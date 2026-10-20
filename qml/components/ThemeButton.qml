import QtQuick
import QtQuick.Controls

Button {
    id: button

    implicitHeight: Theme.controlHeight
    leftPadding: 14
    rightPadding: 14
    Accessible.role: Accessible.Button

    contentItem: Text {
        text: button.text
        color: button.enabled ? Theme.text : Theme.textMuted
        font.pixelSize: 14
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
    }

    background: Rectangle {
        color: button.down ? Theme.accent : button.hovered ? Theme.surfaceRaised : Theme.surface
        border.color: button.activeFocus ? Theme.accent : Theme.border
        border.width: button.activeFocus ? 2 : 1
        radius: Theme.controlRadius
    }
}
