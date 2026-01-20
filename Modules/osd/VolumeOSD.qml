import Quickshell
import Quickshell.Wayland
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../Services" as Services

PanelWindow {
    id: root

    visible: showing
    color: "transparent"

    property bool showing: false
    property bool initialized: false
    property var volumePopup

    readonly property var volumeMonitor: Services.VolumeMonitor
    readonly property int currentVolume: volumeMonitor.percentage
    readonly property bool currentMuted: volumeMonitor.muted

    property int lastVolume: 0
    property bool lastMuted: false

    anchors {
        top: true
        right: true
    }

    margins {
        top: 20
        right: 12
    }

    implicitWidth: 250
    implicitHeight: 45

    mask: Region { item: container }

    Timer {
        id: hideTimer
        interval: 2000
        onTriggered: root.showing = false
    }

    function triggerOSD() {
        if (volumePopup && (volumePopup.shouldShow || (volumePopup.container && volumePopup.container.opacity > 0))) {
            return
        }

        showing = true
        hideTimer.restart()
    }

    function syncState() {
        if (!initialized) {
            lastVolume = currentVolume
            lastMuted = currentMuted
            initialized = true
            return
        }

        if (currentVolume !== lastVolume || currentMuted !== lastMuted) {
            triggerOSD()
        }

        lastVolume = currentVolume
        lastMuted = currentMuted
    }
    

    onCurrentVolumeChanged: syncState()
    onCurrentMutedChanged: syncState()

    Rectangle {
        id: container
        anchors.fill: parent
        radius: 16

        color: Qt.rgba(
                   Services.Theme.background.r,
                   Services.Theme.background.g,
                   Services.Theme.background.b,
                   0.95
               )

        border.width: 1
        border.color: Services.Theme.border

        opacity: root.showing ? 1.0 : 0.0
        scale: root.showing ? 1.0 : 0.9
        transformOrigin: Item.Center

        RowLayout {
            anchors.centerIn: parent
            width: parent.width - 24
            spacing: 12

            Text {
                text: root.currentMuted
                      ? "󰖁"
                      : (root.currentVolume > 66
                         ? "󰕾"
                         : (root.currentVolume > 33 ? "󰖀" : "󰕿"))
                font.family: "Material Design Icons"
                font.pixelSize: 20
                color: root.currentMuted
                       ? Services.Theme.foreground
                       : Services.Theme.secondary
                Layout.alignment: Qt.AlignVCenter
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 6
                Layout.alignment: Qt.AlignVCenter
                radius: 3
                color: Qt.rgba(
                    Services.Theme.foreground.r,
                    Services.Theme.foreground.g,
                    Services.Theme.foreground.b,
                    0.2
                )

                Rectangle {
                    width: parent.width * (root.currentVolume / 100)
                    height: parent.height
                    radius: 3
                    color: root.currentMuted
                           ? Services.Theme.foreground
                           : Services.Theme.secondary

                    Behavior on width {
                        NumberAnimation {
                            duration: 120
                            easing.type: Easing.OutCubic
                        }
                    }

                    Behavior on color {
                        ColorAnimation { duration: 120 }
                    }
                }
            }

            Text {
                text: root.currentVolume + "%"
                color: Services.Theme.foreground
                font.family: "Inter"
                font.pixelSize: 13
                font.weight: Font.DemiBold
                Layout.preferredWidth: 36
                Layout.alignment: Qt.AlignVCenter
                horizontalAlignment: Text.AlignRight
            }
        }
    }
}