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
    minimumWidth: isMiniPlayer ? 240 : 800
    minimumHeight: isMiniPlayer ? 135 : 480
    title: qsTr("rgplayer")
    color: Theme.bg
    flags: isMiniPlayer ? (Qt.Window | Qt.WindowStaysOnTopHint) : Qt.Window

    property bool settingsVisible: false
    property bool playlistVisible: false
    property bool isMiniPlayer: false
    property real savedWidth: 1280
    property real savedHeight: 720
    property real savedX: 100
    property real savedY: 100

    function toggleMiniPlayer() {
        if (!isMiniPlayer) {
            savedWidth = window.width
            savedHeight = window.height
            savedX = window.x
            savedY = window.y
            window.playlistVisible = false
            window.settingsVisible = false
            if (mediaInfoDialog.visible)
                mediaInfoDialog.close()
            isMiniPlayer = true
            window.width = 360
            window.height = 202
            osd.showMessage(qsTr("Mini Player Mode"))
        } else {
            isMiniPlayer = false
            window.width = Math.max(800, savedWidth)
            window.height = Math.max(480, savedHeight)
            window.x = savedX
            window.y = savedY
            osd.showMessage(qsTr("Standard Mode"))
        }
    }

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

    function isAudioFile(path) {
        if (!path) return false
        let lower = path.toLowerCase()
        return lower.endsWith(".mp3") || lower.endsWith(".flac") || lower.endsWith(".wav")
            || lower.endsWith(".m4a") || lower.endsWith(".aac") || lower.endsWith(".ogg")
            || lower.endsWith(".opus") || lower.endsWith(".wma")
    }

    function openMedia(path) {
        if (!path) return
        let clean = path.trim()
        if (clean.length === 0) return
        if ((clean.startsWith('"') && clean.endsWith('"')) || (clean.startsWith("'") && clean.endsWith("'"))) {
            clean = clean.substring(1, clean.length - 1)
        }
        if (clean.startsWith("file:///"))
            clean = clean.slice(7)
        else if (clean.startsWith("file://"))
            clean = clean.slice(7)
        clean = decodeURIComponent(clean)
        playlistModel.addFile(clean)
        playerController.openFile(clean)
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

    // Next / Previous Playlist Tracks
    Shortcut {
        sequence: "N"
        context: Qt.ApplicationShortcut
        onActivated: {
            playlistModel.playNext()
            osd.showMessage(qsTr("Next track"))
        }
    }

    Shortcut {
        sequence: "B"
        context: Qt.ApplicationShortcut
        onActivated: {
            playlistModel.playPrevious()
            osd.showMessage(qsTr("Previous track"))
        }
    }

    // Dialogs & drawers
    Shortcut {
        sequence: "Ctrl+O"
        context: Qt.ApplicationShortcut
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "O"
        context: Qt.ApplicationShortcut
        onActivated: fileDialog.open()
    }

    Shortcut {
        sequence: "P"
        context: Qt.ApplicationShortcut
        onActivated: window.playlistVisible = !window.playlistVisible
    }

    Shortcut {
        sequence: "Ctrl+,"
        context: Qt.ApplicationShortcut
        onActivated: window.settingsVisible = !window.settingsVisible
    }

    Shortcut {
        sequence: "S"
        context: Qt.ApplicationShortcut
        onActivated: window.settingsVisible = !window.settingsVisible
    }

    Shortcut {
        sequence: "F1"
        context: Qt.ApplicationShortcut
        onActivated: {
            window.settingsVisible = !window.settingsVisible
            if (window.settingsVisible)
                osd.showMessage(qsTr("Help & Shortcuts"))
        }
    }

    Shortcut {
        sequence: "I"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (mediaInfoDialog.visible)
                mediaInfoDialog.close()
            else
                mediaInfoDialog.open()
        }
    }

    Shortcut {
        sequence: "M"
        context: Qt.ApplicationShortcut
        onActivated: window.toggleMiniPlayer()
    }

    Shortcut {
        sequence: "Escape"
        context: Qt.ApplicationShortcut
        onActivated: {
            if (mediaInfoDialog.visible)
                mediaInfoDialog.close()
            else if (window.isMiniPlayer)
                window.toggleMiniPlayer()
            else if (window.playlistVisible)
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
        enabled: !window.isMiniPlayer
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true
        cursorShape: playbackBar.revealed ? Qt.ArrowCursor : Qt.BlankCursor
        z: 1
        onPositionChanged: playbackBar.showTemporarily()
        onEntered: playbackBar.showTemporarily()
        // Double-click toggles fullscreen; single click ignored (propagated to items below)
        onDoubleClicked: function(mouse) {
            if (mouse.button === Qt.LeftButton) {
                window.visibility = window.visibility === Window.FullScreen
                    ? Window.Windowed : Window.FullScreen
            }
        }
        onClicked: function(mouse) {
            if (mouse.button === Qt.RightButton) {
                videoMenu.popup(mouse.x, mouse.y)
            } else {
                mouse.accepted = false
            }
        }
    }

    VideoContextMenu {
        id: videoMenu
        controller: playerController
        onMediaInfoRequested: mediaInfoDialog.open()
        onMiniPlayerRequested: window.toggleMiniPlayer()
    }

    MediaInfoDialog {
        id: mediaInfoDialog
        controller: playerController
    }

    DropArea {
        id: dropArea

        anchors.fill: parent
        z: 1
        onDropped: function(drop) {
            if (drop.hasUrls && drop.urls.length > 0) {
                let initialCount = playlistModel.count()
                for (let i = 0; i < drop.urls.length; ++i) {
                    let raw = drop.urls[i].toString()
                    if (raw.startsWith("file:///"))
                        raw = raw.slice(7)
                    else if (raw.startsWith("file://"))
                        raw = raw.slice(7)
                    playlistModel.addFile(decodeURIComponent(raw))
                }
                let newCount = playlistModel.count()
                if (newCount > initialCount) {
                    let firstNewPath = playlistModel.getPath(initialCount)
                    if (firstNewPath.length > 0) {
                        playlistModel.playAt(initialCount)
                    }
                    osd.showMessage(qsTr("Added %1 item(s) to playlist").arg(newCount - initialCount))
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
        visible: !window.isMiniPlayer && playerController.duration <= 0
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

            // ── Recent Files ────────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Theme.border
                visible: recentRepeater.count > 0
            }

            Label {
                Layout.alignment: Qt.AlignHCenter
                text: qsTr("Recent Files")
                color: Theme.textMuted
                font.pixelSize: 13
                font.weight: Font.DemiBold
                visible: recentRepeater.count > 0
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                visible: recentRepeater.count > 0

                Repeater {
                    id: recentRepeater
                    model: playerController.recentFiles

                    Rectangle {
                        Layout.fillWidth: true
                        height: 30
                        radius: Theme.controlRadius
                        color: recentMouse.containsMouse ? Theme.surfaceRaised : "transparent"

                        Label {
                            anchors.fill: parent
                            anchors.leftMargin: 10
                            anchors.rightMargin: 10
                            verticalAlignment: Text.AlignVCenter
                            elide: Text.ElideLeft
                            text: modelData.substring(modelData.lastIndexOf('/') + 1)
                            color: recentMouse.containsMouse ? Theme.accent : Theme.text
                            font.pixelSize: 12
                        }

                        MouseArea {
                            id: recentMouse
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: openMedia(modelData)
                        }

                        ToolTip {
                            visible: recentMouse.containsMouse
                            text: modelData
                            delay: 600
                        }
                    }
                }
            }
        }
    }

    // Music / Audio Album Screen
    Rectangle {
        id: musicView
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 460)
        height: 270
        color: Qt.rgba(0.08, 0.08, 0.10, 0.88)
        border.color: Qt.rgba(1, 1, 1, 0.12)
        radius: 16
        z: 2
        visible: !window.isMiniPlayer && playerController.duration > 0 && isAudioFile(playerController.currentFile)
        opacity: 1.0

        ColumnLayout {
            anchors.centerIn: parent
            spacing: 14
            width: parent.width - 40

            // Vinyl Record Disc
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                width: 90
                height: 90
                radius: 45
                color: "#181a1f"
                border.color: Theme.accent
                border.width: 2

                Rectangle {
                    anchors.centerIn: parent
                    width: 60
                    height: 60
                    radius: 30
                    color: "transparent"
                    border.color: Qt.rgba(1, 1, 1, 0.08)
                    border.width: 1
                }

                Rectangle {
                    anchors.centerIn: parent
                    width: 26
                    height: 26
                    radius: 13
                    color: Theme.accent
                }

                Label {
                    anchors.centerIn: parent
                    text: "🎵"
                    font.pixelSize: 16
                }

                RotationAnimation on rotation {
                    loops: Animation.Infinite
                    from: 0
                    to: 360
                    duration: 5000
                    running: musicView.visible && !playerController.paused && !appSettings.reduceMotion
                }
            }

            // Track info
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    Layout.maximumWidth: musicView.width - 40
                    elide: Text.ElideMiddle
                    text: {
                        let path = playerController.currentFile
                        let filename = path.substring(path.lastIndexOf('/') + 1)
                        return filename.length > 0 ? filename : qsTr("Audio Track")
                    }
                    color: Theme.text
                    font.pixelSize: 18
                    font.weight: Font.DemiBold
                }

                Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: {
                        let parts = playerController.currentFile.split('.')
                        let ext = parts.length > 1 ? parts[parts.length - 1].toUpperCase() : "AUDIO"
                        return qsTr("%1 Track • %2").arg(ext).arg(playerController.paused ? qsTr("Paused") : qsTr("Playing"))
                    }
                    color: Theme.accent
                    font.pixelSize: 13
                }
            }

            // Equalizer Bars
            Row {
                Layout.alignment: Qt.AlignHCenter
                spacing: 4

                Repeater {
                    model: 14
                    Rectangle {
                        width: 4
                        height: 6 + Math.abs(Math.sin((index * 0.7) + (playerController.position * 9))) * 22
                        radius: 2
                        color: Theme.accent
                        opacity: playerController.paused ? 0.35 : 0.9

                        Behavior on height {
                            NumberAnimation { duration: 90 }
                        }
                    }
                }
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
        visible: !window.isMiniPlayer
        z: 3
        onChooseFileRequested: fileDialog.open()
        onSettingsRequested: window.settingsVisible = true
        onOsdRequested: function(message) { osd.showMessage(message) }
        onPlaylistRequested: window.playlistVisible = true
        onThumbnailRequested: function(position) { thumbnailService.request(playerController.currentFile, position) }
    }

    // ── Mini Player Hover Overlay ───────────────────────────────
    Rectangle {
        id: miniPlayerOverlay
        anchors.fill: parent
        z: 3
        visible: window.isMiniPlayer
        color: miniMouse.containsMouse ? Qt.rgba(0, 0, 0, 0.5) : "transparent"

        MouseArea {
            id: miniMouse
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            onClicked: function(mouse) {
                if (mouse.button === Qt.RightButton) {
                    videoMenu.popup(mouse.x, mouse.y)
                } else {
                    playerController.togglePause()
                }
            }
            onDoubleClicked: function(mouse) {
                if (mouse.button === Qt.LeftButton) {
                    window.toggleMiniPlayer()
                }
            }
        }

        // Top bar in mini mode
        RowLayout {
            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 8
            visible: miniMouse.containsMouse

            Label {
                Layout.fillWidth: true
                text: playerController.currentFile ? playerController.currentFile.substring(playerController.currentFile.lastIndexOf('/') + 1) : qsTr("rgplayer")
                color: Theme.text
                font.pixelSize: 11
                font.weight: Font.Medium
                elide: Text.ElideRight
            }

            Rectangle {
                width: 22
                height: 22
                radius: 4
                color: restoreMouse.containsMouse ? Theme.surfaceRaised : Qt.rgba(0, 0, 0, 0.6)
                Accessible.name: qsTr("Exit mini player mode")

                Label {
                    anchors.centerIn: parent
                    text: "🗗"
                    color: restoreMouse.containsMouse ? Theme.accent : Theme.text
                    font.pixelSize: 11
                }

                MouseArea {
                    id: restoreMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: window.toggleMiniPlayer()
                }
            }
        }

        // Bottom bar in mini mode
        ColumnLayout {
            anchors.bottom: parent.bottom
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.margins: 6
            spacing: 2
            visible: miniMouse.containsMouse

            // Slim progress seekbar
            Slider {
                Layout.fillWidth: true
                Layout.preferredHeight: 14
                from: 0
                to: Math.max(1, playerController.duration)
                value: playerController.position
                onMoved: playerController.seek(value)

                background: Rectangle {
                    x: parent.leftPadding
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: parent.availableWidth
                    height: 3
                    radius: 1.5
                    color: Qt.rgba(1, 1, 1, 0.3)

                    Rectangle {
                        width: parent.width * (playerController.duration > 0 ? playerController.position / playerController.duration : 0)
                        height: parent.height
                        color: Theme.accent
                        radius: 1.5
                    }
                }

                handle: Rectangle {
                    x: parent.leftPadding + parent.visualPosition * (parent.availableWidth - width)
                    y: parent.topPadding + parent.availableHeight / 2 - height / 2
                    width: 8
                    height: 8
                    radius: 4
                    color: Theme.accent
                }
            }

            // Compact controls
            RowLayout {
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: 12

                Label {
                    text: "⏮"
                    color: prevMouse.containsMouse ? Theme.accent : Theme.text
                    font.pixelSize: 12
                    Accessible.name: qsTr("Previous track")
                    MouseArea {
                        id: prevMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: playlistModel.playPrevious()
                    }
                }

                Label {
                    text: playerController.paused ? "▶" : "⏸"
                    color: playMiniMouse.containsMouse ? Theme.accent : Theme.text
                    font.pixelSize: 14
                    font.weight: Font.Bold
                    Accessible.name: playerController.paused ? qsTr("Play") : qsTr("Pause")
                    MouseArea {
                        id: playMiniMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: playerController.togglePause()
                    }
                }

                Label {
                    text: "⏭"
                    color: nextMouse.containsMouse ? Theme.accent : Theme.text
                    font.pixelSize: 12
                    Accessible.name: qsTr("Next track")
                    MouseArea {
                        id: nextMouse
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: playlistModel.playNext()
                    }
                }
            }
        }
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
