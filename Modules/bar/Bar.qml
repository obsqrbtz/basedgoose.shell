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
import "../../Modules/shellmenu" as ShellMenu

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

    Services.CpuMonitor { id: cpuMonitor }
    Services.MemoryMonitor { id: memoryMonitor }

    anchors.top: true
    anchors.left: true
    anchors.right: true
    margins {
        top: Commons.Config.barMargin
        left: Commons.Config.barMargin
        right: Commons.Config.barMargin
    }
    implicitHeight: Commons.Config.barHeight
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
    }

    // Left section
    RowLayout {
        id: leftSection
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.bottom: parent.bottom
        anchors.margins: Commons.Config.barPadding
        spacing: Commons.Config.barSpacing

        ShellMenu.ShellMenuButton {
            onClicked: {
                if (bar.shellMenuPopup) {
                    bar.shellMenuPopup.toggle()
                }
            }
        }

        Workspaces.Workspaces {}

        MediaPlayer.MediaPlayer {
            barWindow: bar.barWindow
            mediaPopup: bar.mediaPopup
        }
    }

    // Center section - anchored to true center
    SystemStats.SystemStats {
        id: centerStats
        anchors.centerIn: parent
        width: implicitWidth
        height: implicitHeight
        cpuUsage: cpuMonitor.cpuUsage
        memUsed: memoryMonitor.memUsed
        memTotal: memoryMonitor.memTotal
    }

    // Right section
    Rectangle {
        anchors.right: parent.right
        anchors.rightMargin: Commons.Config.barPadding
        anchors.verticalCenter: parent.verticalCenter
        width: rightRow.width + 20
        height: Commons.Config.componentHeight
        color: Commons.Theme.surfaceBase
        radius: Commons.Theme.radius

        RowLayout {
            id: rightRow
            anchors.centerIn: parent
            spacing: 10

            Clock.Clock {
                barWindow: bar
                calendarPopup: bar.calendarPopup
            }

            SystemTray.SystemTrayComponent {
                barWindow: bar
            }

            Volume.Volume {
                barWindow: bar
                volumePopup: bar.volumePopup
            }

            Bluetooth.Bluetooth {
                barWindow: bar
                bluetoothPopup: bar.bluetoothPopup
            }

            Notifications.NotificationButton {
                notificationCenter: bar.notificationCenter
            }

            Power.PowerButton {
                barWindow: bar
                powerMenuPopup: bar.powerMenuPopup
                onClicked: bar.showPowerMenu()
            }
        }
    }
}
