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
    , m_renderWidth(1024)
    , m_renderHeight(600)
    , m_renderRotate(0)
    , m_renderMouse(1)
    , m_mousePoint("mouse_assets/mouse-point.png")
    , m_mouseHover("mouse_assets/mouse-hover.png")
    , m_mouseField("mouse_assets/mouse-field.png")
    , m_mouseDelay("mouse_assets/mouse-delay.png")
    , m_layer0("")  // Default to empty (layer_0 is front-most)
    , m_layer1("")
    , m_layer2("")
    , m_layer3("")
    , m_layer4("")
    , m_layer5("")
    , m_layer6("")
    , m_layer7("")
    , m_layer8("")
    , m_layer9("")
    , m_layerTransition0(300)  // Default 300ms fade
    , m_layerTransition1(300)
    , m_layerTransition2(300)
    , m_layerTransition3(300)
    , m_layerTransition4(300)
    , m_layerTransition5(300)
    , m_layerTransition6(300)
    , m_layerTransition7(300)
    , m_layerTransition8(300)
    , m_layerTransition9(300)
    , m_timerState(false)
    , m_timerCount(false)
    , m_timerMax(99)
    , m_timerText("FINISH SSO LOGIN")
    , m_timerMenuLeft("NEED MORE TIME")
    , m_timerMenuMiddle("")
    , m_timerMenuRight("START OVER")
    , m_imageSource("")
    , m_imageBgColor("#000000")
    , m_imageFillMode(1)  // Qt::KeepAspectRatio (PreserveAspectFit)
    , m_imageShowBg(false)
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

    // Store previous render dimensions to detect if they changed
    int previousRenderWidth = m_renderWidth;
    int previousRenderHeight = m_renderHeight;

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

    // Load all layers (layer_0 is front-most)
    m_layer0 = m_settings->value("layer_0", "").toString();
    m_layer1 = m_settings->value("layer_1", "").toString();
    m_layer2 = m_settings->value("layer_2", "").toString();
    m_layer3 = m_settings->value("layer_3", "").toString();
    m_layer4 = m_settings->value("layer_4", "").toString();
    m_layer5 = m_settings->value("layer_5", "").toString();
    m_layer6 = m_settings->value("layer_6", "").toString();
    m_layer7 = m_settings->value("layer_7", "").toString();
    m_layer8 = m_settings->value("layer_8", "").toString();
    m_layer9 = m_settings->value("layer_9", "").toString();

    // Load layer transition times (in milliseconds)
    m_layerTransition0 = m_settings->value("layer_transition_0", 300).toInt();
    m_layerTransition1 = m_settings->value("layer_transition_1", 300).toInt();
    m_layerTransition2 = m_settings->value("layer_transition_2", 300).toInt();
    m_layerTransition3 = m_settings->value("layer_transition_3", 300).toInt();
    m_layerTransition4 = m_settings->value("layer_transition_4", 300).toInt();
    m_layerTransition5 = m_settings->value("layer_transition_5", 300).toInt();
    m_layerTransition6 = m_settings->value("layer_transition_6", 300).toInt();
    m_layerTransition7 = m_settings->value("layer_transition_7", 300).toInt();
    m_layerTransition8 = m_settings->value("layer_transition_8", 300).toInt();
    m_layerTransition9 = m_settings->value("layer_transition_9", 300).toInt();

    QString renderWindow = m_settings->value("render_window", "1024;600").toString();  // Default to 1024x600
    QStringList dimensions = renderWindow.split(';');
    if (dimensions.size() == 2) {
        m_renderWidth = dimensions[0].toInt();
        m_renderHeight = dimensions[1].toInt();
    }
    m_renderRotate = m_settings->value("render_rotate", 0).toInt();
    m_renderMouse = m_settings->value("render_mouse", 1).toInt();
    m_mousePoint = m_settings->value("mouse-point", "mouse_assets/mouse-point.png").toString();
    m_mouseHover = m_settings->value("mouse-hover", "mouse_assets/mouse-hover.png").toString();
    m_mouseField = m_settings->value("mouse-field", "mouse_assets/mouse-field.png").toString();
    m_mouseDelay = m_settings->value("mouse-delay", "mouse_assets/mouse-delay.png").toString();
    m_settings->endGroup();

    qDebug() << "Layers (0=front-most):";
    qDebug() << "  layer_0:" << m_layer0 << "(transition:" << m_layerTransition0 << "ms)";
    qDebug() << "  layer_1:" << m_layer1 << "(transition:" << m_layerTransition1 << "ms)";
    qDebug() << "  layer_2:" << m_layer2 << "(transition:" << m_layerTransition2 << "ms)";
    qDebug() << "  layer_3:" << m_layer3 << "(transition:" << m_layerTransition3 << "ms)";
    qDebug() << "  layer_4:" << m_layer4 << "(transition:" << m_layerTransition4 << "ms)";
    qDebug() << "  layer_5:" << m_layer5 << "(transition:" << m_layerTransition5 << "ms)";
    qDebug() << "  layer_6:" << m_layer6 << "(transition:" << m_layerTransition6 << "ms)";
    qDebug() << "  layer_7:" << m_layer7 << "(transition:" << m_layerTransition7 << "ms)";
    qDebug() << "  layer_8:" << m_layer8 << "(transition:" << m_layerTransition8 << "ms)";
    qDebug() << "  layer_9:" << m_layer9 << "(transition:" << m_layerTransition9 << "ms)";
    qDebug() << "Render dimensions:" << m_renderWidth << "x" << m_renderHeight << "Rotation:" << m_renderRotate;
    qDebug() << "Custom mouse cursor:" << (m_renderMouse ? "enabled" : "disabled");

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

    // Load App Image section
    m_settings->beginGroup("app_image");
    m_imageSource = m_settings->value("image_source", "").toString();
    m_imageBgColor = m_settings->value("image_bg_color", "#000000").toString();
    m_imageFillMode = m_settings->value("image_fill_mode", 1).toInt();  // 0=Stretch, 1=PreserveAspectFit, 2=PreserveAspectCrop
    m_imageShowBg = m_settings->value("image_show_bg", 0).toInt() == 1;
    m_settings->endGroup();

    qDebug() << "Image config - Source:" << m_imageSource << "FillMode:" << m_imageFillMode << "ShowBg:" << m_imageShowBg;

    qDebug() << "Config loaded successfully";

    // Check if resolution actually changed
    bool resolutionChanged = (m_renderWidth != previousRenderWidth || m_renderHeight != previousRenderHeight);
    if (resolutionChanged) {
        qDebug() << "Resolution changed from" << previousRenderWidth << "x" << previousRenderHeight
                 << "to" << m_renderWidth << "x" << m_renderHeight;
    }

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
