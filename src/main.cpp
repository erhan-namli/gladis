#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlContext>
#include <QQuickWindow>
#include <QSurfaceFormat>
#include <QDir>
#include <QFile>
#include "datamanager.h"

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

    // Set data path based on deployment location
    // Check if ~/app/vars exists (Pi deployment), otherwise use welcome-data (local dev)
    QString piDataPath = QDir::homePath() + "/app/vars";
    QString localDataPath = "welcome-data";

    if (QDir(piDataPath).exists()) {
        qDebug() << "Running on Pi - using data path:" << piDataPath;
        dataManager.setDataPath(piDataPath);
    } else {
        qDebug() << "Running locally - using data path:" << localDataPath;
        dataManager.setDataPath(localDataPath);
    }

    // Create QML engine
    QQmlApplicationEngine engine;

    // Expose DataManager to QML
    engine.rootContext()->setContextProperty("dataManager", &dataManager);

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
