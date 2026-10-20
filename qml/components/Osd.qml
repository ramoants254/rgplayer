import QtQuick

Rectangle {
    id: osd

    property string message: ""

    function showMessage(value) {
        osd.message = value
        osd.visible = true
        hideTimer.restart()
    }

    color: Theme.surfaceRaised
    border.color: Theme.border
    radius: Theme.controlRadius
    implicitWidth: messageLabel.implicitWidth + 32
    implicitHeight: messageLabel.implicitHeight + 20
    visible: false

    Timer {
        id: hideTimer

        interval: 1200
        onTriggered: osd.visible = false
    }

    Text {
        id: messageLabel

        anchors.centerIn: parent
        color: Theme.text
        font.pixelSize: 16
        text: osd.message
    }
}
