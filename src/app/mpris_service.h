#pragma once

#include <QObject>

class PlayerController;

class MprisService final : public QObject
{
    Q_OBJECT
    Q_CLASSINFO("D-Bus Interface", "org.mpris.MediaPlayer2.Player")
    Q_PROPERTY(QString PlaybackStatus READ playbackStatus NOTIFY playbackStatusChanged)
    Q_PROPERTY(double Volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(double Rate READ rate WRITE setRate NOTIFY rateChanged)
    Q_PROPERTY(qlonglong Position READ position NOTIFY positionChanged)

public:
    explicit MprisService(PlayerController *controller, QObject *parent = nullptr);
    bool registerOnSessionBus();

    QString playbackStatus() const;
    double volume() const;
    void setVolume(double volume);
    double rate() const;
    void setRate(double rate);
    qlonglong position() const;

public slots:
    void Play();
    void Pause();
    void PlayPause();
    void Stop();
    void Next();
    void Previous();
    void Seek(qlonglong offset);

signals:
    void playbackStatusChanged();
    void volumeChanged();
    void rateChanged();
    void positionChanged();

private:
    PlayerController *controller_ = nullptr;
    bool registered_ = false;
};
