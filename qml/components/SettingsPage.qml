import QtQuick
import QtQuick.Controls
import QtQuick.Dialogs
import QtQuick.Layouts

Rectangle {
    id: page

    property bool reduceMotion: false
    property var controller

    signal closeRequested()

    color: Theme.bg
    focus: true

    Keys.onEscapePressed: page.closeRequested()

    FileDialog {
        id: subtitleDialog

        title: qsTr("Load subtitle file")
        fileMode: FileDialog.OpenFile
        nameFilters: [qsTr("Subtitle files (*.srt *.ass *.ssa *.vtt)"), qsTr("All files (*)")]
        onAccepted: {
            let raw = selectedFile.toString()
            if (raw.startsWith("file:///"))
                raw = raw.slice(7)
            else if (raw.startsWith("file://"))
                raw = raw.slice(7)
            page.controller.loadSubtitle(decodeURIComponent(raw))
        }
    }

    // ── Sticky Top Header Bar (Always visible) ───────────────────────────────
    Rectangle {
        id: headerBar
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        height: 60
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        z: 10

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 20
            anchors.rightMargin: 20

            Label {
                Layout.fillWidth: true
                color: Theme.text
                font.pixelSize: 20
                font.weight: Font.DemiBold
                text: qsTr("Settings & Adjustments")
            }

            ThemeButton {
                Accessible.name: qsTr("Close settings")
                text: qsTr("✕ Close Settings (Esc)")
                highlighted: true
                onClicked: page.closeRequested()
            }
        }
    }

    // ── Scrollable Settings Content ──────────────────────────────────────────
    ScrollView {
        anchors.top: headerBar.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        clip: true
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(parent.width - 40, 640)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 16
            Layout.topMargin: 16
            Layout.bottomMargin: 24

            Item { height: 4 } // Top spacer

            // 1. Playback & UI Preferences
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: preferences.implicitHeight + 32
                color: Theme.surface
                border.color: Theme.border
                radius: Theme.panelRadius

                ColumnLayout {
                    id: preferences
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        color: Theme.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        text: qsTr("Playback & Appearance")
                    }

                    ThemeCheckBox {
                        Accessible.name: qsTr("Reduce motion")
                        checked: page.reduceMotion
                        text: qsTr("Reduce motion animations")
                        onToggled: page.reduceMotion = checked
                    }

                    Label {
                        Layout.fillWidth: true
                        color: Theme.textMuted
                        font.pixelSize: 12
                        text: qsTr("Playback controls and overlays transition instantly without animated fading.")
                        wrapMode: Text.WordWrap
                    }
                }
            }

            // 2. Subtitles and Audio
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: subtitleControls.implicitHeight + 32
                color: Theme.surface
                border.color: Theme.border
                radius: Theme.panelRadius

                ColumnLayout {
                    id: subtitleControls
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        color: Theme.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        text: qsTr("Subtitles & Audio")
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 8

                        ThemeButton {
                            Accessible.name: qsTr("Load subtitle file")
                            text: qsTr("📁 Load subtitle file...")
                            onClicked: subtitleDialog.open()
                        }

                        ThemeButton {
                            Accessible.name: qsTr("Cycle audio track")
                            text: qsTr("Next audio track")
                            onClicked: page.controller.cycleAudioTrack()
                        }

                        ThemeButton {
                            Accessible.name: qsTr("Cycle subtitle track")
                            text: qsTr("Next subtitle track")
                            onClicked: page.controller.cycleSubtitleTrack()
                        }
                    }

                    Label { color: Theme.textMuted; text: qsTr("Subtitle delay (seconds)") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Subtitle delay")
                        from: -10
                        to: 10
                        value: 0
                        onMoved: page.controller.setSubtitleDelay(value)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Subtitle scale") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Subtitle size")
                        from: 0.5
                        to: 3.0
                        value: 1.0
                        onMoved: page.controller.setSubtitleScale(value)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Audio sync delay (seconds)") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Audio delay")
                        from: -10
                        to: 10
                        value: 0
                        onMoved: page.controller.setAudioDelay(value)
                    }

                    ThemeCheckBox {
                        Accessible.name: qsTr("Loudness normalization")
                        text: qsTr("Loudness normalization (dialogue leveling)")
                        onToggled: page.controller.setNormalizationEnabled(checked)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Audio Equalizer preset") }
                    ComboBox {
                        Accessible.name: qsTr("Audio preset")
                        Layout.fillWidth: true
                        model: [qsTr("Flat (Default)"), qsTr("Voice Clarity"), qsTr("Bass Boost")]
                        onActivated: page.controller.setEqualizerPreset(index === 0
                            ? "" : index === 1 ? "equalizer=f=1000:g=4" : "equalizer=f=60:g=6")
                    }
                }
            }

            // 3. Video Adjustments
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: videoControls.implicitHeight + 32
                color: Theme.surface
                border.color: Theme.border
                radius: Theme.panelRadius

                ColumnLayout {
                    id: videoControls
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        color: Theme.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        text: qsTr("Video Color & Enhancements")
                    }

                    Label { color: Theme.textMuted; text: qsTr("Brightness") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Brightness")
                        from: -100
                        to: 100
                        value: 0
                        onMoved: page.controller.setBrightness(value)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Contrast") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Contrast")
                        from: -100
                        to: 100
                        value: 0
                        onMoved: page.controller.setContrast(value)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Saturation") }
                    ThemeSlider {
                        Layout.fillWidth: true
                        Accessible.name: qsTr("Saturation")
                        from: -100
                        to: 100
                        value: 0
                        onMoved: page.controller.setSaturation(value)
                    }

                    Label { color: Theme.textMuted; text: qsTr("Video filter preset") }
                    ComboBox {
                        Accessible.name: qsTr("Video filter preset")
                        Layout.fillWidth: true
                        model: [qsTr("None"), qsTr("Deband (smooth gradients)"), qsTr("Sharpen"), qsTr("Deband + Sharpen")]
                        onActivated: page.controller.setVideoFilterPreset(index === 0
                            ? "" : index === 1 ? "deband" : index === 2 ? "sharpen" : "deband,sharpen")
                    }

                    ThemeButton {
                        Accessible.name: qsTr("Take screenshot")
                        text: qsTr("📸 Capture Frame Screenshot")
                        onClicked: page.controller.screenshot()
                    }
                }
            }

            // 4. Keyboard Shortcuts & Help Reference
            Rectangle {
                Layout.fillWidth: true
                implicitHeight: helpSection.implicitHeight + 32
                color: Theme.surface
                border.color: Theme.border
                radius: Theme.panelRadius

                ColumnLayout {
                    id: helpSection
                    anchors.fill: parent
                    anchors.margins: 16
                    spacing: 10

                    Label {
                        color: Theme.text
                        font.weight: Font.DemiBold
                        font.pixelSize: 16
                        text: qsTr("Keyboard Shortcuts & Help")
                    }

                    GridLayout {
                        columns: 2
                        rowSpacing: 8
                        columnSpacing: 24

                        Label { color: Theme.accent; font.bold: true; text: "Space" }
                        Label { color: Theme.text; text: qsTr("Play / Pause") }

                        Label { color: Theme.accent; font.bold: true; text: "Left / Right" }
                        Label { color: Theme.text; text: qsTr("Seek backward / forward (5s)") }

                        Label { color: Theme.accent; font.bold: true; text: "Shift + Left/Right" }
                        Label { color: Theme.text; text: qsTr("Precise seek (1s)") }

                        Label { color: Theme.accent; font.bold: true; text: "Up / Down" }
                        Label { color: Theme.text; text: qsTr("Volume up / down (5%)") }

                        Label { color: Theme.accent; font.bold: true; text: "M" }
                        Label { color: Theme.text; text: qsTr("Toggle Mute") }

                        Label { color: Theme.accent; font.bold: true; text: "F / Double Click" }
                        Label { color: Theme.text; text: qsTr("Toggle Fullscreen") }

                        Label { color: Theme.accent; font.bold: true; text: "[ / ]" }
                        Label { color: Theme.text; text: qsTr("Playback speed − / + (0.25x)") }

                        Label { color: Theme.accent; font.bold: true; text: "Backspace" }
                        Label { color: Theme.text; text: qsTr("Reset speed to 1.00x") }

                        Label { color: Theme.accent; font.bold: true; text: "N / B" }
                        Label { color: Theme.text; text: qsTr("Next / Previous playlist item") }

                        Label { color: Theme.accent; font.bold: true; text: "P" }
                        Label { color: Theme.text; text: qsTr("Toggle Playlist drawer") }

                        Label { color: Theme.accent; font.bold: true; text: "S / Ctrl+," }
                        Label { color: Theme.text; text: qsTr("Toggle Settings") }

                        Label { color: Theme.accent; font.bold: true; text: "L" }
                        Label { color: Theme.text; text: qsTr("Set A-B Repeat Loop (A -> B -> Clear)") }

                        Label { color: Theme.accent; font.bold: true; text: "O / Ctrl+O" }
                        Label { color: Theme.text; text: qsTr("Open File Dialog") }

                        Label { color: Theme.accent; font.bold: true; text: "I" }
                        Label { color: Theme.text; text: qsTr("Media Information dialog") }

                        Label { color: Theme.accent; font.bold: true; text: "Alt+Up / Down" }
                        Label { color: Theme.text; text: qsTr("Reorder selected playlist item") }

                        Label { color: Theme.accent; font.bold: true; text: "F1" }
                        Label { color: Theme.text; text: qsTr("Help & Keyboard Shortcuts") }

                        Label { color: Theme.accent; font.bold: true; text: "Esc" }
                        Label { color: Theme.text; text: qsTr("Close Drawer / Exit Fullscreen") }
                    }
                }
            }

            Item { height: 24 } // Bottom padding
        }
    }
}
