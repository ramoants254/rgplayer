#include <QGuiApplication>
#include <QQmlContext>
#include <QQmlApplicationEngine>
#include <QQuickWindow>

#include <clocale>

#include "app/player_controller.h"
#include "app/playlist_model.h"
#include "app/mpris_service.h"
#include "app/thumbnail_service.h"
#include "core/mpv_wrapper.h"

int main(int argc, char *argv[])
{
    // QQuickFramebufferObject requires the OpenGL backend.
    // This must be called before QGuiApplication is constructed.
    QQuickWindow::setGraphicsApi(QSGRendererInterface::OpenGL);

    QGuiApplication app(argc, argv);
    std::setlocale(LC_NUMERIC, "C");
    app.setApplicationName(QStringLiteral("rgplayer"));
    app.setApplicationVersion(QStringLiteral("0.1.0"));
    app.setOrganizationName(QStringLiteral("rgplayer"));
    app.setOrganizationDomain(QStringLiteral("rgplayer.local"));

    MpvWrapper mpv;
    PlayerController playerController(&mpv);
    PlaylistModel playlistModel;
    ThumbnailService thumbnailService;
    MprisService mprisService(&playerController);
    mprisService.registerOnSessionBus();
    QObject::connect(&playlistModel, &PlaylistModel::playRequested, &playerController,
                     &PlayerController::openFile);

    QQmlApplicationEngine engine;
    engine.rootContext()->setContextProperty(QStringLiteral("playerController"), &playerController);
    engine.rootContext()->setContextProperty(QStringLiteral("playlistModel"), &playlistModel);
    engine.rootContext()->setContextProperty(QStringLiteral("thumbnailService"), &thumbnailService);

    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        [] { QCoreApplication::exit(EXIT_FAILURE); },
        Qt::QueuedConnection);

    engine.loadFromModule(QStringLiteral("Rgplayer"), QStringLiteral("Main"));
    if (argc > 1) {
        playlistModel.addFile(QString::fromLocal8Bit(argv[1]));
        playerController.openFile(QString::fromLocal8Bit(argv[1]));
    }
    return app.exec();
}
