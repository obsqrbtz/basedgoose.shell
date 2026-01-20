import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Modules/applauncher" as AppLauncher
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
    signal showAppLauncher()

    property var bluetoothPopup
    property var mediaPopup
    property var volumePopup
    property var notificationPopups
    property var notificationCenter

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

    Component.onCompleted: {
        bar.bluetoothPopup = btPopup
        bar.volumePopup = volPopup
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Commons.Config.barPadding
        spacing: Commons.Config.barSpacing

        AppLauncher.AppLauncherButton {
            onClicked: bar.showAppLauncher()
        }

        Workspaces.Workspaces {}
                    Rectangle {
                id: mediaModule
                height: 28
                width: mediaPlayerLoader.implicitWidth + 16
                visible: Services.Players.active
                
                radius: 14
                color: Commons.Theme.foreground
                
                border.width: 1
                border.color: Commons.Theme.surfaceBorder
                
                clip: true
                
                Behavior on width {
                    NumberAnimation { 
                        duration: 400
                        easing.bezierCurve: [0.34, 1.56, 0.64, 1]
                    }
                }
                
                // Top highlight
                Rectangle {
                    anchors.top: parent.top
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.margins: 1
                    height: parent.height / 2
                    radius: parent.radius - 1
                    
                    gradient: Gradient {
                        GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
                        GradientStop { position: 1.0; color: "transparent" }
                    }
                }
                
                Loader {
                    id: mediaPlayerLoader
                    anchors.centerIn: parent
                    asynchronous: true
                    source: "../../Modules/mediaplayer/MediaPlayer.qml"
                    
                    Binding {
                        target: mediaPlayerLoader.item
                        property: "barWindow"
                        value: bar.barWindow
                        when: mediaPlayerLoader.status === Loader.Ready && bar.barWindow !== undefined
                        restoreMode: Binding.RestoreBinding
                    }
                    
                    Binding {
                        target: mediaPlayerLoader.item
                        property: "mediaPopup"
                        value: bar.mediaPopup
                        when: mediaPlayerLoader.status === Loader.Ready && bar.mediaPopup !== undefined
                        restoreMode: Binding.RestoreBinding
                    }
                }
            }

        Item { Layout.fillWidth: true }

        SystemStats.SystemStats {
            cpuUsage: cpuMonitor.cpuUsage
            memUsed: memoryMonitor.memUsed
            memTotal: memoryMonitor.memTotal
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: rightRow.width + 20
            height: Commons.Config.componentHeight
            color: Commons.Theme.surfaceBase
            radius: Commons.Config.componentRadius

            RowLayout {
                id: rightRow
                spacing: 10

                Item { width: Commons.Config.componentPadding / 2 }

                Loader {
                    id: volumeLoader
                    source: "../../Modules/volume/Volume.qml"
                    asynchronous: true
                    Binding {
                        target: volumeLoader.item
                        property: "barWindow"
                        value: bar
                    }
                    Binding {
                        target: volumeLoader.item
                        property: "volumePopup"
                        value: bar.volumePopup
                    }
                    Layout.leftMargin: Commons.Config.componentPadding / 2
                }

                Rectangle {
                    id: bluetoothContainer
                    height: Commons.Config.componentHeight
                    color: "transparent"
                    radius: 14
                    Layout.preferredWidth: Math.min(140, Math.max(44, (bluetoothLoader.status === Loader.Ready && bluetoothLoader.item) ? bluetoothLoader.implicitWidth + Commons.Config.componentPadding : 44))
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: Commons.Config.componentPadding / 2
                    clip: true

                    Loader {
                        id: bluetoothLoader
                        source: "../../Modules/bluetooth/Bluetooth.qml"
                        asynchronous: true
                        anchors.centerIn: parent
                        Binding {
                            target: bluetoothLoader.item
                            property: "barWindow"
                            value: bar
                        }
                        Binding {
                            target: bluetoothLoader.item
                            property: "bluetoothPopup"
                            value: bar.bluetoothPopup
                        }
                    }
                }

                Clock.Clock {}

                SystemTray.SystemTrayComponent {
                    barWindow: bar
                }

                Notifications.NotificationButton {
                    notificationCenter: bar.notificationCenter
                }

                Power.PowerButton {
                    onClicked: bar.showPowerMenu()
                }
            }
        }
    }
}
