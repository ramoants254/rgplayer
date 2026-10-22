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

    property real previousVolume: 100
    property int loopStep: 0

    // Play / Pause
    Shortcut {
        sequence: "Space"
        onActivated: {
            playerController.togglePause()
            osd.showMessage(playerController.paused ? qsTr("Paused") : qsTr("Playing"))
        }
    }

    // Seeking
    Shortcut {
        sequence: "Left"
        onActivated: {
            let target = Math.max(0, playerController.position - 5)
            playerController.seek(target)
            osd.showMessage(qsTr("Seek -5s"))
        }
    }

    Shortcut {
        sequence: "Right"
        onActivated: {
            let target = Math.min(playerController.duration, playerController.position + 5)
            playerController.seek(target)
            osd.showMessage(qsTr("Seek +5s"))
        }
    }

    Shortcut {
        sequence: "Shift+Left"
        onActivated: {
            let target = Math.max(0, playerController.position - 1)
            playerController.seek(target)
            osd.showMessage(qsTr("Seek -1s"))
        }
    }

    Shortcut {
        sequence: "Shift+Right"
        onActivated: {
            let target = Math.min(playerController.duration, playerController.position + 1)
            playerController.seek(target)
            osd.showMessage(qsTr("Seek +1s"))
        }
    }

    // Volume
    Shortcut {
        sequence: "Up"
        onActivated: {
            playerController.volume = Math.min(100, playerController.volume + 5)
            osd.showMessage(qsTr("Volume %1%").arg(Math.round(playerController.volume)))
        }
    }

    Shortcut {
        sequence: "Down"
        onActivated: {
            playerController.volume = Math.max(0, playerController.volume - 5)
            osd.showMessage(qsTr("Volume %1%").arg(Math.round(playerController.volume)))
        }
    }

    Shortcut {
        sequence: "M"
        onActivated: {
            if (playerController.volume > 0) {
                window.previousVolume = playerController.volume
                playerController.volume = 0
                osd.showMessage(qsTr("Muted"))
            } else {
                playerController.volume = window.previousVolume > 0 ? window.previousVolume : 100
                osd.showMessage(qsTr("Volume %1%").arg(Math.round(playerController.volume)))
            }
        }
    }

    // Fullscreen
    Shortcut {
        sequence: "F"
        onActivated: window.visibility = window.visibility === Window.FullScreen
            ? Window.Windowed : Window.FullScreen
    }

    Shortcut {
        sequence: "F11"
        onActivated: window.visibility = window.visibility === Window.FullScreen
            ? Window.Windowed : Window.FullScreen
    }

    // Speed
    Shortcut {
        sequence: "["
        onActivated: {
            playerController.speed = Math.max(0.25, playerController.speed - 0.25)
            osd.showMessage(qsTr("Speed: %1x").arg(playerController.speed.toFixed(2)))
        }
    }

    Shortcut {
        sequence: "]"
        onActivated: {
            playerController.speed = Math.min(4.0, playerController.speed + 0.25)
            osd.showMessage(qsTr("Speed: %1x").arg(playerController.speed.toFixed(2)))
        }
    }

    Shortcut {
        sequence: "Backspace"
        onActivated: {
            playerController.speed = 1.0
            osd.showMessage(qsTr("Speed: 1.00x"))
        }
    }

    // Frame stepping
    Shortcut {
        sequence: "."
        onActivated: {
            playerController.frameStep()
            osd.showMessage(qsTr("Frame Step Forward"))
        }
    }

    // Chapters
    Shortcut {
        sequence: "PageUp"
        onActivated: playerController.previousChapter()
    }

    Shortcut {
        sequence: "PageDown"
        onActivated: playerController.nextChapter()
    }

    // A-B Loop
    Shortcut {
        sequence: "L"
        onActivated: {
            if (window.loopStep === 0) {
                playerController.setLoopStart()
                osd.showMessage(qsTr("Loop Point A set"))
                window.loopStep = 1
            } else if (window.loopStep === 1) {
                playerController.setLoopEnd()
                osd.showMessage(qsTr("Loop Point B set"))
                window.loopStep = 2
            } else {
                playerController.clearLoop()
                osd.showMessage(qsTr("Loop cleared"))
                window.loopStep = 0
            }
        }
    }

    // Dialogs & drawers
    Shortcut {
        sequence: "Ctrl+O"
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "O"
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "P"
        onActivated: window.playlistVisible = !window.playlistVisible
    }

    Shortcut {
        sequence: "Ctrl+,"
        onActivated: window.settingsVisible = !window.settingsVisible
    }

    Shortcut {
        sequence: "S"
        onActivated: window.settingsVisible = !window.settingsVisible
    }

    Shortcut {
        sequence: "Escape"
        onActivated: {
            if (window.playlistVisible)
                window.playlistVisible = false
            else if (window.settingsVisible)
                window.settingsVisible = false
            else if (window.visibility === Window.FullScreen)
                window.visibility = Window.Windowed
        }
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
                let firstPath = ""
                for (let i = 0; i < drop.urls.length; ++i) {
                    let raw = drop.urls[i].toString()
                    if (raw.startsWith("file:///"))
                        raw = raw.slice(7)
                    else if (raw.startsWith("file://"))
                        raw = raw.slice(7)
                    let clean = decodeURIComponent(raw)
                    if (i === 0)
                        firstPath = clean
                    playlistModel.addFile(clean)
                }
                if (firstPath.length > 0) {
                    openMedia(firstPath)
                    osd.showMessage(qsTr("Added %1 file(s) to playlist").arg(drop.urls.length))
                }
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
