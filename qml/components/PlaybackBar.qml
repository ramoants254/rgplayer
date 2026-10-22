import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

// The outer Item is taller than the visible controls so the gradient vignette
// blends the control zone into the video above it.
Item {
    id: bar

    property var controller
    property bool revealed: true
    property bool reduceMotion: false
    property url thumbnailSource

    signal chooseFileRequested()
    signal settingsRequested()
    signal osdRequested(string message)
    signal playlistRequested()
    signal thumbnailRequested(real position)

    // Called by the window-level mouse tracker whenever the mouse moves.
    function showTemporarily() {
        revealed = true
        if (!barHover.hovered) {
            hideTimer.restart()
        }
    }

    implicitHeight: 160  // vignette (upper ~70px) + controls (lower ~90px)

    // ── Gradient vignette fills the whole item height ──────────────────────
    Rectangle {
        anchors.fill: parent
        gradient: Gradient {
            orientation: Gradient.Vertical
            GradientStop { position: 0.0; color: "transparent" }
            GradientStop { position: 0.55; color: Qt.rgba(0.039, 0.039, 0.047, 0.55) }
            GradientStop { position: 1.0;  color: Qt.rgba(0.039, 0.039, 0.047, 0.94) }
        }
    }

    // ── Seek-bar hover thumbnail ────────────────────────────────────────────
    Rectangle {
        id: thumbBox
        anchors.bottom: controlsCol.top
        anchors.bottomMargin: 10
        x: Math.max(14, Math.min(bar.width - width - 14, controlsCol.x + seekSlider.x + seekSlider.hoverPositionX - width / 2))
        width: 162
        height: 92
        color: "#111215"
        border.color: Theme.accent
        border.width: 1
        radius: 4
        visible: seekSlider.hovered && bar.revealed && thumbImg.status === Image.Ready && bar.thumbnailSource.toString().length > 0

        Image {
            id: thumbImg
            anchors.fill: parent
            anchors.margins: 1
            fillMode: Image.PreserveAspectFit
            source: bar.thumbnailSource
            cache: false
        }
    }

    // ── Auto-hide timer ─────────────────────────────────────────────────────
    Timer {
        id: hideTimer
        interval: 2500
        repeat: false
        onTriggered: bar.revealed = false
    }

    HoverHandler {
        id: barHover
        onHoveredChanged: {
            if (hovered) {
                bar.revealed = true
                hideTimer.stop()
            } else {
                hideTimer.restart()
            }
        }
    }

    // ── Controls ────────────────────────────────────────────────────────────
    ColumnLayout {
        id: controlsCol
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        anchors.bottomMargin: 10
        spacing: 6

        // Row 0: Seek slider
        ThemeSlider {
            id: seekSlider
            Layout.fillWidth: true
            Accessible.name: qsTr("Playback position")
            from: 0
            to: Math.max(0, bar.controller ? bar.controller.duration : 0)
            value: bar.controller ? bar.controller.position : 0
            enabled: to > 0
            onMoved: {
                bar.controller.seek(value)
                bar.osdRequested(qsTr("Seek %1").arg(fmtTime(Math.floor(value))))
            }
            onHoverValueChanged: function(v) { bar.thumbnailRequested(v) }
        }

        // Row 1: Primary controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 6

            ThemeButton {
                Accessible.name: qsTr("Open media file")
                text: qsTr("Open")
                onClicked: bar.chooseFileRequested()
            }

            ThemeButton {
                id: playPauseBtn
                Accessible.name: bar.controller && bar.controller.paused ? qsTr("Play") : qsTr("Pause")
                text: bar.controller && bar.controller.paused ? qsTr("▶") : qsTr("⏸")
                font.pixelSize: 15
                onClicked: bar.controller.togglePause()
            }

            Label {
                color: Theme.textMuted
                font.pixelSize: 13
                text: bar.controller
                    ? fmtTime(Math.floor(bar.controller.position)) + "  /  " + fmtTime(Math.floor(bar.controller.duration))
                    : "0:00  /  0:00"
            }

            Item { Layout.fillWidth: true }

            Label { color: Theme.textMuted; text: "🔊"; font.pixelSize: 14 }

            ThemeSlider {
                Layout.preferredWidth: 100
                Accessible.name: qsTr("Volume")
                from: 0; to: 100
                value: bar.controller ? bar.controller.volume : 0
                onMoved: {
                    bar.controller.volume = value
                    bar.osdRequested(qsTr("Volume %1%").arg(Math.floor(value)))
                }
            }

            ThemeButton {
                Accessible.name: qsTr("Settings")
                text: qsTr("⚙")
                font.pixelSize: 14
                onClicked: bar.settingsRequested()
            }

            ThemeButton {
                Accessible.name: qsTr("Playlist")
                text: qsTr("☰")
                font.pixelSize: 14
                onClicked: bar.playlistRequested()
            }
        }

        // Row 2: Power controls
        RowLayout {
            Layout.fillWidth: true
            spacing: 4

            ThemeButton { text: qsTr("−"); Accessible.name: qsTr("Decrease speed"); font.pixelSize: 14
                onClicked: if (bar.controller) bar.controller.speed = Math.max(0.25, bar.controller.speed - 0.25) }
            Label { color: Theme.textMuted; font.pixelSize: 12; text: bar.controller ? bar.controller.speed.toFixed(2) + "x" : "1.00x" }
            ThemeButton { text: qsTr("+"); Accessible.name: qsTr("Increase speed"); font.pixelSize: 14
                onClicked: if (bar.controller) bar.controller.speed = Math.min(4.0, bar.controller.speed + 0.25) }

            Rectangle { width: 1; height: 16; color: Theme.border; Layout.leftMargin: 2; Layout.rightMargin: 2 }

            ThemeButton { text: qsTr("Frame"); Accessible.name: qsTr("Step one frame"); onClicked: bar.controller.frameStep() }
            ThemeButton { text: qsTr("A"); Accessible.name: qsTr("Set A loop point"); onClicked: bar.controller.setLoopStart() }
            ThemeButton { text: qsTr("B"); Accessible.name: qsTr("Set B loop point"); onClicked: bar.controller.setLoopEnd() }
            ThemeButton { text: qsTr("Clear loop"); Accessible.name: qsTr("Clear A/B loop"); onClicked: bar.controller.clearLoop() }

            Rectangle { width: 1; height: 16; color: Theme.border; Layout.leftMargin: 2; Layout.rightMargin: 2 }

            ThemeButton { text: qsTr("Ch −"); Accessible.name: qsTr("Previous chapter"); onClicked: bar.controller.previousChapter() }
            ThemeButton { text: qsTr("Ch +"); Accessible.name: qsTr("Next chapter"); onClicked: bar.controller.nextChapter() }

            Rectangle { width: 1; height: 16; color: Theme.border; Layout.leftMargin: 2; Layout.rightMargin: 2 }

            ThemeButton { text: qsTr("Audio"); Accessible.name: qsTr("Cycle audio track"); onClicked: bar.controller.cycleAudioTrack() }
            ThemeButton { text: qsTr("Subs"); Accessible.name: qsTr("Cycle subtitle track"); onClicked: bar.controller.cycleSubtitleTrack() }

            Item { Layout.fillWidth: true }
        }
    }

    // ── Visibility animation ─────────────────────────────────────────────────
    opacity: bar.revealed ? 1.0 : 0.0
    Behavior on opacity {
        NumberAnimation { duration: bar.reduceMotion ? 0 : 180; easing.type: Easing.OutCubic }
    }

    // ── Time formatter ────────────────────────────────────────────────────────
    function fmtTime(secs) {
        const h = Math.floor(secs / 3600)
        const m = Math.floor((secs % 3600) / 60)
        const s = secs % 60
        const pad = n => String(n).padStart(2, "0")
        return h > 0 ? h + ":" + pad(m) + ":" + pad(s) : m + ":" + pad(s)
    }
}
