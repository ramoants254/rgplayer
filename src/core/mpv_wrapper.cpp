#include "mpv_wrapper.h"

#include <QMetaObject>

#include <mpv/client.h>
#include <mpv/render.h>
#include <mpv/render_gl.h>

MpvWrapper::MpvWrapper(QObject *parent)
    : QObject(parent)
{
    handle_ = mpv_create();
    if (handle_ == nullptr) {
        setError(QStringLiteral("Could not create the mpv instance."));
        return;
    }

    // vo=libmpv tells mpv to use the render API only — no standalone window.
    // Without this mpv opens its own native video output window alongside ours.
    if (mpv_set_option_string(handle_, "vo", "libmpv") < 0
        || mpv_set_option_string(handle_, "hwdec", "auto-safe") < 0
        || mpv_set_option_string(handle_, "terminal", "no") < 0
        || mpv_set_option_string(handle_, "msg-level", "all=no") < 0) {
        setError(QStringLiteral("Could not configure the mpv instance."));
        return;
    }

    mpv_set_wakeup_callback(handle_, &MpvWrapper::wakeup, this);
    const int status = mpv_initialize(handle_);
    if (status < 0) {
        setError(QString::fromUtf8(mpv_error_string(status)));
        return;
    }

    mpv_observe_property(handle_, 1, "pause", MPV_FORMAT_FLAG);
    mpv_observe_property(handle_, 2, "volume", MPV_FORMAT_DOUBLE);
    mpv_observe_property(handle_, 3, "time-pos", MPV_FORMAT_DOUBLE);
    mpv_observe_property(handle_, 4, "duration", MPV_FORMAT_DOUBLE);
    mpv_observe_property(handle_, 5, "speed", MPV_FORMAT_DOUBLE);

    initialized_ = true;
    emit initializedChanged(true);
}

MpvWrapper::~MpvWrapper()
{
    freeRenderContext();
    if (handle_ == nullptr) {
        return;
    }

    mpv_set_wakeup_callback(handle_, nullptr, nullptr);
    mpv_terminate_destroy(handle_);
}

bool MpvWrapper::isInitialized() const
{
    return initialized_;
}

QString MpvWrapper::error() const
{
    return error_;
}

bool MpvWrapper::createRenderContext(MpvGetProcAddress getProcAddress,
                                     MpvRenderUpdateCallback updateCallback,
                                     void *callbackContext)
{
    if (!initialized_ || renderContext_ != nullptr || getProcAddress == nullptr) {
        return renderContext_ != nullptr;
    }

    mpv_opengl_init_params glParams{getProcAddress, nullptr};
    const char *apiType = MPV_RENDER_API_TYPE_OPENGL;
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_API_TYPE, const_cast<char *>(apiType)},
        {MPV_RENDER_PARAM_OPENGL_INIT_PARAMS, &glParams},
        {MPV_RENDER_PARAM_INVALID, nullptr},
    };

    const int status = mpv_render_context_create(&renderContext_, handle_, params);
    if (status < 0) {
        setError(QString::fromUtf8(mpv_error_string(status)));
        return false;
    }

    mpv_render_context_set_update_callback(renderContext_, updateCallback, callbackContext);
    return true;
}

void MpvWrapper::freeRenderContext()
{
    if (renderContext_ == nullptr) {
        return;
    }

    mpv_render_context_set_update_callback(renderContext_, nullptr, nullptr);
    mpv_render_context_free(renderContext_);
    renderContext_ = nullptr;
}

bool MpvWrapper::renderToFramebuffer(unsigned int framebuffer, int width, int height)
{
    if (renderContext_ == nullptr || width <= 0 || height <= 0) {
        return false;
    }

    mpv_opengl_fbo fbo{static_cast<int>(framebuffer), width, height, 0};
    int flipY = 0;
    mpv_render_param params[] = {
        {MPV_RENDER_PARAM_OPENGL_FBO, &fbo},
        {MPV_RENDER_PARAM_FLIP_Y, &flipY},
        {MPV_RENDER_PARAM_INVALID, nullptr},
    };

    return mpv_render_context_render(renderContext_, params) >= 0;
}

void MpvWrapper::openFile(const QString &path)
{
    if (!initialized_ || path.isEmpty()) {
        return;
    }

    const QByteArray encodedPath = path.toUtf8();
    const char *arguments[] = {"loadfile", encodedPath.constData(), "replace", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::play()
{
    const char *arguments[] = {"set", "pause", "no", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::pause()
{
    const char *arguments[] = {"set", "pause", "yes", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::togglePause()
{
    const char *arguments[] = {"cycle", "pause", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setVolume(double volume)
{
    const QByteArray encodedVolume = QByteArray::number(volume, 'f', 2);
    const char *arguments[] = {"set", "volume", encodedVolume.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::seek(double position)
{
    const QByteArray encodedPosition = QByteArray::number(qMax(0.0, position), 'f', 3);
    const char *arguments[] = {"seek", encodedPosition.constData(), "absolute", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setSpeed(double speed)
{
    const QByteArray encodedSpeed = QByteArray::number(qBound(0.25, speed, 4.0), 'f', 2);
    const char *arguments[] = {"set", "speed", encodedSpeed.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::frameStep()
{
    const char *arguments[] = {"frame-step", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setLoopPoint(char point, double position)
{
    const char property[] = {'a', 'b', '-', point, '\0'};
    const QByteArray encodedPosition = QByteArray::number(qMax(0.0, position), 'f', 3);
    const char *arguments[] = {"set", property, encodedPosition.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::clearLoop()
{
    const char *clearA[] = {"set", "ab-loop-a", "no", nullptr};
    const char *clearB[] = {"set", "ab-loop-b", "no", nullptr};
    sendCommand(clearA);
    sendCommand(clearB);
}

void MpvWrapper::cycleAudioTrack()
{
    const char *arguments[] = {"cycle", "audio", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::cycleSubtitleTrack()
{
    const char *arguments[] = {"cycle", "sub", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::previousChapter()
{
    const char *arguments[] = {"add", "chapter", "-1", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::nextChapter()
{
    const char *arguments[] = {"add", "chapter", "1", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setSubtitleDelay(double seconds)
{
    const QByteArray value = QByteArray::number(seconds, 'f', 3);
    const char *arguments[] = {"set", "sub-delay", value.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setSubtitleScale(double scale)
{
    const QByteArray value = QByteArray::number(qBound(0.5, scale, 3.0), 'f', 2);
    const char *arguments[] = {"set", "sub-scale", value.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setAudioDelay(double seconds)
{
    const QByteArray value = QByteArray::number(seconds, 'f', 3);
    const char *arguments[] = {"set", "audio-delay", value.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setVideoProperty(const char *property, double value)
{
    const QByteArray encodedValue = QByteArray::number(value, 'f', 2);
    const char *arguments[] = {"set", property, encodedValue.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::loadSubtitle(const QString &path)
{
    const QByteArray encodedPath = path.toUtf8();
    const char *arguments[] = {"sub-add", encodedPath.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::screenshot()
{
    const char *arguments[] = {"screenshot", "video", nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setSubtitleOption(const char *property, const QString &value)
{
    const QByteArray encodedValue = value.toUtf8();
    const char *arguments[] = {"set", property, encodedValue.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setAudioFilter(const QString &filter)
{
    const QByteArray encodedFilter = filter.toUtf8();
    const char *arguments[] = {"af", "set", encodedFilter.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::setVideoFilter(const QString &filter)
{
    const QByteArray encodedFilter = filter.toUtf8();
    const char *arguments[] = {"vf", "set", encodedFilter.constData(), nullptr};
    sendCommand(arguments);
}

void MpvWrapper::processEvents()
{
    if (handle_ == nullptr) {
        return;
    }

    while (true) {
        mpv_event *event = mpv_wait_event(handle_, 0);
        if (event == nullptr || event->event_id == MPV_EVENT_NONE) {
            return;
        }

        if (event->event_id == MPV_EVENT_START_FILE) {
            emit fileStarted(QString());
        } else if (event->event_id == MPV_EVENT_FILE_LOADED) {
            emit fileLoaded();
        } else if (event->event_id == MPV_EVENT_PROPERTY_CHANGE) {
            const auto *property = static_cast<const mpv_event_property *>(event->data);
            if (property == nullptr || property->data == nullptr) {
                continue;
            }

            if (property->format == MPV_FORMAT_FLAG && qstrcmp(property->name, "pause") == 0) {
                emit pauseChanged(*static_cast<const int *>(property->data) != 0);
            } else if (property->format == MPV_FORMAT_DOUBLE
                       && qstrcmp(property->name, "volume") == 0) {
                emit volumeChanged(*static_cast<const double *>(property->data));
            } else if (property->format == MPV_FORMAT_DOUBLE
                       && qstrcmp(property->name, "time-pos") == 0) {
                emit positionChanged(*static_cast<const double *>(property->data));
            } else if (property->format == MPV_FORMAT_DOUBLE
                       && qstrcmp(property->name, "duration") == 0) {
                emit durationChanged(*static_cast<const double *>(property->data));
            } else if (property->format == MPV_FORMAT_DOUBLE
                       && qstrcmp(property->name, "speed") == 0) {
                emit speedChanged(*static_cast<const double *>(property->data));
            }
        } else if (event->event_id == MPV_EVENT_END_FILE && event->error < 0) {
            setError(QString::fromUtf8(mpv_error_string(event->error)));
        }
    }
}

void MpvWrapper::wakeup(void *context)
{
    auto *wrapper = static_cast<MpvWrapper *>(context);
    QMetaObject::invokeMethod(wrapper, &MpvWrapper::processEvents, Qt::QueuedConnection);
}

bool MpvWrapper::sendCommand(const char **arguments)
{
    if (!initialized_) {
        return false;
    }

    const int status = mpv_command(handle_, arguments);
    if (status < 0) {
        setError(QString::fromUtf8(mpv_error_string(status)));
        return false;
    }
    return true;
}

void MpvWrapper::setError(const QString &message)
{
    error_ = message;
    emit errorChanged(error_);
}
