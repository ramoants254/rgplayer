#include "mpv_render_item.h"

#include <QOpenGLContext>
#include <QOpenGLFramebufferObject>
#include <QQuickOpenGLUtils>
#include <QQuickWindow>

#include "app/player_controller.h"
#include "core/mpv_wrapper.h"

namespace {

class MpvFramebufferRenderer final : public QQuickFramebufferObject::Renderer
{
public:
    ~MpvFramebufferRenderer() override
    {
        if (wrapper_ != nullptr) {
            wrapper_->freeRenderContext();
        }
    }

    void synchronize(QQuickFramebufferObject *item) override
    {
        auto *renderItem = static_cast<MpvRenderItem *>(item);
        controller_ = qobject_cast<PlayerController *>(renderItem->controller());
        if (controller_ == nullptr || wrapper_ != nullptr) {
            return;
        }

        wrapper_ = controller_->backend();
        if (wrapper_ != nullptr) {
            wrapper_->createRenderContext(&getProcAddress, &renderUpdate, renderItem);
        }
    }

    QOpenGLFramebufferObject *createFramebufferObject(const QSize &size) override
    {
        return new QOpenGLFramebufferObject(size, QOpenGLFramebufferObject::CombinedDepthStencil);
    }

    void render() override
    {
        if (wrapper_ == nullptr || framebufferObject() == nullptr) {
            return;
        }

        const QSize size = framebufferObject()->size();
        // handle() is the GL framebuffer object id; texture() is just the colour
        // attachment texture id — they are different namespaces in OpenGL.
        // mpv_opengl_fbo.fbo must receive the FBO id (handle), not the texture id.
        wrapper_->renderToFramebuffer(framebufferObject()->handle(), size.width(), size.height());
        QQuickOpenGLUtils::resetOpenGLState();
    }

private:
    static void *getProcAddress(void *, const char *name)
    {
        auto *context = QOpenGLContext::currentContext();
        return context == nullptr
            ? nullptr
            : reinterpret_cast<void *>(context->getProcAddress(name));
    }

    static void renderUpdate(void *context)
    {
        auto *item = static_cast<MpvRenderItem *>(context);
        QMetaObject::invokeMethod(item, &MpvRenderItem::requestUpdate, Qt::QueuedConnection);
    }

    PlayerController *controller_ = nullptr;
    MpvWrapper *wrapper_ = nullptr;
};

} // namespace

MpvRenderItem::MpvRenderItem(QQuickItem *parent)
    : QQuickFramebufferObject(parent)
{
    setMirrorVertically(false);
}

QQuickFramebufferObject::Renderer *MpvRenderItem::createRenderer() const
{
    return new MpvFramebufferRenderer;
}

QObject *MpvRenderItem::controller() const
{
    return playerController_;
}

void MpvRenderItem::setController(QObject *controller)
{
    auto *playerController = qobject_cast<PlayerController *>(controller);
    if (playerController_ == playerController) {
        return;
    }

    playerController_ = playerController;
    emit controllerChanged();
    update();
}

void MpvRenderItem::requestUpdate()
{
    update();
}
