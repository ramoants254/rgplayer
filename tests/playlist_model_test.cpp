#include <QSignalSpy>
#include <QSettings>
#include <QTest>

#include "app/playlist_model.h"

class PlaylistModelTest final : public QObject
{
    Q_OBJECT

private slots:
    void init()
    {
        QSettings settings;
        settings.clear();
    }

    void addsUniqueFilesAndExposesRoles()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.addFile(QStringLiteral("/tmp/two.mkv"));

        QCOMPARE(model.rowCount(), 2);
        QCOMPARE(model.data(model.index(0), PlaylistModel::PathRole).toString(),
                 QStringLiteral("/tmp/one.mp4"));
        QCOMPARE(model.data(model.index(0), PlaylistModel::TitleRole).toString(),
                 QStringLiteral("one.mp4"));
    }

    void selectingEmitsPathAndUpdatesIndex()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        QSignalSpy playSpy(&model, &PlaylistModel::playRequested);

        model.playAt(0);

        QCOMPARE(model.currentIndex(), 0);
        QCOMPARE(playSpy.count(), 1);
        QCOMPARE(playSpy.at(0).at(0).toString(), QStringLiteral("/tmp/one.mp4"));
    }

    void removingResetsSelection()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.playAt(0);
        model.removeAt(0);

        QCOMPARE(model.rowCount(), 0);
        QCOMPARE(model.currentIndex(), -1);
    }
};

QTEST_MAIN(PlaylistModelTest)
#include "playlist_model_test.moc"
