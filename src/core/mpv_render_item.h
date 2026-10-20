#pragma once

#include <QQuickFramebufferObject>
#include <QQuickItem>

class PlayerController;

class MpvRenderItem : public QQuickFramebufferObject
{
    Q_OBJECT
    QML_ELEMENT
    Q_PROPERTY(QObject *controller READ controller WRITE setController NOTIFY controllerChanged)

public:
    explicit MpvRenderItem(QQuickItem *parent = nullptr);

    Renderer *createRenderer() const override;
    QObject *controller() const;
    void setController(QObject *controller);

public slots:
    void requestUpdate();

signals:
    void controllerChanged();

private:
    PlayerController *playerController_ = nullptr;
};
