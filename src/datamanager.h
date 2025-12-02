#ifndef DATAMANAGER_H
#define DATAMANAGER_H

#include <QObject>
#include <QFileSystemWatcher>
#include <QTimer>
#include <QVariantMap>
#include <QHash>
#include <QDateTime>

class DataManager : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QVariantMap facilityData READ facilityData NOTIFY facilityDataChanged)
    Q_PROPERTY(QVariantMap userData READ userData NOTIFY userDataChanged)
    Q_PROPERTY(QString facilityName READ facilityName NOTIFY facilityNameChanged)
    Q_PROPERTY(QVariantMap facilityColors READ facilityColors NOTIFY facilityColorsChanged)
    Q_PROPERTY(QString dataPath READ dataPath WRITE setDataPath NOTIFY dataPathChanged)
    Q_PROPERTY(QString scrollUpperText READ scrollUpperText NOTIFY scrollUpperTextChanged)
    Q_PROPERTY(QString scrollLowerText READ scrollLowerText NOTIFY scrollLowerTextChanged)
    Q_PROPERTY(bool qrCodeAvailable READ qrCodeAvailable NOTIFY qrCodeAvailableChanged)
    Q_PROPERTY(bool facilityLogoIsGif READ facilityLogoIsGif NOTIFY facilityLogoIsGifChanged)
    Q_PROPERTY(QString textDaily READ textDaily NOTIFY textDailyChanged)
    Q_PROPERTY(QString textCount READ textCount NOTIFY textCountChanged)
    Q_PROPERTY(QString textRound READ textRound NOTIFY textRoundChanged)

public:
    explicit DataManager(QObject *parent = nullptr);

    QVariantMap facilityData() const { return m_facilityData; }
    QVariantMap userData() const { return m_userData; }
    QString facilityName() const { return m_facilityName; }
    QVariantMap facilityColors() const { return m_facilityColors; }
    QString dataPath() const { return m_dataPath; }
    QString scrollUpperText() const { return m_scrollUpperText; }
    QString scrollLowerText() const { return m_scrollLowerText; }
    bool qrCodeAvailable() const { return m_qrCodeAvailable; }
    bool facilityLogoIsGif() const { return m_facilityLogoIsGif; }
    QString textDaily() const { return m_textDaily; }
    QString textCount() const { return m_textCount; }
    QString textRound() const { return m_textRound; }

    void setDataPath(const QString &path);

    Q_INVOKABLE QString getGameImagePath(int index) const;
    Q_INVOKABLE QString getBannerImagePath() const;
    Q_INVOKABLE QString getFacilityLogoPath() const;
    Q_INVOKABLE QString getLeftImagePath() const;
    Q_INVOKABLE QString getRightImagePath() const;
    Q_INVOKABLE QString getQRCodePath() const;
    Q_INVOKABLE QString getGameLabGifPath() const;

signals:
    void facilityDataChanged();
    void userDataChanged();
    void facilityNameChanged();
    void facilityColorsChanged();
    void dataPathChanged();
    void scrollUpperTextChanged();
    void scrollLowerTextChanged();
    void qrCodeAvailableChanged();
    void imagesChanged();  // Signal when any image file changes
    void facilityLogoIsGifChanged();
    void textDailyChanged();
    void textCountChanged();
    void textRoundChanged();

private slots:
    void onFileChanged(const QString &path);
    void onDelayedFileRead();

private:
    void setupFileWatching();
    void loadAllData();
    void loadFacilityData();
    void loadUserData();
    void loadFacilityName();
    void loadFacilityColors();
    void loadScrollUpperText();
    void loadScrollLowerText();
    void checkQRCodeAvailability();
    void checkFacilityLogoType();
    void loadTextDaily();
    void loadTextCount();
    void loadTextRound();
    bool isFileStable(const QString &path);
    QByteArray safeReadFile(const QString &path);

    QFileSystemWatcher *m_fileWatcher;
    QTimer *m_delayTimer;
    QHash<QString, QDateTime> m_fileModificationTimes;
    QHash<QString, qint64> m_fileSizes;
    QString m_pendingFile;

    QVariantMap m_facilityData;
    QVariantMap m_userData;
    QString m_facilityName;
    QVariantMap m_facilityColors;
    QString m_dataPath;
    QString m_scrollUpperText;
    QString m_scrollLowerText;
    bool m_qrCodeAvailable;
    bool m_facilityLogoIsGif;
    QString m_textDaily;
    QString m_textCount;
    QString m_textRound;
};

#endif // DATAMANAGER_H
