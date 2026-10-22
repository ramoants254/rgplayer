#pragma once

#include <QObject>
#include <QString>

struct mpv_handle;
struct mpv_render_context;

using MpvGetProcAddress = void *(*)(void *ctx, const char *name);
using MpvRenderUpdateCallback = void (*)(void *ctx);

class MpvWrapper final : public QObject
{
    Q_OBJECT

public:
    explicit MpvWrapper(QObject *parent = nullptr);
    ~MpvWrapper() override;

    bool isInitialized() const;
    QString error() const;
    bool createRenderContext(MpvGetProcAddress getProcAddress,
                             MpvRenderUpdateCallback updateCallback,
                             void *callbackContext);
    void freeRenderContext();
    bool renderToFramebuffer(unsigned int framebuffer, int width, int height);

public slots:
    void openFile(const QString &path);
    void play();
    void pause();
    void togglePause();
    void setVolume(double volume);
    void seek(double position);
    void setSpeed(double speed);
    void frameStep();
    void setLoopPoint(char point, double position);
    void clearLoop();
    void cycleAudioTrack();
    void cycleSubtitleTrack();
    void previousChapter();
    void nextChapter();
    void setSubtitleDelay(double seconds);
    void setSubtitleScale(double scale);
    void setAudioDelay(double seconds);
    void setVideoProperty(const char *property, double value);
    void loadSubtitle(const QString &path);
    void screenshot();
    void setSubtitleOption(const char *property, const QString &value);
    void setAudioFilter(const QString &filter);
    void setVideoFilter(const QString &filter);
    void setStringProperty(const char *property, const QString &value);

signals:
    void initializedChanged(bool initialized);
    void errorChanged(const QString &message);
    void fileStarted(const QString &path);
    void fileLoaded();
    void pauseChanged(bool paused);
    void volumeChanged(double volume);
    void positionChanged(double position);
    void durationChanged(double duration);
    void speedChanged(double speed);

private slots:
    void processEvents();

private:
    static void wakeup(void *context);
    bool sendCommand(const char **arguments);
    void setError(const QString &message);

    mpv_handle *handle_ = nullptr;
    mpv_render_context *renderContext_ = nullptr;
    QString error_;
    bool initialized_ = false;
};
