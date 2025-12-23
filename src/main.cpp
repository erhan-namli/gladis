#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QDir>
#include <QFile>
#include "datamanager.h"
#include "configmanager.h"
#include "fileiohelper.h"

int main(int argc, char *argv[])
{
    // Enable vsync for smooth animations (critical for Raspberry Pi)
    QSurfaceFormat format;
    format.setSwapInterval(1);  // 1 = vsync enabled, 0 = vsync disabled
    QSurfaceFormat::setDefaultFormat(format);

    // Enable high DPI scaling
    QGuiApplication::setHighDpiScaleFactorRoundingPolicy(Qt::HighDpiScaleFactorRoundingPolicy::PassThrough);

    QGuiApplication app(argc, argv);

    // Set application info
    app.setOrganizationName("GameLab");
    app.setOrganizationDomain("gamelab.com");
    app.setApplicationName("GLADIS");

    // Create data manager
    DataManager dataManager;

    // Create config manager
    ConfigManager configManager;

    // Create file I/O helper
    FileIOHelper fileIOHelper;

    // Set data path and config path based on deployment location
    // Check if ~/app/vars exists (Pi deployment), otherwise use welcome-data (local dev)
    QString piDataPath = QDir::homePath() + "/app/vars";
    QString piConfigPath = "/dev/shm/app/gladis.ini";
    QString localDataPath = "welcome-data";
    QString localConfigPath = "gladis.ini";
    QString defaultConfigPath = "gladis.ini";  // Default fallback

    if (QDir(piDataPath).exists()) {
        qDebug() << "Running on Pi - using data path:" << piDataPath;
        dataManager.setDataPath(piDataPath);

        // Try Pi config first, fallback to default if not present
        if (QFile::exists(piConfigPath)) {
            qDebug() << "Using Pi config:" << piConfigPath;
            configManager.setConfigPath(piConfigPath);
        } else {
            qDebug() << "Pi config not found, falling back to default:" << defaultConfigPath;
            configManager.setConfigPath(defaultConfigPath);
        }
    } else {
        qDebug() << "Running locally - using data path:" << localDataPath;
        dataManager.setDataPath(localDataPath);
        configManager.setConfigPath(localConfigPath);
    }

    // Create QML engine
    QQmlApplicationEngine engine;

    // Expose DataManager, ConfigManager, and FileIOHelper to QML
    engine.rootContext()->setContextProperty("dataManager", &dataManager);
    engine.rootContext()->setContextProperty("configManager", &configManager);
    engine.rootContext()->setContextProperty("fileIO", &fileIOHelper);

    // Load main QML file
    const QUrl url(QStringLiteral("qrc:/main.qml"));
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreated,
        &app,
        [url](QObject *obj, const QUrl &objUrl) {
            if (!obj && url == objUrl) {
                QCoreApplication::exit(-1);
            }
        },
        Qt::QueuedConnection);

    engine.load(url);

    if (engine.rootObjects().isEmpty()) {
        return -1;
    }

    // Force vsync on the window after it's created (critical for Pi5)
    QObject *rootObject = engine.rootObjects().first();
    QQuickWindow *window = qobject_cast<QQuickWindow *>(rootObject);
    if (window) {
        qDebug() << "Setting vsync on QQuickWindow...";

        // Set the format with swap interval on the actual window
        QSurfaceFormat windowFormat = window->format();
        windowFormat.setSwapInterval(1);
        window->setFormat(windowFormat);

        qDebug() << "Window format swap interval:" << window->format().swapInterval();
    } else {
        qDebug() << "Warning: Could not cast root object to QQuickWindow";
    }

    return app.exec();
}
