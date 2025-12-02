#include "datamanager.h"
#include <QFile>
#include <QFileInfo>
#include <QUrl>
#include <QJsonDocument>
#include <QJsonObject>
#include <QDebug>
#include <QDir>
#include <QThread>

DataManager::DataManager(QObject *parent)
    : QObject(parent)
    , m_fileWatcher(new QFileSystemWatcher(this))
    , m_delayTimer(new QTimer(this))
    , m_dataPath("welcome-data")
    , m_qrCodeAvailable(false)
    , m_facilityLogoIsGif(false)
    , m_textDaily("LAB HOURS")
    , m_textCount("PLAYERS")
    , m_textRound("NEW RELEASES")
{
    m_delayTimer->setSingleShot(true);
    m_delayTimer->setInterval(500); // 500ms delay to ensure file write completion

    connect(m_fileWatcher, &QFileSystemWatcher::fileChanged,
            this, &DataManager::onFileChanged);
    connect(m_delayTimer, &QTimer::timeout,
            this, &DataManager::onDelayedFileRead);

    setupFileWatching();
    loadAllData();
}

void DataManager::setDataPath(const QString &path)
{
    if (m_dataPath != path) {
        m_dataPath = path;
        setupFileWatching();
        loadAllData();
        emit dataPathChanged();
    }
}

void DataManager::setupFileWatching()
{
    // Remove existing watches
    if (!m_fileWatcher->files().isEmpty()) {
        m_fileWatcher->removePaths(m_fileWatcher->files());
    }

    // Add files to watch
    QStringList filesToWatch = {
        m_dataPath + "/facility_data.json",
        m_dataPath + "/user_data.json",
        m_dataPath + "/facility_name.txt",
        m_dataPath + "/facility_colors",
        m_dataPath + "/scroll_upper.txt",
        m_dataPath + "/scroll_lower.txt",
        m_dataPath + "/qr_support.png",
        m_dataPath + "/facility_logo.png",
        m_dataPath + "/facility_logo.gif",
        m_dataPath + "/game1_image.jpg",
        m_dataPath + "/game2_image.jpg",
        m_dataPath + "/game3_image.jpg",
        m_dataPath + "/game4_image.jpg",
        m_dataPath + "/left_image.png",
        m_dataPath + "/right_image.png",
        m_dataPath + "/banner_image.png",
        m_dataPath + "/text_daily",
        m_dataPath + "/text_count",
        m_dataPath + "/text_round"
    };

    for (const QString &file : filesToWatch) {
        if (QFile::exists(file)) {
            m_fileWatcher->addPath(file);
            qDebug() << "Watching file:" << file;
        } else {
            qWarning() << "File not found:" << file;
        }
    }
}

void DataManager::onFileChanged(const QString &path)
{
    qDebug() << "File changed detected:" << path;

    // Store the pending file and start the delay timer
    m_pendingFile = path;
    m_delayTimer->start();
}

void DataManager::onDelayedFileRead()
{
    if (m_pendingFile.isEmpty()) {
        return;
    }

    QString path = m_pendingFile;
    m_pendingFile.clear();

    // Check if file is stable (same size for the delay period)
    if (!isFileStable(path)) {
        qDebug() << "File still being written, retrying:" << path;
        m_pendingFile = path;
        m_delayTimer->start();
        return;
    }

    qDebug() << "Reading stable file:" << path;

    // Re-add the file to watcher (sometimes removed after modification)
    if (!m_fileWatcher->files().contains(path)) {
        m_fileWatcher->addPath(path);
    }

    // Load the appropriate data based on filename
    if (path.endsWith("facility_data.json")) {
        loadFacilityData();
    } else if (path.endsWith("user_data.json")) {
        loadUserData();
    } else if (path.endsWith("facility_name.txt")) {
        loadFacilityName();
    } else if (path.endsWith("facility_colors")) {
        loadFacilityColors();
    } else if (path.endsWith("scroll_upper.txt")) {
        loadScrollUpperText();
    } else if (path.endsWith("scroll_lower.txt")) {
        loadScrollLowerText();
    } else if (path.endsWith("qr_support.png")) {
        checkQRCodeAvailability();
    } else if (path.endsWith("facility_logo.png") || path.endsWith("facility_logo.gif")) {
        // Facility logo changed - check type and emit signals
        checkFacilityLogoType();
        qDebug() << "Facility logo file changed, emitting imagesChanged signal";
        emit imagesChanged();
    } else if (path.endsWith("_image.jpg") || path.endsWith("_image.png")) {
        // Image file changed - emit signal to reload images in QML
        qDebug() << "Image file changed, emitting imagesChanged signal";
        emit imagesChanged();
    } else if (path.endsWith("text_daily")) {
        loadTextDaily();
    } else if (path.endsWith("text_count")) {
        loadTextCount();
    } else if (path.endsWith("text_round")) {
        loadTextRound();
    }
}

bool DataManager::isFileStable(const QString &path)
{
    QFileInfo fileInfo(path);
    if (!fileInfo.exists()) {
        return false;
    }

    qint64 currentSize = fileInfo.size();
    QDateTime currentModTime = fileInfo.lastModified();

    // Check if we have previous data
    if (m_fileSizes.contains(path)) {
        if (m_fileSizes[path] == currentSize &&
            m_fileModificationTimes[path] == currentModTime) {
            // File is stable
            m_fileSizes.remove(path);
            m_fileModificationTimes.remove(path);
            return true;
        }
    }

    // Store current state
    m_fileSizes[path] = currentSize;
    m_fileModificationTimes[path] = currentModTime;
    return false;
}

QByteArray DataManager::safeReadFile(const QString &path)
{
    QFile file(path);
    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file:" << path;
        return QByteArray();
    }

    QByteArray data = file.readAll();
    file.close();
    return data;
}

void DataManager::loadAllData()
{
    loadFacilityData();
    loadUserData();
    loadFacilityName();
    loadFacilityColors();
    loadScrollUpperText();
    loadScrollLowerText();
    checkQRCodeAvailability();
    checkFacilityLogoType();
    loadTextDaily();
    loadTextCount();
    loadTextRound();
}

void DataManager::loadFacilityData()
{
    QString filePath = m_dataPath + "/facility_data.json";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read facility_data.json";
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error in facility_data.json:" << parseError.errorString();
        return;
    }

    if (doc.isObject()) {
        m_facilityData = doc.object().toVariantMap();
        emit facilityDataChanged();
        qDebug() << "Facility data loaded successfully";
    }
}

void DataManager::loadUserData()
{
    QString filePath = m_dataPath + "/user_data.json";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read user_data.json";
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error in user_data.json:" << parseError.errorString();
        return;
    }

    if (doc.isObject()) {
        m_userData = doc.object().toVariantMap();
        emit userDataChanged();
        qDebug() << "User data loaded successfully";
    }
}

void DataManager::loadFacilityName()
{
    QString filePath = m_dataPath + "/facility_name.txt";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read facility_name.txt";
        return;
    }

    QString name = QString::fromUtf8(data).trimmed();
    if (m_facilityName != name) {
        m_facilityName = name;
        emit facilityNameChanged();
        qDebug() << "Facility name loaded:" << m_facilityName;
    }
}

void DataManager::loadFacilityColors()
{
    QString filePath = m_dataPath + "/facility_colors";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read facility_colors";
        return;
    }

    QJsonParseError parseError;
    QJsonDocument doc = QJsonDocument::fromJson(data, &parseError);

    if (parseError.error != QJsonParseError::NoError) {
        qWarning() << "JSON parse error in facility_colors:" << parseError.errorString();
        return;
    }

    if (doc.isObject()) {
        m_facilityColors = doc.object().toVariantMap();
        emit facilityColorsChanged();
        qDebug() << "Facility colors loaded successfully";
    }
}

QString DataManager::getGameImagePath(int index) const
{
    QString relativePath = m_dataPath + QString("/game%1_image.jpg").arg(index);
    QFileInfo fileInfo(relativePath);
    return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
}

QString DataManager::getBannerImagePath() const
{
    QString relativePath = m_dataPath + "/banner_image.png";
    QFileInfo fileInfo(relativePath);
    return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
}

QString DataManager::getFacilityLogoPath() const
{
    // Check for .png first, then .gif
    QString pngPath = m_dataPath + "/facility_logo.png";
    QString gifPath = m_dataPath + "/facility_logo.gif";

    if (QFile::exists(pngPath)) {
        QFileInfo fileInfo(pngPath);
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
    } else if (QFile::exists(gifPath)) {
        QFileInfo fileInfo(gifPath);
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
    }

    // Return empty if neither exists
    return "";
}

QString DataManager::getLeftImagePath() const
{
    QString relativePath = m_dataPath + "/left_image.png";
    QFileInfo fileInfo(relativePath);
    return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
}

QString DataManager::getRightImagePath() const
{
    QString relativePath = m_dataPath + "/right_image.png";
    QFileInfo fileInfo(relativePath);
    return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
}

QString DataManager::getQRCodePath() const
{
    QString relativePath = m_dataPath + "/qr_support.png";
    QFileInfo fileInfo(relativePath);
    return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
}

QString DataManager::getGameLabGifPath() const
{
    QString relativePath = m_dataPath + "/gamelab.gif";
    QFileInfo fileInfo(relativePath);
    if (fileInfo.exists()) {
        return QUrl::fromLocalFile(fileInfo.absoluteFilePath()).toString();
    }
    return "";
}

void DataManager::loadScrollUpperText()
{
    QString filePath = m_dataPath + "/scroll_upper.txt";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read scroll_upper.txt";
        m_scrollUpperText = "SEAMLESS SCROLLING TEXT NOTIFICATION";
        emit scrollUpperTextChanged();
        return;
    }

    QString text = QString::fromUtf8(data).trimmed();
    if (m_scrollUpperText != text) {
        m_scrollUpperText = text;
        emit scrollUpperTextChanged();
        qDebug() << "Scroll upper text loaded:" << m_scrollUpperText;
    }
}

void DataManager::loadScrollLowerText()
{
    QString filePath = m_dataPath + "/scroll_lower.txt";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read scroll_lower.txt";
        m_scrollLowerText = "SEAMLESS SCROLLING TEXT NOTIFICATION";
        emit scrollLowerTextChanged();
        return;
    }

    QString text = QString::fromUtf8(data).trimmed();
    if (m_scrollLowerText != text) {
        m_scrollLowerText = text;
        emit scrollLowerTextChanged();
        qDebug() << "Scroll lower text loaded:" << m_scrollLowerText;
    }
}

void DataManager::checkQRCodeAvailability()
{
    QString filePath = m_dataPath + "/qr_support.png";
    bool available = QFile::exists(filePath);

    if (m_qrCodeAvailable != available) {
        m_qrCodeAvailable = available;
        emit qrCodeAvailableChanged();
        qDebug() << "QR code availability:" << m_qrCodeAvailable;
    }
}

void DataManager::checkFacilityLogoType()
{
    QString gifPath = m_dataPath + "/facility_logo.gif";
    bool isGif = QFile::exists(gifPath);

    if (m_facilityLogoIsGif != isGif) {
        m_facilityLogoIsGif = isGif;
        emit facilityLogoIsGifChanged();
        qDebug() << "Facility logo is GIF:" << m_facilityLogoIsGif;
    }
}

void DataManager::loadTextDaily()
{
    QString filePath = m_dataPath + "/text_daily";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read text_daily";
        m_textDaily = "LAB HOURS";  // Default value
        emit textDailyChanged();
        return;
    }

    QString text = QString::fromUtf8(data).trimmed();
    if (m_textDaily != text) {
        m_textDaily = text;
        emit textDailyChanged();
        qDebug() << "Text daily loaded:" << m_textDaily;
    }
}

void DataManager::loadTextCount()
{
    QString filePath = m_dataPath + "/text_count";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read text_count";
        m_textCount = "PLAYERS";  // Default value
        emit textCountChanged();
        return;
    }

    QString text = QString::fromUtf8(data).trimmed();
    if (m_textCount != text) {
        m_textCount = text;
        emit textCountChanged();
        qDebug() << "Text count loaded:" << m_textCount;
    }
}

void DataManager::loadTextRound()
{
    QString filePath = m_dataPath + "/text_round";
    QByteArray data = safeReadFile(filePath);

    if (data.isEmpty()) {
        qWarning() << "Empty or failed to read text_round";
        m_textRound = "NEW RELEASES";  // Default value
        emit textRoundChanged();
        return;
    }

    QString text = QString::fromUtf8(data).trimmed();
    if (m_textRound != text) {
        m_textRound = text;
        emit textRoundChanged();
        qDebug() << "Text round loaded:" << m_textRound;
    }
}
