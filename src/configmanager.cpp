#include "configmanager.h"
#include <QDebug>
#include <QFile>
#include <QRegularExpression>

ConfigManager::ConfigManager(QObject *parent)
    : QObject(parent)
    , m_fileWatcher(new QFileSystemWatcher(this))
    , m_settings(nullptr)
    , m_colorFlip(false)
    , m_helloState(true)
    , m_renderWidth(1080)
    , m_renderHeight(1920)
    , m_renderRotate(0)
    , m_layer0("app_hello")
    , m_timerState(false)
    , m_timerCount(false)
    , m_timerMax(99)
    , m_timerText("FINISH SSO LOGIN")
    , m_timerMenuLeft("NEED MORE TIME")
    , m_timerMenuMiddle("")
    , m_timerMenuRight("START OVER")
{
    connect(m_fileWatcher, &QFileSystemWatcher::fileChanged, this, &ConfigManager::onFileChanged);
}

ConfigManager::~ConfigManager()
{
    if (m_settings) {
        delete m_settings;
    }
}

void ConfigManager::setConfigPath(const QString &path)
{
    m_configPath = path;

    // Remove old file from watcher if exists
    if (!m_fileWatcher->files().isEmpty()) {
        m_fileWatcher->removePaths(m_fileWatcher->files());
    }

    // Add new file to watcher
    if (QFile::exists(path)) {
        m_fileWatcher->addPath(path);
        qDebug() << "Watching config file:" << path;
    } else {
        qWarning() << "Config file does not exist:" << path;
    }

    loadConfig();
}

QString ConfigManager::parseHexColor(const QString &value)
{
    // Extract hex value from format like "{0x000000}" or "0x000000"
    QRegularExpression hexRegex("(?:0x|#)?([0-9A-Fa-f]{6})");
    QRegularExpressionMatch match = hexRegex.match(value);

    if (match.hasMatch()) {
        return "#" + match.captured(1);
    }

    // Return default if parsing fails
    return "#000000";
}

void ConfigManager::loadConfig()
{
    if (m_configPath.isEmpty()) {
        qWarning() << "Config path not set";
        return;
    }

    if (!QFile::exists(m_configPath)) {
        qWarning() << "Config file does not exist:" << m_configPath;
        return;
    }

    // Clean up old settings object
    if (m_settings) {
        delete m_settings;
    }

    // Create new settings object
    m_settings = new QSettings(m_configPath, QSettings::IniFormat);
    qDebug() << "Loading config from:" << m_configPath;

    // Load App Theme section
    m_settings->beginGroup("app_theme");
    m_colorMain = parseHexColor(m_settings->value("color_main", "0x00AEEF").toString());
    m_colorBg01 = parseHexColor(m_settings->value("color_bg01", "0x002657").toString());
    m_colorBg02 = parseHexColor(m_settings->value("color_bg02", "0x00529b").toString());
    m_colorText = parseHexColor(m_settings->value("color_text", "0xfb6502").toString());
    m_colorFlip = m_settings->value("color_flip", 0).toInt() == 1;
    m_settings->endGroup();

    qDebug() << "Theme colors - Main:" << m_colorMain << "Bg01:" << m_colorBg01 << "Bg02:" << m_colorBg02 << "Text:" << m_colorText;

    // Load App Hello section
    m_settings->beginGroup("app_hello");
    m_helloState = m_settings->value("hello_state", 1).toInt() == 1;
    m_helloNews1 = m_settings->value("hello_news-1", "Welcome!").toString();
    m_helloNews2 = m_settings->value("hello_news-2", "Welcome!").toString();
    m_helloLead = m_settings->value("hello_lead", "/home/gladis/app/vars/banner_image.png").toString();
    m_helloMain = m_settings->value("hello_main", "/home/gladis/app/vars/facility_logo.png").toString();
    m_helloSpinText = m_settings->value("hello_spin-text", "NEW RELEASES").toString();
    m_helloSpinImg1 = m_settings->value("hello_spin-img1", "/home/gladis/app/vars/game1_image.jpg").toString();
    m_helloSpinImg2 = m_settings->value("hello_spin-img2", "/home/gladis/app/vars/game2_image.jpg").toString();
    m_helloSpinImg3 = m_settings->value("hello_spin-img3", "/home/gladis/app/vars/game3_image.jpg").toString();
    m_helloSpinImg4 = m_settings->value("hello_spin-img4", "/home/gladis/app/vars/game4_image.jpg").toString();
    m_helloShow1 = m_settings->value("hello_show-1", "/home/gladis/app/vars/left_image.png").toString();
    m_helloShow2 = m_settings->value("hello_show-2", "/home/gladis/app/vars/right_image.png").toString();
    m_helloHourText = m_settings->value("hello_hour-text", "LAB HOURS").toString();
    m_helloHourData = m_settings->value("hello_hour-data", "/home/gladis/app/vars/facility_data.json").toString();
    m_helloListText = m_settings->value("hello_list-text", "PLAYERS").toString();
    m_helloListData = m_settings->value("hello_list-data", "/home/gladis/app/vars/user_data.json").toString();
    m_helloLogo = m_settings->value("hello_logo", "/home/gladis/app/vars/gamelab.gif").toString();
    m_helloScan = m_settings->value("hello_scan", "/home/gladis/app/vars/qr_support.png").toString();
    m_settings->endGroup();

    // Parse platform list from hello_list-* entries
    parsePlatformList();

    // Load render properties from app_live section
    m_settings->beginGroup("app_live");
    m_layer0 = m_settings->value("layer_0", "app_hello").toString();
    QString renderWindow = m_settings->value("render_window", "1080;1920").toString();
    QStringList dimensions = renderWindow.split(';');
    if (dimensions.size() == 2) {
        m_renderWidth = dimensions[0].toInt();
        m_renderHeight = dimensions[1].toInt();
    }
    m_renderRotate = m_settings->value("render_rotate", 0).toInt();
    m_settings->endGroup();

    qDebug() << "Active layer (layer_0):" << m_layer0;
    qDebug() << "Render dimensions:" << m_renderWidth << "x" << m_renderHeight << "Rotation:" << m_renderRotate;

    // Load App Timer section
    m_settings->beginGroup("app_timer");
    m_timerState = m_settings->value("timer_state", 0).toInt() == 1;
    m_timerCount = m_settings->value("timer_count", 0).toInt() == 1;
    m_timerMax = m_settings->value("timer_max", 99).toInt();
    m_timerText = m_settings->value("timer_text", "FINISH SSO LOGIN").toString();
    m_timerMenuLeft = m_settings->value("timer_menu-l", "NEED MORE TIME").toString();
    m_timerMenuMiddle = m_settings->value("timer_menu-m", "").toString();
    m_timerMenuRight = m_settings->value("timer_menu-r", "START OVER").toString();
    m_settings->endGroup();

    qDebug() << "Timer config - State:" << m_timerState << "Count:" << m_timerCount << "Max:" << m_timerMax;
    qDebug() << "Timer text:" << m_timerText;

    qDebug() << "Config loaded successfully";

    emit configChanged();
}

void ConfigManager::parsePlatformList()
{
    m_platformList.clear();

    if (!m_settings) {
        return;
    }

    m_settings->beginGroup("app_hello");

    // Parse hello_list-* entries (img, cat, tot)
    // Look for entries from 0 to 9 (supports up to 10 platforms)
    for (int i = 0; i < 10; i++) {
        QString imgKey = QString("hello_list-img%1").arg(i);
        QString catKey = QString("hello_list-cat%1").arg(i);
        QString totKey = QString("hello_list-tot%1").arg(i);

        if (m_settings->contains(catKey)) {
            QVariantMap platform;
            platform["icon"] = m_settings->value(imgKey, "").toString();
            platform["category"] = m_settings->value(catKey, "").toString();
            platform["total"] = m_settings->value(totKey, "0").toInt();
            platform["index"] = i;

            m_platformList.append(platform);
            qDebug() << "Platform" << i << ":" << platform["category"] << "-" << platform["total"] << "icon:" << platform["icon"];
        }
    }

    m_settings->endGroup();

    qDebug() << "Parsed" << m_platformList.size() << "platforms";
}

void ConfigManager::onFileChanged(const QString &path)
{
    qDebug() << "Config file changed:" << path;

    // Re-add the file to watcher (it gets removed automatically after change)
    if (!m_fileWatcher->files().contains(path)) {
        m_fileWatcher->addPath(path);
    }

    // Reload configuration
    loadConfig();
}
