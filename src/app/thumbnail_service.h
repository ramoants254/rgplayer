#pragma once

#include <QObject>
#include <QUrl>

class QProcess;

class ThumbnailService final : public QObject
{
    Q_OBJECT
    Q_PROPERTY(QUrl imageUrl READ imageUrl NOTIFY imageUrlChanged)

public:
    explicit ThumbnailService(QObject *parent = nullptr);

    QUrl imageUrl() const;
    Q_INVOKABLE void request(const QString &path, double position);

signals:
    void imageUrlChanged();

private:
    QProcess *process_ = nullptr;
    QString outputPath_;
    QUrl imageUrl_;
};
