import QtQuick
import QtQuick.Controls

CheckBox {
    id: checkBox

    Accessible.role: Accessible.CheckBox

    indicator: Rectangle {
        x: checkBox.leftPadding
        y: checkBox.topPadding + (checkBox.availableHeight - height) / 2
        implicitWidth: 20
        implicitHeight: 20
        radius: 4
        color: checkBox.checked ? Theme.accent : Theme.surface
        border.color: checkBox.activeFocus ? Theme.accentHover : Theme.border
        border.width: checkBox.activeFocus ? 2 : 1

        Text {
            anchors.centerIn: parent
            color: Theme.accentText
            font.pixelSize: 14
            text: checkBox.checked ? "x" : ""
        }
    }

    contentItem: Text {
        leftPadding: checkBox.indicator.width + checkBox.spacing
        color: Theme.text
        text: checkBox.text
        verticalAlignment: Text.AlignVCenter
    }
}
