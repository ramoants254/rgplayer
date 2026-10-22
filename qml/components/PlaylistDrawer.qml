import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Rectangle {
    id: drawer

    property var playlist
    signal closeRequested()

    color: Theme.surface
    border.color: Theme.border
    border.width: 1
    width: 320

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 16
        spacing: 12

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                color: Theme.text
                font.pixelSize: 20
                font.weight: Font.DemiBold
                text: qsTr("Playlist")
            }

            ThemeButton {
                Accessible.name: qsTr("Close playlist")
                text: qsTr("Close")
                onClicked: drawer.closeRequested()
            }
        }

        ListView {
            id: list

            Layout.fillHeight: true
            Layout.fillWidth: true
            clip: true
            model: drawer.playlist
            spacing: 4
            focus: true
            boundsBehavior: Flickable.StopAtBounds

            Keys.onReturnPressed: {
                if (currentIndex >= 0 && currentIndex < count) {
                    drawer.playlist.playAt(currentIndex)
                }
            }
            Keys.onEnterPressed: {
                if (currentIndex >= 0 && currentIndex < count) {
                    drawer.playlist.playAt(currentIndex)
                }
            }
            Keys.onDeletePressed: {
                if (currentIndex >= 0 && currentIndex < count) {
                    drawer.playlist.removeAt(currentIndex)
                }
            }

            delegate: Rectangle {
                id: itemDelegate
                required property string title
                required property int index

                readonly property bool isPlaying: index === drawer.playlist.currentIndex
                readonly property bool isSelected: index === list.currentIndex

                width: list.width
                height: Theme.controlHeight
                radius: Theme.controlRadius
                color: {
                    if (mouseArea.pressed)
                        return Theme.surfaceRaised
                    if (isSelected && list.activeFocus)
                        return Theme.surfaceRaised
                    if (isPlaying)
                        return Qt.rgba(1.0, 0.42, 0.0, 0.18)
                    if (mouseArea.containsMouse)
                        return Theme.surfaceRaised
                    return Theme.surface
                }
                border.color: {
                    if (isSelected && list.activeFocus)
                        return Theme.accent
                    if (isPlaying)
                        return Theme.accent
                    if (isSelected)
                        return Theme.border
                    return "transparent"
                }
                border.width: (isPlaying || (isSelected && list.activeFocus)) ? 1.5 : 1

                MouseArea {
                    id: mouseArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    acceptedButtons: Qt.LeftButton

                    onClicked: {
                        list.currentIndex = itemDelegate.index
                        list.forceActiveFocus()
                    }

                    onDoubleClicked: {
                        drawer.playlist.playAt(itemDelegate.index)
                    }
                }

                RowLayout {
                    anchors.fill: parent
                    anchors.leftMargin: 10
                    anchors.rightMargin: 8
                    spacing: 8

                    // Playing icon or track number
                    Label {
                        Layout.preferredWidth: 20
                        text: itemDelegate.isPlaying ? "▶" : (itemDelegate.index + 1)
                        color: itemDelegate.isPlaying ? Theme.accent : Theme.textMuted
                        font.pixelSize: itemDelegate.isPlaying ? 11 : 12
                        font.weight: itemDelegate.isPlaying ? Font.Bold : Font.Normal
                        horizontalAlignment: Text.AlignHCenter
                    }

                    // Track title
                    Label {
                        Layout.fillWidth: true
                        text: itemDelegate.title
                        color: itemDelegate.isPlaying ? Theme.accent : Theme.text
                        font.pixelSize: 13
                        font.weight: itemDelegate.isPlaying ? Font.Medium : Font.Normal
                        elide: Text.ElideRight
                    }

                    // Remove item button
                    Rectangle {
                        Layout.preferredWidth: 22
                        Layout.preferredHeight: 22
                        radius: 11
                        color: delMouse.containsMouse ? Qt.rgba(1, 1, 1, 0.15) : "transparent"
                        visible: mouseArea.containsMouse || itemDelegate.isSelected

                        Label {
                            anchors.centerIn: parent
                            text: "✕"
                            color: delMouse.containsMouse ? "#FF4D4D" : Theme.textMuted
                            font.pixelSize: 11
                        }

                        MouseArea {
                            id: delMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: drawer.playlist.removeAt(itemDelegate.index)
                        }
                    }
                }
            }

            Label {
                anchors.centerIn: parent
                color: Theme.textMuted
                text: qsTr("Playlist is empty")
                visible: list.count === 0
            }
        }

        ThemeButton {
            Accessible.name: qsTr("Clear playlist")
            Layout.fillWidth: true
            text: qsTr("Clear playlist")
            onClicked: drawer.playlist.clear()
        }
    }

    DropArea {
        anchors.fill: parent
        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                for (let i = 0; i < drop.urls.length; ++i) {
                    let raw = drop.urls[i].toString()
                    if (raw.startsWith("file:///"))
                        raw = raw.slice(7)
                    else if (raw.startsWith("file://"))
                        raw = raw.slice(7)
                    drawer.playlist.addFile(decodeURIComponent(raw))
                }
                drop.acceptProposedAction()
            }
        }
    }
}
