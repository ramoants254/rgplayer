#include <QFile>
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
        QFile f1(QStringLiteral("/tmp/one.mp4"));
        if (f1.open(QIODevice::WriteOnly)) {
            f1.write("mock");
            f1.close();
        }
        QFile f2(QStringLiteral("/tmp/two.mkv"));
        if (f2.open(QIODevice::WriteOnly)) {
            f2.write("mock");
            f2.close();
        }
        QFile f3(QStringLiteral("/tmp/three.mp4"));
        if (f3.open(QIODevice::WriteOnly)) {
            f3.write("mock");
            f3.close();
        }
    }

    void cleanup()
    {
        QFile::remove(QStringLiteral("/tmp/one.mp4"));
        QFile::remove(QStringLiteral("/tmp/two.mkv"));
        QFile::remove(QStringLiteral("/tmp/three.mp4"));
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

    void navigationCyclesTracks()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.addFile(QStringLiteral("/tmp/two.mkv"));

        QSignalSpy playSpy(&model, &PlaylistModel::playRequested);
        model.playAt(0);
        QCOMPARE(model.currentIndex(), 0);

        model.playNext();
        QCOMPARE(model.currentIndex(), 1);
        QCOMPARE(playSpy.last().at(0).toString(), QStringLiteral("/tmp/two.mkv"));

        model.playPrevious();
        QCOMPARE(model.currentIndex(), 0);
        QCOMPARE(playSpy.last().at(0).toString(), QStringLiteral("/tmp/one.mp4"));
    }

    void clearEmptiesListAndResetsIndex()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.addFile(QStringLiteral("/tmp/two.mkv"));
        model.playAt(1);

        QCOMPARE(model.count(), 2);
        QCOMPARE(model.currentIndex(), 1);

        model.clear();
        QCOMPARE(model.count(), 0);
        QCOMPARE(model.currentIndex(), -1);
    }

    void moveTracksUpdatesOrderAndCurrentIndex()
    {
        PlaylistModel model;
        model.addFile(QStringLiteral("/tmp/one.mp4"));
        model.addFile(QStringLiteral("/tmp/two.mkv"));
        model.addFile(QStringLiteral("/tmp/three.mp4"));
        model.playAt(0); // Playing one.mp4 at 0

        // Move one.mp4 from 0 to 2 -> order becomes two, three, one
        model.move(0, 2);
        QCOMPARE(model.getPath(0), QStringLiteral("/tmp/two.mkv"));
        QCOMPARE(model.getPath(1), QStringLiteral("/tmp/three.mp4"));
        QCOMPARE(model.getPath(2), QStringLiteral("/tmp/one.mp4"));
        // currentIndex should follow one.mp4 to 2
        QCOMPARE(model.currentIndex(), 2);

        // Move three.mp4 from 1 to 0 -> order becomes three, two, one
        model.move(1, 0);
        QCOMPARE(model.getPath(0), QStringLiteral("/tmp/three.mp4"));
        QCOMPARE(model.getPath(1), QStringLiteral("/tmp/two.mkv"));
        QCOMPARE(model.getPath(2), QStringLiteral("/tmp/one.mp4"));
        // one.mp4 was at 2, didn't move relative to the swap above it
        QCOMPARE(model.currentIndex(), 2);

        // Move three.mp4 from 0 to 2 -> order becomes two, one, three
        // currentIndex (one.mp4 at 2) should shift down to 1
        model.move(0, 2);
        QCOMPARE(model.getPath(0), QStringLiteral("/tmp/two.mkv"));
        QCOMPARE(model.getPath(1), QStringLiteral("/tmp/one.mp4"));
        QCOMPARE(model.getPath(2), QStringLiteral("/tmp/three.mp4"));
        QCOMPARE(model.currentIndex(), 1);
    }
};

QTEST_MAIN(PlaylistModelTest)
#include "playlist_model_test.moc"
