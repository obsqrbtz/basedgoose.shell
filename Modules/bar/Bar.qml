//@ pragma ComponentBehavior: Bound
import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Modules/applauncher" as AppLauncher
import "../../Modules/shellmenu" as ShellMenu
import "../../Modules/clock" as Clock
import "../../Modules/notifications" as Notifications
import "../../Modules/power" as Power
import "../../Modules/systemstats" as SystemStats
import "../../Modules/systemtray" as SystemTray
import "../../Modules/workspaces" as Workspaces
import "../../Modules/bluetooth" as Bluetooth
import "../../Modules/mediaplayer" as MediaPlayer
import "../../Modules/volume" as Volume

PanelWindow {
    id: bar

    signal showPowerMenu()

    property var bluetoothPopup
    property var calendarPopup
    property var mediaPopup
    property var volumePopup
    property var notificationPopups
    property var notificationCenter
    property var shellMenuPopup
    property var powerMenuPopup

    readonly property string barPosition: Commons.Config.barPosition
    readonly property bool isHorizontal: barPosition === "top" || barPosition === "bottom"
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    Services.CpuMonitor { id: cpuMonitor }
    Services.MemoryMonitor { id: memoryMonitor }

    anchors.top: barPosition === "top" || barPosition === "left" || barPosition === "right"
    anchors.bottom: barPosition === "bottom" || barPosition === "left" || barPosition === "right"
    anchors.left: barPosition === "left" || barPosition === "top" || barPosition === "bottom"
    anchors.right: barPosition === "right" || barPosition === "top" || barPosition === "bottom"
    
    margins {
        top: (barPosition === "top" || barPosition === "left" || barPosition === "right") ? Commons.Config.barMargin : 0
        bottom: (barPosition === "bottom" || barPosition === "left" || barPosition === "right") ? Commons.Config.barMargin : 0
        left: (barPosition === "left" || barPosition === "top" || barPosition === "bottom") ? Commons.Config.barMargin : 0
        right: (barPosition === "right" || barPosition === "top" || barPosition === "bottom") ? Commons.Config.barMargin : 0
    }
    
    implicitWidth: isVertical ? Commons.Config.barWidth : undefined
    implicitHeight: isHorizontal ? Commons.Config.barHeight : undefined
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radius
        border.color: Commons.Theme.border
        border.width: 1
    }

    Bluetooth.BluetoothPopup {
        id: btPopup
    }

    Volume.VolumePopup {
        id: volPopup
    }

    Clock.CalendarPopup {
        id: calPopup
    }

    Component.onCompleted: {
        bar.bluetoothPopup = btPopup
        bar.volumePopup = volPopup
        bar.calendarPopup = calPopup
        
        console.log("[Bar] Position:", barPosition, "isVertical:", isVertical)
    }

    Component {
        id: shellMenuComponent
        ShellMenu.ShellMenuButton {
            id: shellMenuBtn
            barWindow: bar
            isVertical: bar.isVertical
            onClicked: {
                if (bar.shellMenuPopup) {
                    if (!bar.shellMenuPopup.shouldShow) {
                        bar.shellMenuPopup.positionNear(shellMenuBtn, bar)
                    }
                    bar.shellMenuPopup.toggle()
                }
            }
        }
    }

    Component {
        id: workspacesComponent
        Workspaces.Workspaces {
            barWindow: bar
            isVertical: bar.isVertical
        }
    }

    Component {
        id: mediaPlayerComponent
        MediaPlayer.MediaPlayer {
            barWindow: bar
            mediaPopup: bar.mediaPopup
            isVertical: bar.isVertical
        }
    }

    Component {
        id: systemStatsComponent
        SystemStats.SystemStats {
            cpuUsage: cpuMonitor.cpuUsage
            memUsed: memoryMonitor.memUsed
            memTotal: memoryMonitor.memTotal
            barWindow: bar
            isVertical: bar.isVertical
        }
    }

    Component {
        id: clockComponent
        Clock.Clock {
            barWindow: bar
            calendarPopup: bar.calendarPopup
            isVertical: bar.isVertical
        }
    }

    Component {
        id: systemTrayComponent
        SystemTray.SystemTrayComponent {
            barWindow: bar
            isVertical: bar.isVertical
        }
    }

    Component {
        id: volumeComponent
        Volume.Volume {
            barWindow: bar
            volumePopup: bar.volumePopup
            isVertical: bar.isVertical
        }
    }

    Component {
        id: bluetoothComponent
        Bluetooth.Bluetooth {
            barWindow: bar
            bluetoothPopup: bar.bluetoothPopup
            isVertical: bar.isVertical
        }
    }

    Component {
        id: notificationsComponent
        Notifications.NotificationButton {
            notificationCenter: bar.notificationCenter
            barWindow: bar
            isVertical: bar.isVertical
        }
    }

    Component {
        id: powerComponent
        Power.PowerButton {
            barWindow: bar
            powerMenuPopup: bar.powerMenuPopup
            isVertical: bar.isVertical
            onClicked: bar.showPowerMenu()
        }
    }

    function getModuleComponent(moduleName) {
        switch (moduleName) {
            case "shellmenu": return shellMenuComponent
            case "workspaces": return workspacesComponent
            case "mediaplayer": return mediaPlayerComponent
            case "systemstats": return systemStatsComponent
            case "clock": return clockComponent
            case "systemtray": return systemTrayComponent
            case "volume": return volumeComponent
            case "bluetooth": return bluetoothComponent
            case "notifications": return notificationsComponent
            case "power": return powerComponent
            default: return null
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Commons.Config.barPadding
        spacing: 0
        visible: isHorizontal

        // Start section
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.left || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: bar.getModuleComponent(modelData)
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Item { Layout.fillWidth: true }

        // Center section
        RowLayout {
            Layout.alignment: Qt.AlignVCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.center || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: bar.getModuleComponent(modelData)
                    Layout.alignment: Qt.AlignVCenter
                }
            }
        }

        Item { Layout.fillWidth: true }

        // End section
        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            implicitWidth: rightRowH.implicitWidth + 20
            implicitHeight: Commons.Config.componentHeight
            color: Commons.Theme.surfaceBase
            radius: Commons.Theme.radius

            RowLayout {
                id: rightRowH
                anchors.centerIn: parent
                spacing: 10

                Repeater {
                    model: Commons.Config.barModules.right || []
                    delegate: Loader {
                        required property string modelData
                        sourceComponent: bar.getModuleComponent(modelData)
                        Layout.alignment: Qt.AlignVCenter
                    }
                }
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Commons.Config.barPadding
        spacing: 0
        visible: isVertical

        // Start section
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.left || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: bar.getModuleComponent(modelData)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Item { Layout.fillHeight: true }

        // Center section
        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.center || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: bar.getModuleComponent(modelData)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        Item { Layout.fillHeight: true }

        // End section
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            implicitWidth: Commons.Config.barWidth - Commons.Config.barPadding * 2
            implicitHeight: rightColV.implicitHeight + 16
            color: Commons.Theme.surfaceBase
            radius: Commons.Theme.radius

            ColumnLayout {
                id: rightColV
                anchors.centerIn: parent
                spacing: 8

                Repeater {
                    model: Commons.Config.barModules.right || []
                    delegate: Loader {
                        required property string modelData
                        sourceComponent: bar.getModuleComponent(modelData)
                        Layout.alignment: Qt.AlignHCenter
                    }
                }
            }
        }
    }
}
