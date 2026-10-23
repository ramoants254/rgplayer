import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Popup {
    id: root

    property var controller
    property var info: ({})

    function refresh() {
        if (controller) {
            info = controller.mediaInfo()
        }
    }

    onAboutToShow: refresh()

    modal: true
    focus: true
    closePolicy: Popup.CloseOnEscape | Popup.CloseOnPressOutside
    anchors.centerIn: Overlay.overlay
    width: Math.min(520, parent ? parent.width - 40 : 520)
    padding: 24

    background: Rectangle {
        color: Theme.surface
        border.color: Theme.border
        border.width: 1
        radius: Theme.panelRadius
    }

    contentItem: ColumnLayout {
        spacing: 16

        // Header
        RowLayout {
            Layout.fillWidth: true

            Label {
                Layout.fillWidth: true
                text: qsTr("Media Information")
                color: Theme.text
                font.pixelSize: 18
                font.weight: Font.Bold
            }

            ThemeButton {
                text: qsTr("Close")
                Accessible.name: qsTr("Close media information dialog")
                onClicked: root.close()
            }
        }

        Rectangle {
            Layout.fillWidth: true
            height: 1
            color: Theme.border
        }

        ScrollView {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(contentCol.implicitHeight, 380)
            clip: true

            ColumnLayout {
                id: contentCol
                width: parent.width
                spacing: 14

                // Section: General
                Label {
                    text: qsTr("GENERAL")
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.Bold
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 16
                    Layout.fillWidth: true

                    Label { text: qsTr("File Name:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.fileName || qsTr("None")
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        Layout.fillWidth: true
                        elide: Text.ElideRight
                    }

                    Label { text: qsTr("Path:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.filePath || qsTr("None")
                        color: Theme.text
                        font.pixelSize: 11
                        Layout.fillWidth: true
                        elide: Text.ElideMiddle
                    }

                    Label { text: qsTr("Format:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.fileFormat || qsTr("Unknown")
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("File Size:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: {
                            const bytes = Number(root.info.fileSize)
                            if (!bytes || isNaN(bytes)) return qsTr("Unknown")
                            if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(2) + " GB"
                            if (bytes >= 1048576) return (bytes / 1048576).toFixed(1) + " MB"
                            return (bytes / 1024).toFixed(0) + " KB"
                        }
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Duration:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: {
                            const sec = Math.floor(Number(root.info.duration) || 0)
                            const h = Math.floor(sec / 3600)
                            const m = Math.floor((sec % 3600) / 60)
                            const s = sec % 60
                            const p = (v) => v < 10 ? "0" + v : "" + v
                            return h > 0 ? `${p(h)}:${p(m)}:${p(s)}` : `${p(m)}:${p(s)}`
                        }
                        color: Theme.text
                        font.pixelSize: 12
                    }
                }

                // Section: Video
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border; visible: !!root.info.videoCodec }

                Label {
                    text: qsTr("VIDEO")
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    visible: !!root.info.videoCodec
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 16
                    Layout.fillWidth: true
                    visible: !!root.info.videoCodec

                    Label { text: qsTr("Codec:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: (root.info.videoCodec || "").toUpperCase()
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Label { text: qsTr("Resolution:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.width && root.info.height
                            ? `${root.info.width} × ${root.info.height}`
                            : qsTr("Unknown")
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Frame Rate:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.fps ? `${Number(root.info.fps).toFixed(2)} fps` : qsTr("Unknown")
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Bitrate:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: {
                            const bps = Number(root.info.videoBitrate)
                            if (!bps || isNaN(bps)) return qsTr("Unknown")
                            if (bps >= 1000000) return (bps / 1000000).toFixed(2) + " Mbps"
                            return (bps / 1000).toFixed(0) + " kbps"
                        }
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Hardware Dec:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.hwdec || qsTr("None (Software)")
                        color: root.info.hwdec && root.info.hwdec !== "no" ? "#44D07B" : Theme.textMuted
                        font.pixelSize: 12
                    }
                }

                // Section: Audio
                Rectangle { Layout.fillWidth: true; height: 1; color: Theme.border; visible: !!root.info.audioCodec }

                Label {
                    text: qsTr("AUDIO")
                    color: Theme.accent
                    font.pixelSize: 11
                    font.weight: Font.Bold
                    visible: !!root.info.audioCodec
                }

                GridLayout {
                    columns: 2
                    rowSpacing: 6
                    columnSpacing: 16
                    Layout.fillWidth: true
                    visible: !!root.info.audioCodec

                    Label { text: qsTr("Codec:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: (root.info.audioCodec || "").toUpperCase()
                        color: Theme.text
                        font.pixelSize: 12
                        font.weight: Font.DemiBold
                    }

                    Label { text: qsTr("Channels:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: {
                            const ch = Number(root.info.channels)
                            if (ch === 1) return qsTr("1 channel (Mono)")
                            if (ch === 2) return qsTr("2 channels (Stereo)")
                            if (ch === 6) return qsTr("6 channels (5.1 Surround)")
                            if (ch === 8) return qsTr("8 channels (7.1 Surround)")
                            return ch ? `${ch} channels` : qsTr("Unknown")
                        }
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Sample Rate:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: root.info.sampleRate ? `${root.info.sampleRate} Hz` : qsTr("Unknown")
                        color: Theme.text
                        font.pixelSize: 12
                    }

                    Label { text: qsTr("Bitrate:"); color: Theme.textMuted; font.pixelSize: 12 }
                    Label {
                        text: {
                            const bps = Number(root.info.audioBitrate)
                            if (!bps || isNaN(bps)) return qsTr("Unknown")
                            return (bps / 1000).toFixed(0) + " kbps"
                        }
                        color: Theme.text
                        font.pixelSize: 12
                    }
                }
            }
        }
    }
}
