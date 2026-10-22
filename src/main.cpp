#include <QCommandLineParser>
#include <QFileInfo>
#include <QGuiApplication>
#include <QIcon>
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
    app.setWindowIcon(QIcon::fromTheme(QStringLiteral("rgplayer"),
                                       QIcon(QStringLiteral(":/qt/qml/Rgplayer/resources/rgplayer.svg"))));

    QCommandLineParser parser;
    parser.setApplicationDescription(QStringLiteral("rgplayer - Fast, modern Linux media player"));
    parser.addHelpOption();
    parser.addVersionOption();
    parser.addPositionalArgument(QStringLiteral("media"), QStringLiteral("Media file or folder to open and play."));
    parser.process(app);

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

    const QStringList positionalArgs = parser.positionalArguments();
    for (const QString &arg : positionalArgs) {
        if (!arg.startsWith(QLatin1Char('-')) && QFileInfo::exists(arg)) {
            playlistModel.addFile(arg);
        }
    }
    if (!positionalArgs.isEmpty()) {
        const QString firstFile = positionalArgs.first();
        if (!firstFile.startsWith(QLatin1Char('-')) && QFileInfo::exists(firstFile)) {
            playerController.openFile(firstFile);
        }
    }

    return app.exec();
}
