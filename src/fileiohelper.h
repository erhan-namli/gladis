#ifndef FILEIOHELPER_H
#define FILEIOHELPER_H

#include <QObject>
#include <QString>
#include <QFileSystemWatcher>
#include <QTimer>

class FileIOHelper : public QObject
{
    Q_OBJECT

public:
    explicit FileIOHelper(QObject *parent = nullptr);
    ~FileIOHelper();

    // Write a file with given content
    Q_INVOKABLE bool writeFile(const QString &filePath, const QString &content);

    // Check if a file exists
    Q_INVOKABLE bool fileExists(const QString &filePath);

    // Delete a file
    Q_INVOKABLE bool deleteFile(const QString &filePath);

    // Read file content
    Q_INVOKABLE QString readFile(const QString &filePath);

    // Watch a file for changes
    Q_INVOKABLE void watchFile(const QString &filePath);

    // Stop watching a file
    Q_INVOKABLE void unwatchFile(const QString &filePath);

signals:
    void fileChanged(const QString &filePath);
    void fileAppeared(const QString &filePath);

private slots:
    void onFileChanged(const QString &path);

private:
    QFileSystemWatcher *m_watcher;
    QTimer *m_checkTimer;
    QStringList m_watchedFiles;

    void checkForNewFiles();
};

#endif // FILEIOHELPER_H
