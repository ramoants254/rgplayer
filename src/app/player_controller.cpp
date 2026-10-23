#include "player_controller.h"

#include <QDir>
#include <QFile>
#include <QSettings>
#include <QTimer>
#include <QUrl>

#include "core/mpv_wrapper.h"

namespace {
QString resumeKeyForPath(const QString &filePath)
{
    return QStringLiteral("resume/%1").arg(QString::fromUtf8(QUrl::toPercentEncoding(filePath)));
}
} // namespace

PlayerController::PlayerController(MpvWrapper *mpv, QObject *parent)
    : QObject(parent)
    , mpv_(mpv)
    , available_(mpv != nullptr && mpv->isInitialized())
{
    if (mpv_ == nullptr) {
        error_ = QStringLiteral("Playback core is unavailable.");
        return;
    }

    connect(mpv_, &MpvWrapper::initializedChanged, this, [this](bool initialized) {
        available_ = initialized;
        emit availableChanged();
    });
    connect(mpv_, &MpvWrapper::errorChanged, this, [this](const QString &message) {
        error_ = message;
        emit errorChanged();
    });
    connect(mpv_, &MpvWrapper::pauseChanged, this, [this](bool paused) {
        paused_ = paused;
        emit pausedChanged();
    });
    connect(mpv_, &MpvWrapper::volumeChanged, this, [this](double volume) {
        volume_ = volume;
        emit volumeChanged();
    });
    connect(mpv_, &MpvWrapper::positionChanged, this, [this](double position) {
        position_ = position;
        emit positionChanged();
        if (resumeTimer_ != nullptr) {
            resumeTimer_->start();
        }
    });
    connect(mpv_, &MpvWrapper::durationChanged, this, [this](double duration) {
        duration_ = duration;
        emit durationChanged();
    });
    connect(mpv_, &MpvWrapper::speedChanged, this, [this](double speed) {
        speed_ = speed;
        emit speedChanged();
    });

    connect(mpv_, &MpvWrapper::fileLoaded, this, [this] {
        if (currentFile_.isEmpty()) {
            return;
        }
        const double resumePosition = QSettings().value(
            resumeKeyForPath(currentFile_), 0.0).toDouble();
        if (resumePosition > 1.0) {
            mpv_->seek(resumePosition);
        }
    });

    resumeTimer_ = new QTimer(this);
    resumeTimer_->setSingleShot(true);
    resumeTimer_->setInterval(500);
    connect(resumeTimer_, &QTimer::timeout, this, [this] {
        if (currentFile_.isEmpty()) {
            return;
        }
        QSettings settings;
        if (duration_ > 10.0 && position_ >= duration_ - 5.0) {
            settings.remove(resumeKeyForPath(currentFile_));
        } else if (position_ > 1.0) {
            settings.setValue(resumeKeyForPath(currentFile_), position_);
        }
    });

    if (!available_) {
        error_ = mpv_->error();
    }
}

bool PlayerController::available() const
{
    return available_;
}

bool PlayerController::paused() const
{
    return paused_;
}

double PlayerController::volume() const
{
    return volume_;
}

double PlayerController::position() const
{
    return position_;
}

double PlayerController::duration() const
{
    return duration_;
}

double PlayerController::speed() const
{
    return speed_;
}

QString PlayerController::currentFile() const
{
    return currentFile_;
}

QString PlayerController::error() const
{
    return error_;
}

MpvWrapper *PlayerController::backend() const
{
    return mpv_;
}

void PlayerController::openFile(const QString &rawPath)
{
    QString path = rawPath.trimmed();
    if (path.isEmpty()) {
        return;
    }
    if ((path.startsWith('"') && path.endsWith('"')) || (path.startsWith('\'') && path.endsWith('\''))) {
        path = path.mid(1, path.length() - 2);
    }
    if (path.startsWith(QLatin1String("file:///"))) {
        path = path.mid(7);
    } else if (path.startsWith(QLatin1String("file://"))) {
        path = path.mid(7);
    }
    if (path.startsWith(QLatin1String("~/"))) {
        path = QDir::homePath() + path.mid(1);
    }
    path = QUrl::fromPercentEncoding(path.toUtf8());

    if (currentFile_ != path) {
        currentFile_ = path;
        emit currentFileChanged();
    }

    QSettings settings;
    QStringList recents = settings.value(QStringLiteral("recent/history")).toStringList();
    recents.removeAll(path);
    recents.prepend(path);
    while (recents.size() > 15) {
        recents.removeLast();
    }
    settings.setValue(QStringLiteral("recent/history"), recents);
    emit recentFilesChanged();

    if (mpv_ != nullptr) {
        mpv_->openFile(path);
    }
}

void PlayerController::play()
{
    if (mpv_ != nullptr) {
        mpv_->play();
    }
}

void PlayerController::pause()
{
    if (mpv_ != nullptr) {
        mpv_->pause();
    }
}

void PlayerController::togglePause()
{
    if (mpv_ != nullptr) {
        mpv_->togglePause();
    }
}

void PlayerController::seek(double position)
{
    if (mpv_ != nullptr) {
        mpv_->seek(position);
    }
}

void PlayerController::frameStep()
{
    if (mpv_ != nullptr) {
        mpv_->frameStep();
    }
}

void PlayerController::setLoopStart()
{
    if (mpv_ != nullptr) {
        mpv_->setLoopPoint('a', position_);
    }
}

void PlayerController::setLoopEnd()
{
    if (mpv_ != nullptr) {
        mpv_->setLoopPoint('b', position_);
    }
}

void PlayerController::clearLoop()
{
    if (mpv_ != nullptr) {
        mpv_->clearLoop();
    }
}

void PlayerController::cycleAudioTrack()
{
    if (mpv_ != nullptr) {
        mpv_->cycleAudioTrack();
    }
}

void PlayerController::cycleSubtitleTrack()
{
    if (mpv_ != nullptr) {
        mpv_->cycleSubtitleTrack();
    }
}

void PlayerController::previousChapter()
{
    if (mpv_ != nullptr) {
        mpv_->previousChapter();
    }
}

void PlayerController::nextChapter()
{
    if (mpv_ != nullptr) {
        mpv_->nextChapter();
    }
}

void PlayerController::setSubtitleDelay(double seconds)
{
    if (mpv_ != nullptr) {
        mpv_->setSubtitleDelay(seconds);
    }
}

void PlayerController::setSubtitleScale(double scale)
{
    if (mpv_ != nullptr) {
        mpv_->setSubtitleScale(scale);
    }
}

void PlayerController::setAudioDelay(double seconds)
{
    if (mpv_ != nullptr) {
        mpv_->setAudioDelay(seconds);
    }
}

void PlayerController::setBrightness(double value)
{
    if (mpv_ != nullptr) {
        mpv_->setVideoProperty("brightness", value);
    }
}

void PlayerController::setContrast(double value)
{
    if (mpv_ != nullptr) {
        mpv_->setVideoProperty("contrast", value);
    }
}

void PlayerController::setSaturation(double value)
{
    if (mpv_ != nullptr) {
        mpv_->setVideoProperty("saturation", value);
    }
}

void PlayerController::loadSubtitle(const QString &path)
{
    if (mpv_ != nullptr && !path.isEmpty()) {
        mpv_->loadSubtitle(path);
    }
}

void PlayerController::screenshot()
{
    if (mpv_ != nullptr) {
        mpv_->screenshot();
    }
}

void PlayerController::setSubtitleOverride(bool enabled)
{
    if (mpv_ != nullptr) {
        mpv_->setSubtitleOption("sub-ass-override", enabled ? QStringLiteral("force")
                                                               : QStringLiteral("no"));
    }
}

void PlayerController::setSubtitleFontSize(double size)
{
    if (mpv_ != nullptr) {
        mpv_->setSubtitleOption("sub-font-size", QString::number(qBound(8.0, size, 96.0), 'f', 1));
    }
}

void PlayerController::setSubtitleCodepage(const QString &codepage)
{
    if (mpv_ != nullptr) {
        mpv_->setSubtitleOption("sub-codepage", codepage);
    }
}

void PlayerController::setEqualizerPreset(const QString &preset)
{
    if (mpv_ != nullptr) {
        mpv_->setAudioFilter(preset);
    }
}

void PlayerController::setNormalizationEnabled(bool enabled)
{
    if (mpv_ != nullptr) {
        mpv_->setAudioFilter(enabled ? QStringLiteral("loudnorm") : QString());
    }
}

void PlayerController::setVideoFilterPreset(const QString &preset)
{
    if (mpv_ != nullptr) {
        mpv_->setVideoFilter(preset);
    }
}

void PlayerController::setVolume(double volume)
{
    volume_ = qBound(0.0, volume, 100.0);
    emit volumeChanged();
    if (mpv_ != nullptr) {
        mpv_->setVolume(volume_);
    }
}

void PlayerController::setSpeed(double speed)
{
    speed_ = qBound(0.25, speed, 4.0);
    emit speedChanged();
    if (mpv_ != nullptr) {
        mpv_->setSpeed(speed_);
    }
}

void PlayerController::setAspectRatio(const QString &ratio)
{
    if (mpv_ != nullptr) {
        // ratio values: "-1" (auto/original), "16:9", "4:3", "2.35:1"
        mpv_->setStringProperty("video-aspect-override", ratio);
    }
}

QVariantMap PlayerController::mediaInfo() const
{
    QVariantMap info = (mpv_ != nullptr) ? mpv_->mediaInfo() : QVariantMap();
    info.insert(QStringLiteral("filePath"), currentFile_);
    info.insert(QStringLiteral("fileName"),
                currentFile_.isEmpty()
                    ? QString()
                    : currentFile_.mid(currentFile_.lastIndexOf(QLatin1Char('/')) + 1));
    info.insert(QStringLiteral("duration"), duration_);
    return info;
}

QStringList PlayerController::recentFiles() const
{
    QSettings settings;
    const QStringList recents = settings.value(QStringLiteral("recent/history")).toStringList();
    QStringList result;
    result.reserve(recents.size());
    for (const auto &filePath : recents) {
        if (QFile::exists(filePath)) {
            result.append(filePath);
        }
    }
    return result;
}
