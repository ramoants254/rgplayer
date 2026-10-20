#include "thumbnail_service.h"

#include <QDir>
#include <QProcess>
#include <QStandardPaths>

ThumbnailService::ThumbnailService(QObject *parent)
    : QObject(parent)
    , process_(new QProcess(this))
{
    const QString cacheDirectory = QStandardPaths::writableLocation(QStandardPaths::CacheLocation);
    QDir().mkpath(cacheDirectory);
    outputPath_ = cacheDirectory + QStringLiteral("/rgplayer-preview.png");
}

QUrl ThumbnailService::imageUrl() const
{
    return imageUrl_;
}

void ThumbnailService::request(const QString &path, double position)
{
    if (path.isEmpty() || position < 0.0) {
        return;
    }

    if (process_->state() != QProcess::NotRunning) {
        process_->kill();
        process_->waitForFinished(100);
    }

    const QStringList arguments = {
        QStringLiteral("-hide_banner"),
        QStringLiteral("-loglevel"),
        QStringLiteral("error"),
        QStringLiteral("-ss"),
        QString::number(position, 'f', 3),
        QStringLiteral("-i"),
        path,
        QStringLiteral("-frames:v"),
        QStringLiteral("1"),
        QStringLiteral("-vf"),
        QStringLiteral("scale=320:-1"),
        QStringLiteral("-y"),
        outputPath_,
    };

    disconnect(process_, nullptr, this, nullptr);
    connect(process_, &QProcess::finished, this, [this](int exitCode, QProcess::ExitStatus) {
        if (exitCode != 0) {
            return;
        }
        imageUrl_ = QUrl::fromLocalFile(outputPath_);
        emit imageUrlChanged();
    });
    process_->start(QStringLiteral("ffmpeg"), arguments);
}
