import QtQuick
import QtQuick.Controls

Slider {
    id: slider

    signal hoverValueChanged(real value)
    property alias hovered: hoverHandler.hovered
    property real hoverPositionX: hoverHandler.point.position.x

    implicitHeight: 24

    background: Rectangle {
        x: slider.leftPadding
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: slider.availableWidth
        height: 4
        radius: 2
        color: Theme.border

        Rectangle {
            width: slider.visualPosition * parent.width
            height: parent.height
            radius: parent.radius
            color: Theme.accent
        }
    }

    handle: Rectangle {
        x: slider.leftPadding + slider.visualPosition * (slider.availableWidth - width)
        y: slider.topPadding + slider.availableHeight / 2 - height / 2
        width: 16
        height: 16
        radius: 8
        color: slider.activeFocus ? Theme.accentHover : Theme.accent
        border.color: slider.activeFocus ? Theme.text : Theme.accent
        border.width: slider.activeFocus ? 2 : 1
    }

    HoverHandler {
        id: hoverHandler

        onPointChanged: {
            if (hovered && slider.width > 0) {
                var ratio = Math.max(0, Math.min(1, point.position.x / slider.width))
                slider.hoverValueChanged(slider.from + ratio * (slider.to - slider.from))
            }
        }
    }
}
