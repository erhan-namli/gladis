#include "fileiohelper.h"
#include <QFile>
#include <QTextStream>
#include <QDebug>
#include <QTimer>
#include <QDir>

FileIOHelper::FileIOHelper(QObject *parent)
    : QObject(parent)
    , m_watcher(new QFileSystemWatcher(this))
    , m_checkTimer(new QTimer(this))
{
    connect(m_watcher, &QFileSystemWatcher::fileChanged, this, &FileIOHelper::onFileChanged);

    // Timer to periodically check for files that don't exist yet
    m_checkTimer->setInterval(500);  // Check every 500ms
    connect(m_checkTimer, &QTimer::timeout, this, &FileIOHelper::checkForNewFiles);
    m_checkTimer->start();
}

FileIOHelper::~FileIOHelper()
{
}

bool FileIOHelper::writeFile(const QString &filePath, const QString &content)
{
    QFile file(filePath);

    // Ensure directory exists
    QFileInfo fileInfo(filePath);
    QDir dir = fileInfo.absoluteDir();
    if (!dir.exists()) {
        if (!dir.mkpath(".")) {
            qWarning() << "Failed to create directory for file:" << filePath;
            return false;
        }
    }

    if (!file.open(QIODevice::WriteOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file for writing:" << filePath << file.errorString();
        return false;
    }

    QTextStream out(&file);
    out << content;
    file.close();

    qDebug() << "Wrote file:" << filePath;
    return true;
}

bool FileIOHelper::fileExists(const QString &filePath)
{
    return QFile::exists(filePath);
}

bool FileIOHelper::deleteFile(const QString &filePath)
{
    if (!QFile::exists(filePath)) {
        return false;
    }

    bool success = QFile::remove(filePath);
    if (success) {
        qDebug() << "Deleted file:" << filePath;
    } else {
        qWarning() << "Failed to delete file:" << filePath;
    }

    return success;
}

QString FileIOHelper::readFile(const QString &filePath)
{
    QFile file(filePath);

    if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
        qWarning() << "Failed to open file for reading:" << filePath;
        return QString();
    }

    QTextStream in(&file);
    QString content = in.readAll();
    file.close();

    return content;
}

void FileIOHelper::watchFile(const QString &filePath)
{
    if (m_watchedFiles.contains(filePath)) {
        return;  // Already watching
    }

    m_watchedFiles.append(filePath);

    // Only add to watcher if file exists
    if (QFile::exists(filePath)) {
        if (!m_watcher->files().contains(filePath)) {
            m_watcher->addPath(filePath);
            qDebug() << "Watching file:" << filePath;
        }
    } else {
        qDebug() << "Will watch for file when it appears:" << filePath;
    }
}

void FileIOHelper::unwatchFile(const QString &filePath)
{
    m_watchedFiles.removeAll(filePath);

    if (m_watcher->files().contains(filePath)) {
        m_watcher->removePath(filePath);
        qDebug() << "Stopped watching file:" << filePath;
    }
}

void FileIOHelper::onFileChanged(const QString &path)
{
    qDebug() << "File changed:" << path;

    // Re-add to watcher (some systems remove it after change)
    if (!m_watcher->files().contains(path) && QFile::exists(path)) {
        m_watcher->addPath(path);
    }

    emit fileChanged(path);
}

void FileIOHelper::checkForNewFiles()
{
    // Check if any watched files that didn't exist now exist
    for (const QString &filePath : m_watchedFiles) {
        if (!m_watcher->files().contains(filePath) && QFile::exists(filePath)) {
            m_watcher->addPath(filePath);
            qDebug() << "File appeared, now watching:" << filePath;
            emit fileAppeared(filePath);
            emit fileChanged(filePath);
        }
    }
}
