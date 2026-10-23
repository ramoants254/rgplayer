#pragma once

#include <QObject>
#include <QString>
#include <QVariantMap>

class QTimer;

class MpvWrapper;

class PlayerController final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(bool available READ available NOTIFY availableChanged)
    Q_PROPERTY(bool paused READ paused NOTIFY pausedChanged)
    Q_PROPERTY(double volume READ volume WRITE setVolume NOTIFY volumeChanged)
    Q_PROPERTY(double position READ position NOTIFY positionChanged)
    Q_PROPERTY(double duration READ duration NOTIFY durationChanged)
    Q_PROPERTY(double speed READ speed WRITE setSpeed NOTIFY speedChanged)
    Q_PROPERTY(QString currentFile READ currentFile NOTIFY currentFileChanged)
    Q_PROPERTY(QStringList recentFiles READ recentFiles NOTIFY recentFilesChanged)
    Q_PROPERTY(QString error READ error NOTIFY errorChanged)

public:
    explicit PlayerController(MpvWrapper *mpv, QObject *parent = nullptr);

    bool available() const;
    bool paused() const;
    double volume() const;
    double position() const;
    double duration() const;
    double speed() const;
    QString currentFile() const;
    QStringList recentFiles() const;
    QString error() const;
    MpvWrapper *backend() const;

    Q_INVOKABLE void openFile(const QString &path);
    Q_INVOKABLE void play();
    Q_INVOKABLE void pause();
    Q_INVOKABLE void togglePause();
    Q_INVOKABLE void seek(double position);
    Q_INVOKABLE void frameStep();
    Q_INVOKABLE void setLoopStart();
    Q_INVOKABLE void setLoopEnd();
    Q_INVOKABLE void clearLoop();
    Q_INVOKABLE void cycleAudioTrack();
    Q_INVOKABLE void cycleSubtitleTrack();
    Q_INVOKABLE void previousChapter();
    Q_INVOKABLE void nextChapter();
    Q_INVOKABLE void setSubtitleDelay(double seconds);
    Q_INVOKABLE void setSubtitleScale(double scale);
    Q_INVOKABLE void setAudioDelay(double seconds);
    Q_INVOKABLE void setBrightness(double value);
    Q_INVOKABLE void setContrast(double value);
    Q_INVOKABLE void setSaturation(double value);
    Q_INVOKABLE void loadSubtitle(const QString &path);
    Q_INVOKABLE void screenshot();
    Q_INVOKABLE void setSubtitleOverride(bool enabled);
    Q_INVOKABLE void setSubtitleFontSize(double size);
    Q_INVOKABLE void setSubtitleCodepage(const QString &codepage);
    Q_INVOKABLE void setEqualizerPreset(const QString &preset);
    Q_INVOKABLE void setNormalizationEnabled(bool enabled);
    Q_INVOKABLE void setVideoFilterPreset(const QString &preset);
    Q_INVOKABLE void setAspectRatio(const QString &ratio);
    Q_INVOKABLE QVariantMap mediaInfo() const;
    void setVolume(double volume);
    void setSpeed(double speed);

signals:
    void availableChanged();
    void pausedChanged();
    void volumeChanged();
    void positionChanged();
    void durationChanged();
    void speedChanged();
    void currentFileChanged();
    void recentFilesChanged();
    void errorChanged();

private:
    MpvWrapper *mpv_ = nullptr;
    bool available_ = false;
    bool paused_ = true;
    double volume_ = 100.0;
    double position_ = 0.0;
    double duration_ = 0.0;
    double speed_ = 1.0;
    QString currentFile_;
    QTimer *resumeTimer_ = nullptr;
    QString error_;
};
