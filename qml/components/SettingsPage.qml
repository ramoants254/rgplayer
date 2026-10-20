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
        onAccepted: page.controller.loadSubtitle(selectedFile.toLocalFile())
    }

    ColumnLayout {
        anchors.centerIn: parent
        width: Math.min(parent.width - 48, 640)
        spacing: 18

        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                color: Theme.text
                font.pixelSize: 24
                font.weight: Font.DemiBold
                text: qsTr("Settings")
            }

            ThemeButton {
                Accessible.name: qsTr("Close settings")
                text: qsTr("Close")
                onClicked: page.closeRequested()
            }
        }

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
                spacing: 12

                Label {
                    color: Theme.text
                    font.weight: Font.DemiBold
                    text: qsTr("Playback")
                }

                ThemeCheckBox {
                    Accessible.name: qsTr("Reduce motion")
                    checked: page.reduceMotion
                    text: qsTr("Reduce motion")
                    onToggled: page.reduceMotion = checked
                }

                Label {
                    Layout.fillWidth: true
                    color: Theme.textMuted
                    text: qsTr("Playback controls fade more gently when enabled.")
                    wrapMode: Text.WordWrap
                }
            }
        }

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
                    text: qsTr("Subtitles and audio")
                }

                ThemeButton {
                    Accessible.name: qsTr("Load subtitle file")
                    text: qsTr("Load subtitle")
                    onClicked: subtitleDialog.open()
                }

                Label { color: Theme.textMuted; text: qsTr("Subtitle delay") }
                ThemeSlider {
                    Layout.fillWidth: true
                    Accessible.name: qsTr("Subtitle delay")
                    from: -10
                    to: 10
                    value: 0
                    onMoved: page.controller.setSubtitleDelay(value)
                }

                Label { color: Theme.textMuted; text: qsTr("Subtitle size") }
                ThemeSlider {
                    Layout.fillWidth: true
                    Accessible.name: qsTr("Subtitle size")
                    from: 0.5
                    to: 3
                    value: 1
                    onMoved: page.controller.setSubtitleScale(value)
                }

                Label { color: Theme.textMuted; text: qsTr("Audio delay") }
                ThemeSlider {
                    Layout.fillWidth: true
                    Accessible.name: qsTr("Audio delay")
                    from: -10
                    to: 10
                    value: 0
                    onMoved: page.controller.setAudioDelay(value)
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
        }

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
                    text: qsTr("Video")
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

                ThemeButton {
                    Accessible.name: qsTr("Take screenshot")
                    text: qsTr("Screenshot")
                    onClicked: page.controller.screenshot()
                }

                ThemeCheckBox {
                    Accessible.name: qsTr("Force ASS subtitle styling")
                    text: qsTr("Force ASS subtitle styling")
                    onToggled: page.controller.setSubtitleOverride(checked)
                }

                Label { color: Theme.textMuted; text: qsTr("Subtitle font size") }
                ThemeSlider {
                    Layout.fillWidth: true
                    Accessible.name: qsTr("Subtitle font size")
                    from: 8
                    to: 96
                    value: 55
                    onMoved: page.controller.setSubtitleFontSize(value)
                }

                Label { color: Theme.textMuted; text: qsTr("Subtitle codepage") }
                ComboBox {
                    Accessible.name: qsTr("Subtitle codepage")
                    Layout.fillWidth: true
                    model: [qsTr("Automatic"), qsTr("UTF-8"), qsTr("Windows-1252")]
                    onActivated: page.controller.setSubtitleCodepage(index === 0
                        ? "enca:en" : index === 1 ? "utf-8" : "cp1252")
                }

                Label { color: Theme.textMuted; text: qsTr("Audio preset") }
                ComboBox {
                    Accessible.name: qsTr("Audio preset")
                    Layout.fillWidth: true
                    model: [qsTr("Flat"), qsTr("Voice"), qsTr("Bass")]
                    onActivated: page.controller.setEqualizerPreset(index === 0
                        ? "" : index === 1 ? "equalizer=f=1000:g=4" : "equalizer=f=60:g=6")
                }

                ThemeCheckBox {
                    Accessible.name: qsTr("Loudness normalization")
                    text: qsTr("Loudness normalization")
                    onToggled: page.controller.setNormalizationEnabled(checked)
                }

                Label { color: Theme.textMuted; text: qsTr("Video filter preset") }
                ComboBox {
                    Accessible.name: qsTr("Video filter preset")
                    Layout.fillWidth: true
                    model: [qsTr("None"), qsTr("Deband"), qsTr("Sharpen"), qsTr("Deband + sharpen")]
                    onActivated: page.controller.setVideoFilterPreset(index === 0
                        ? "" : index === 1 ? "deband" : index === 2 ? "sharpen" : "deband,sharpen")
                }
            }
        }
    }
}
