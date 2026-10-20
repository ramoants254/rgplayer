#include "mpris_service.h"

#include <QDBusConnection>

#include "app/player_controller.h"

MprisService::MprisService(PlayerController *controller, QObject *parent)
    : QObject(parent)
    , controller_(controller)
{
    if (controller_ == nullptr) {
        return;
    }

    connect(controller_, &PlayerController::pausedChanged, this, &MprisService::playbackStatusChanged);
    connect(controller_, &PlayerController::positionChanged, this, &MprisService::positionChanged);
    connect(controller_, &PlayerController::volumeChanged, this, &MprisService::volumeChanged);
    connect(controller_, &PlayerController::speedChanged, this, &MprisService::rateChanged);
}

bool MprisService::registerOnSessionBus()
{
    auto bus = QDBusConnection::sessionBus();
    if (!bus.isConnected()) {
        return false;
    }

    if (!bus.registerService(QStringLiteral("org.mpris.MediaPlayer2.rgplayer"))) {
        return false;
    }

    registered_ = bus.registerObject(QStringLiteral("/org/mpris/MediaPlayer2"), this,
                                      QDBusConnection::ExportAllSlots
                                          | QDBusConnection::ExportAllSignals
                                          | QDBusConnection::ExportAllProperties);
    return registered_;
}

QString MprisService::playbackStatus() const
{
    return controller_ != nullptr && !controller_->paused() ? QStringLiteral("Playing")
                                                              : QStringLiteral("Paused");
}

double MprisService::volume() const
{
    return controller_ == nullptr ? 0.0 : controller_->volume() / 100.0;
}

void MprisService::setVolume(double volume)
{
    if (controller_ != nullptr) {
        controller_->setVolume(volume * 100.0);
    }
}

double MprisService::rate() const
{
    return controller_ == nullptr ? 1.0 : controller_->speed();
}

void MprisService::setRate(double rate)
{
    if (controller_ != nullptr) {
        controller_->setSpeed(rate);
    }
}

qlonglong MprisService::position() const
{
    return controller_ == nullptr ? 0 : static_cast<qlonglong>(controller_->position() * 1000000.0);
}

void MprisService::Play()
{
    if (controller_ != nullptr) {
        controller_->play();
    }
}

void MprisService::Pause()
{
    if (controller_ != nullptr) {
        controller_->pause();
    }
}

void MprisService::PlayPause()
{
    if (controller_ != nullptr) {
        controller_->togglePause();
    }
}

void MprisService::Stop()
{
    if (controller_ != nullptr) {
        controller_->pause();
    }
}

void MprisService::Next()
{
    if (controller_ != nullptr) {
        controller_->nextChapter();
    }
}

void MprisService::Previous()
{
    if (controller_ != nullptr) {
        controller_->previousChapter();
    }
}

void MprisService::Seek(qlonglong offset)
{
    if (controller_ != nullptr) {
        controller_->seek(controller_->position() + static_cast<double>(offset) / 1000000.0);
    }
}
