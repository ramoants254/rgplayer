import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtCore
import QtQuick.Layouts

ApplicationWindow {
    id: window

    visible: true
    width: 1280
    height: 720
    minimumWidth: 800
    minimumHeight: 480
    title: qsTr("rgplayer")
    color: Theme.bg

    property bool settingsVisible: false
    property bool playlistVisible: false

    Settings {
        id: appSettings

        category: "Playback"
        property real volume: 100
        property bool reduceMotion: false
    }

    Component.onCompleted: playerController.volume = appSettings.volume

    Connections {
        target: playerController
        function onVolumeChanged() {
            appSettings.volume = playerController.volume
        }
    }

    Connections {
        target: thumbnailService
        function onImageUrlChanged() {
            playbackBar.thumbnailSource = thumbnailService.imageUrl
        }
    }

    Shortcut {
        sequence: "Space"
        onActivated: playerController.togglePause()
    }

    function openMedia(path) {
        if (path.length === 0) {
            return
        }
        playlistModel.addFile(path)
        playerController.openFile(path)
    }

    Osd {
        id: osd

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.margins: 24
        z: 5
    }

    Shortcut {
        sequence: "Ctrl+O"
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: window.settingsVisible = !window.settingsVisible
    }

    Shortcut {
        sequence: "F11"
        onActivated: window.visibility = window.visibility === Window.FullScreen
            ? Window.Windowed : Window.FullScreen
    }

    Shortcut {
        sequence: "["
        onActivated: playerController.speed = Math.max(0.25, playerController.speed - 0.25)
    }

    Shortcut {
        sequence: "]"
        onActivated: playerController.speed = Math.min(4.0, playerController.speed + 0.25)
    }

    Shortcut {
        sequence: "."
        onActivated: playerController.frameStep()
    }

    Shortcut {
        sequence: "PageUp"
        onActivated: playerController.previousChapter()
    }

    Shortcut {
        sequence: "PageDown"
        onActivated: playerController.nextChapter()
    }

    FileDialog {
        id: fileDialog

        title: qsTr("Open media file")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Media files (*.mp4 *.mkv *.webm *.avi *.mov *.mp3 *.flac *.wav)"),
            qsTr("All files (*)")]
        onAccepted: {
            // selectedFile is a QML url value — its toString() gives "file:///path".
            // .toLocalFile() does not exist on a QML url; strip the scheme manually.
            let raw = selectedFile.toString()
            if (raw.startsWith("file:///"))
                raw = raw.slice(7)          // keep the leading /
            else if (raw.startsWith("file://"))
                raw = raw.slice(7)
            openMedia(decodeURIComponent(raw))
        }
    }

    MpvRenderItem {
        id: videoOutput

        anchors.fill: parent
        controller: playerController
    }

    // Window-level mouse tracker: any movement over the video area reveals the bar.
    MouseArea {
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        propagateComposedEvents: true
        cursorShape: playbackBar.revealed ? Qt.ArrowCursor : Qt.BlankCursor
        z: 1
        onPositionChanged: playbackBar.showTemporarily()
        onEntered: playbackBar.showTemporarily()
        // Double-click toggles fullscreen; single click ignored (propagated to items below)
        onDoubleClicked: {
            window.visibility = window.visibility === Window.FullScreen
                ? Window.Windowed : Window.FullScreen
        }
        onClicked: function(mouse) { mouse.accepted = false }
    }

    DropArea {
        id: dropArea

        anchors.fill: parent
        z: 1
        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                openMedia(drop.urls[0].toLocalFile())
                drop.acceptProposedAction()
            }
        }
    }

    Rectangle {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 560)
        height: emptyLayout.implicitHeight + 40
        color: Theme.surface
        border.color: Theme.border
        radius: Theme.panelRadius
        visible: playerController.duration <= 0
        z: 2

        ColumnLayout {
            id: emptyLayout

            anchors.centerIn: parent
            width: parent.width - 40
            spacing: 10

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("rgplayer")
                color: Theme.text
                font.pixelSize: 28
                font.weight: Font.DemiBold
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: playerController.available
                    ? qsTr("Open a local file to begin")
                    : qsTr("Playback core unavailable")
                color: Theme.textMuted
            }

            TextField {
                id: pathField

                Layout.fillWidth: true
                Accessible.name: qsTr("Media file path")
                placeholderText: qsTr("Enter a local media file path")
                selectByMouse: true
            }

            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 8

                ThemeButton {
                    Accessible.name: qsTr("Choose media file")
                    text: qsTr("Choose file")
                    onClicked: fileDialog.open()
                }

                ThemeButton {
                    Accessible.name: qsTr("Open path")
                    text: qsTr("Open path")
                    onClicked: openMedia(pathField.text)
                }
            }

            Label {
                Layout.fillWidth: true
                color: Theme.accent
                elide: Text.ElideRight
                text: playerController.error
                visible: text.length > 0
            }

            ThemeCheckBox {
                Accessible.name: qsTr("Reduce motion")
                checked: appSettings.reduceMotion
                text: qsTr("Reduce motion")
                onToggled: appSettings.reduceMotion = checked
            }
        }
    }

    PlaybackBar {
        id: playbackBar

        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        controller: playerController
        reduceMotion: appSettings.reduceMotion
        z: 3
        onChooseFileRequested: fileDialog.open()
        onSettingsRequested: window.settingsVisible = true
        onOsdRequested: function(message) { osd.showMessage(message) }
        onPlaylistRequested: window.playlistVisible = true
        onThumbnailRequested: function(position) { thumbnailService.request(playerController.currentFile, position) }
    }

    SettingsPage {
        anchors.fill: parent
        visible: window.settingsVisible
        z: 4
        controller: playerController
        reduceMotion: appSettings.reduceMotion
        onReduceMotionChanged: appSettings.reduceMotion = reduceMotion
        onCloseRequested: window.settingsVisible = false
    }

    PlaylistDrawer {
        anchors.top: parent.top
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        visible: window.playlistVisible
        z: 4
        playlist: playlistModel
        onCloseRequested: window.playlistVisible = false
    }
}
