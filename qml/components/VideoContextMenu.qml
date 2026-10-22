import QtQuick
import QtQuick.Controls

Menu {
    id: contextMenu

    property var controller

    // Shared styling for all menu items
    palette.window: Theme.surface
    palette.windowText: Theme.text
    palette.highlight: Theme.accent
    palette.highlightedText: Theme.accentText

    background: Rectangle {
        implicitWidth: 240
        color: Qt.rgba(0.08, 0.08, 0.10, 0.96)
        border.color: Theme.border
        radius: Theme.controlRadius
    }

    // ── Play / Pause ────────────────────────────────────────────────────────
    MenuItem {
        Accessible.name: contextMenu.controller && contextMenu.controller.paused
            ? qsTr("Play") : qsTr("Pause")
        text: contextMenu.controller && contextMenu.controller.paused
            ? qsTr("▶  Play") : qsTr("⏸  Pause")
        onTriggered: contextMenu.controller.togglePause()

        background: Rectangle {
            color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
            radius: 4
        }
        contentItem: Label {
            text: parent.text
            color: parent.highlighted ? Theme.accent : Theme.text
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
    }

    MenuSeparator {
        contentItem: Rectangle { implicitHeight: 1; color: Theme.border }
    }

    // ── Aspect Ratio ────────────────────────────────────────────────────────
    Menu {
        title: qsTr("📐  Aspect Ratio")

        palette.window: Theme.surface
        palette.windowText: Theme.text
        palette.highlight: Theme.accent
        palette.highlightedText: Theme.accentText

        background: Rectangle {
            implicitWidth: 200
            color: Qt.rgba(0.08, 0.08, 0.10, 0.96)
            border.color: Theme.border
            radius: Theme.controlRadius
        }

        Repeater {
            model: [
                { label: qsTr("Auto (Original)"), value: "-1" },
                { label: qsTr("16:9  Widescreen"), value: "16:9" },
                { label: qsTr("4:3   Standard"), value: "4:3" },
                { label: qsTr("2.35:1  Cinematic"), value: "2.35:1" },
                { label: qsTr("1:1   Square"), value: "1:1" },
            ]
            delegate: MenuItem {
                text: modelData.label
                onTriggered: contextMenu.controller.setAspectRatio(modelData.value)

                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
                    radius: 4
                }
                contentItem: Label {
                    text: parent.text
                    color: parent.highlighted ? Theme.accent : Theme.text
                    font.pixelSize: 13
                    leftPadding: 12
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    // ── Playback Speed ──────────────────────────────────────────────────────
    Menu {
        title: qsTr("⏩  Speed")

        palette.window: Theme.surface
        palette.windowText: Theme.text
        palette.highlight: Theme.accent
        palette.highlightedText: Theme.accentText

        background: Rectangle {
            implicitWidth: 180
            color: Qt.rgba(0.08, 0.08, 0.10, 0.96)
            border.color: Theme.border
            radius: Theme.controlRadius
        }

        Repeater {
            model: [
                { label: qsTr("0.25x"), speed: 0.25 },
                { label: qsTr("0.50x"), speed: 0.50 },
                { label: qsTr("0.75x"), speed: 0.75 },
                { label: qsTr("1.00x  (Normal)"), speed: 1.0 },
                { label: qsTr("1.25x"), speed: 1.25 },
                { label: qsTr("1.50x"), speed: 1.50 },
                { label: qsTr("2.00x"), speed: 2.0 },
                { label: qsTr("4.00x"), speed: 4.0 },
            ]
            delegate: MenuItem {
                text: modelData.label
                onTriggered: contextMenu.controller.speed = modelData.speed

                background: Rectangle {
                    color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
                    radius: 4
                }
                contentItem: Label {
                    text: parent.text
                    color: {
                        if (parent.highlighted) return Theme.accent
                        if (contextMenu.controller && Math.abs(contextMenu.controller.speed - modelData.speed) < 0.01)
                            return Theme.accent
                        return Theme.text
                    }
                    font.pixelSize: 13
                    font.weight: contextMenu.controller && Math.abs(contextMenu.controller.speed - modelData.speed) < 0.01
                        ? Font.Bold : Font.Normal
                    leftPadding: 12
                    verticalAlignment: Text.AlignVCenter
                }
            }
        }
    }

    MenuSeparator {
        contentItem: Rectangle { implicitHeight: 1; color: Theme.border }
    }

    // ── Audio Track ─────────────────────────────────────────────────────────
    MenuItem {
        Accessible.name: qsTr("Next audio track")
        text: qsTr("🔊  Next Audio Track")
        onTriggered: contextMenu.controller.cycleAudioTrack()

        background: Rectangle {
            color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
            radius: 4
        }
        contentItem: Label {
            text: parent.text
            color: parent.highlighted ? Theme.accent : Theme.text
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
    }

    // ── Subtitle Track ──────────────────────────────────────────────────────
    MenuItem {
        Accessible.name: qsTr("Next subtitle track")
        text: qsTr("💬  Next Subtitle Track")
        onTriggered: contextMenu.controller.cycleSubtitleTrack()

        background: Rectangle {
            color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
            radius: 4
        }
        contentItem: Label {
            text: parent.text
            color: parent.highlighted ? Theme.accent : Theme.text
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
    }

    MenuSeparator {
        contentItem: Rectangle { implicitHeight: 1; color: Theme.border }
    }

    // ── Screenshot ──────────────────────────────────────────────────────────
    MenuItem {
        Accessible.name: qsTr("Screenshot")
        text: qsTr("📸  Screenshot")
        onTriggered: contextMenu.controller.screenshot()

        background: Rectangle {
            color: parent.highlighted ? Qt.rgba(1, 0.42, 0, 0.18) : "transparent"
            radius: 4
        }
        contentItem: Label {
            text: parent.text
            color: parent.highlighted ? Theme.accent : Theme.text
            font.pixelSize: 13
            leftPadding: 12
            verticalAlignment: Text.AlignVCenter
        }
    }
}
