#ifndef CONFIGMANAGER_H
#define CONFIGMANAGER_H

#include <QObject>
#include <QSettings>
#include <QFileSystemWatcher>
#include <QVariantMap>
#include <QString>
#include <QColor>

class ConfigManager : public QObject
{
    Q_OBJECT

    // App Theme Properties
    Q_PROPERTY(QString colorMain READ colorMain NOTIFY configChanged)
    Q_PROPERTY(QString colorBg01 READ colorBg01 NOTIFY configChanged)
    Q_PROPERTY(QString colorBg02 READ colorBg02 NOTIFY configChanged)
    Q_PROPERTY(QString colorText READ colorText NOTIFY configChanged)
    Q_PROPERTY(bool colorFlip READ colorFlip NOTIFY configChanged)

    // App Hello Properties
    Q_PROPERTY(bool helloState READ helloState NOTIFY configChanged)
    Q_PROPERTY(QString helloNews1 READ helloNews1 NOTIFY configChanged)
    Q_PROPERTY(QString helloNews2 READ helloNews2 NOTIFY configChanged)
    Q_PROPERTY(QString helloLead READ helloLead NOTIFY configChanged)
    Q_PROPERTY(QString helloMain READ helloMain NOTIFY configChanged)
    Q_PROPERTY(QString helloSpinText READ helloSpinText NOTIFY configChanged)
    Q_PROPERTY(QString helloSpinImg1 READ helloSpinImg1 NOTIFY configChanged)
    Q_PROPERTY(QString helloSpinImg2 READ helloSpinImg2 NOTIFY configChanged)
    Q_PROPERTY(QString helloSpinImg3 READ helloSpinImg3 NOTIFY configChanged)
    Q_PROPERTY(QString helloSpinImg4 READ helloSpinImg4 NOTIFY configChanged)
    Q_PROPERTY(QString helloShow1 READ helloShow1 NOTIFY configChanged)
    Q_PROPERTY(QString helloShow2 READ helloShow2 NOTIFY configChanged)
    Q_PROPERTY(QString helloHourText READ helloHourText NOTIFY configChanged)
    Q_PROPERTY(QString helloHourData READ helloHourData NOTIFY configChanged)
    Q_PROPERTY(QString helloListText READ helloListText NOTIFY configChanged)
    Q_PROPERTY(QString helloListData READ helloListData NOTIFY configChanged)
    Q_PROPERTY(QString helloLogo READ helloLogo NOTIFY configChanged)
    Q_PROPERTY(QString helloScan READ helloScan NOTIFY configChanged)

    // Dynamic player list properties (for platforms)
    Q_PROPERTY(QVariantList platformList READ platformList NOTIFY configChanged)

    // Render properties
    Q_PROPERTY(int renderScreen READ renderScreen NOTIFY configChanged)
    Q_PROPERTY(int renderWidth READ renderWidth NOTIFY configChanged)
    Q_PROPERTY(int renderHeight READ renderHeight NOTIFY configChanged)
    Q_PROPERTY(int renderRotate READ renderRotate NOTIFY configChanged)
    Q_PROPERTY(int renderMouse READ renderMouse NOTIFY configChanged)
    Q_PROPERTY(QString mousePoint READ mousePoint NOTIFY configChanged)
    Q_PROPERTY(QString mouseHover READ mouseHover NOTIFY configChanged)
    Q_PROPERTY(QString mouseField READ mouseField NOTIFY configChanged)
    Q_PROPERTY(QString mouseDelay READ mouseDelay NOTIFY configChanged)

    // App Live properties - Layer system (layer_0 is front-most)
    Q_PROPERTY(QString layer0 READ layer0 NOTIFY configChanged)
    Q_PROPERTY(QString layer1 READ layer1 NOTIFY configChanged)
    Q_PROPERTY(QString layer2 READ layer2 NOTIFY configChanged)
    Q_PROPERTY(QString layer3 READ layer3 NOTIFY configChanged)
    Q_PROPERTY(QString layer4 READ layer4 NOTIFY configChanged)
    Q_PROPERTY(QString layer5 READ layer5 NOTIFY configChanged)
    Q_PROPERTY(QString layer6 READ layer6 NOTIFY configChanged)
    Q_PROPERTY(QString layer7 READ layer7 NOTIFY configChanged)
    Q_PROPERTY(QString layer8 READ layer8 NOTIFY configChanged)
    Q_PROPERTY(QString layer9 READ layer9 NOTIFY configChanged)

    // Layer transition times (opacity fade duration in milliseconds)
    Q_PROPERTY(int layerTransition0 READ layerTransition0 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition1 READ layerTransition1 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition2 READ layerTransition2 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition3 READ layerTransition3 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition4 READ layerTransition4 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition5 READ layerTransition5 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition6 READ layerTransition6 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition7 READ layerTransition7 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition8 READ layerTransition8 NOTIFY configChanged)
    Q_PROPERTY(int layerTransition9 READ layerTransition9 NOTIFY configChanged)

    // App Timer Properties
    Q_PROPERTY(bool timerState READ timerState NOTIFY configChanged)
    Q_PROPERTY(bool timerCount READ timerCount NOTIFY configChanged)
    Q_PROPERTY(int timerMax READ timerMax NOTIFY configChanged)
    Q_PROPERTY(QString timerText READ timerText NOTIFY configChanged)
    Q_PROPERTY(QString timerMenuLeft READ timerMenuLeft NOTIFY configChanged)
    Q_PROPERTY(QString timerMenuMiddle READ timerMenuMiddle NOTIFY configChanged)
    Q_PROPERTY(QString timerMenuRight READ timerMenuRight NOTIFY configChanged)

    // App Image Properties
    Q_PROPERTY(QString imageSource READ imageSource NOTIFY configChanged)
    Q_PROPERTY(QString imageBgColor READ imageBgColor NOTIFY configChanged)
    Q_PROPERTY(int imageFillMode READ imageFillMode NOTIFY configChanged)
    Q_PROPERTY(bool imageShowBg READ imageShowBg NOTIFY configChanged)

public:
    explicit ConfigManager(QObject *parent = nullptr);
    ~ConfigManager();

    void setConfigPath(const QString &path);
    void loadConfig();

    // Getters for App Theme
    QString colorMain() const { return m_colorMain; }
    QString colorBg01() const { return m_colorBg01; }
    QString colorBg02() const { return m_colorBg02; }
    QString colorText() const { return m_colorText; }
    bool colorFlip() const { return m_colorFlip; }

    // Getters for App Hello
    bool helloState() const { return m_helloState; }
    QString helloNews1() const { return m_helloNews1; }
    QString helloNews2() const { return m_helloNews2; }
    QString helloLead() const { return m_helloLead; }
    QString helloMain() const { return m_helloMain; }
    QString helloSpinText() const { return m_helloSpinText; }
    QString helloSpinImg1() const { return m_helloSpinImg1; }
    QString helloSpinImg2() const { return m_helloSpinImg2; }
    QString helloSpinImg3() const { return m_helloSpinImg3; }
    QString helloSpinImg4() const { return m_helloSpinImg4; }
    QString helloShow1() const { return m_helloShow1; }
    QString helloShow2() const { return m_helloShow2; }
    QString helloHourText() const { return m_helloHourText; }
    QString helloHourData() const { return m_helloHourData; }
    QString helloListText() const { return m_helloListText; }
    QString helloListData() const { return m_helloListData; }
    QString helloLogo() const { return m_helloLogo; }
    QString helloScan() const { return m_helloScan; }

    // Getters for dynamic platform list
    QVariantList platformList() const { return m_platformList; }

    // Getters for render properties
    int renderScreen() const { return m_renderScreen; }
    int renderWidth() const { return m_renderWidth; }
    int renderHeight() const { return m_renderHeight; }
    int renderRotate() const { return m_renderRotate; }
    int renderMouse() const { return m_renderMouse; }
    QString mousePoint() const { return m_mousePoint; }
    QString mouseHover() const { return m_mouseHover; }
    QString mouseField() const { return m_mouseField; }
    QString mouseDelay() const { return m_mouseDelay; }

    // Getters for app live - Layers
    QString layer0() const { return m_layer0; }
    QString layer1() const { return m_layer1; }
    QString layer2() const { return m_layer2; }
    QString layer3() const { return m_layer3; }
    QString layer4() const { return m_layer4; }
    QString layer5() const { return m_layer5; }
    QString layer6() const { return m_layer6; }
    QString layer7() const { return m_layer7; }
    QString layer8() const { return m_layer8; }
    QString layer9() const { return m_layer9; }

    // Getters for layer transitions
    int layerTransition0() const { return m_layerTransition0; }
    int layerTransition1() const { return m_layerTransition1; }
    int layerTransition2() const { return m_layerTransition2; }
    int layerTransition3() const { return m_layerTransition3; }
    int layerTransition4() const { return m_layerTransition4; }
    int layerTransition5() const { return m_layerTransition5; }
    int layerTransition6() const { return m_layerTransition6; }
    int layerTransition7() const { return m_layerTransition7; }
    int layerTransition8() const { return m_layerTransition8; }
    int layerTransition9() const { return m_layerTransition9; }

    // Getters for timer
    bool timerState() const { return m_timerState; }
    bool timerCount() const { return m_timerCount; }
    int timerMax() const { return m_timerMax; }
    QString timerText() const { return m_timerText; }
    QString timerMenuLeft() const { return m_timerMenuLeft; }
    QString timerMenuMiddle() const { return m_timerMenuMiddle; }
    QString timerMenuRight() const { return m_timerMenuRight; }

    // Getters for image app
    QString imageSource() const { return m_imageSource; }
    QString imageBgColor() const { return m_imageBgColor; }
    int imageFillMode() const { return m_imageFillMode; }
    bool imageShowBg() const { return m_imageShowBg; }

signals:
    void configChanged();

private slots:
    void onFileChanged(const QString &path);

private:
    QString parseHexColor(const QString &value);
    void parsePlatformList();

    QString m_configPath;
    QFileSystemWatcher *m_fileWatcher;
    QSettings *m_settings;

    // App Theme members
    QString m_colorMain;
    QString m_colorBg01;
    QString m_colorBg02;
    QString m_colorText;
    bool m_colorFlip;

    // App Hello members
    bool m_helloState;
    QString m_helloNews1;
    QString m_helloNews2;
    QString m_helloLead;
    QString m_helloMain;
    QString m_helloSpinText;
    QString m_helloSpinImg1;
    QString m_helloSpinImg2;
    QString m_helloSpinImg3;
    QString m_helloSpinImg4;
    QString m_helloShow1;
    QString m_helloShow2;
    QString m_helloHourText;
    QString m_helloHourData;
    QString m_helloListText;
    QString m_helloListData;
    QString m_helloLogo;
    QString m_helloScan;

    // Dynamic platform list
    QVariantList m_platformList;

    // Render properties
    int m_renderScreen;
    int m_renderWidth;
    int m_renderHeight;
    int m_renderRotate;
    int m_renderMouse;
    QString m_mousePoint;
    QString m_mouseHover;
    QString m_mouseField;
    QString m_mouseDelay;

    // App live properties - Layers (layer_0 is front-most, higher z-index)
    QString m_layer0;
    QString m_layer1;
    QString m_layer2;
    QString m_layer3;
    QString m_layer4;
    QString m_layer5;
    QString m_layer6;
    QString m_layer7;
    QString m_layer8;
    QString m_layer9;

    // Layer transition times (in milliseconds)
    int m_layerTransition0;
    int m_layerTransition1;
    int m_layerTransition2;
    int m_layerTransition3;
    int m_layerTransition4;
    int m_layerTransition5;
    int m_layerTransition6;
    int m_layerTransition7;
    int m_layerTransition8;
    int m_layerTransition9;

    // App Timer properties
    bool m_timerState;
    bool m_timerCount;
    int m_timerMax;
    QString m_timerText;
    QString m_timerMenuLeft;
    QString m_timerMenuMiddle;
    QString m_timerMenuRight;

    // App Image properties
    QString m_imageSource;
    QString m_imageBgColor;
    int m_imageFillMode;  // Qt::AspectRatioMode enum value
    bool m_imageShowBg;
};

#endif // CONFIGMANAGER_H
