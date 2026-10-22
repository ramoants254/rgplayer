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
            spacing: 6

            delegate: ThemeButton {
                required property string title
                required property int index

                Accessible.name: qsTr("Play %1").arg(title)
                highlighted: index === drawer.playlist.currentIndex
                text: title
                width: list.width
                onClicked: drawer.playlist.playAt(index)
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
