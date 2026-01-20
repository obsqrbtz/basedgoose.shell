import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.SystemTray
import "../../Services" as Services
import "../../Widgets" as Widgets

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
        top: Services.Config.barMargin
        left: Services.Config.barMargin
        right: Services.Config.barMargin
    }
    implicitHeight: Services.Config.barHeight
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color: Services.Theme.background
        radius: Services.Theme.radius
        border.color: Services.Theme.border
        border.width: 1
    }

    Widgets.BluetoothPopupWindow {
        id: btPopup
    }

    Widgets.VolumePopupWindow {
        id: volPopup
    }

    Component.onCompleted: {
        bar.bluetoothPopup = btPopup
        bar.volumePopup = volPopup
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: Services.Config.barPadding
        spacing: Services.Config.barSpacing

        Widgets.AppLauncherButton {
            onClicked: bar.showAppLauncher()
        }

        Widgets.Workspaces {}
                    Rectangle {
                id: mediaModule
                height: 28
                width: mediaPlayerLoader.implicitWidth + 16
                visible: Services.Players.active
                
                radius: 14
                color: Services.Theme.foreground
                
                border.width: 1
                border.color: Services.Theme.surfaceBorder
                
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
                    source: "../../Widgets/MediaPlayer.qml"
                    
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

        Widgets.SystemStats {
            cpuUsage: cpuMonitor.cpuUsage
            memUsed: memoryMonitor.memUsed
            memTotal: memoryMonitor.memTotal
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: rightRow.width + 20
            height: Services.Config.componentHeight
            color: Services.Theme.surfaceBase
            radius: Services.Config.componentRadius

            RowLayout {
                id: rightRow
                spacing: 10

                Item { width: Services.Config.componentPadding / 2 }

                Loader {
                    id: volumeLoader
                    source: "../../Widgets/Volume.qml"
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
                    Layout.leftMargin: Services.Config.componentPadding / 2
                }

                Rectangle {
                    id: bluetoothContainer
                    height: Services.Config.componentHeight
                    color: "transparent"
                    radius: 14
                    Layout.preferredWidth: Math.min(140, Math.max(44, (bluetoothLoader.status === Loader.Ready && bluetoothLoader.item) ? bluetoothLoader.implicitWidth + Services.Config.componentPadding : 44))
                    Layout.alignment: Qt.AlignVCenter
                    Layout.rightMargin: Services.Config.componentPadding / 2
                    clip: true

                    Loader {
                        id: bluetoothLoader
                        source: "../../Widgets/Bluetooth.qml"
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

                Widgets.Clock {}

                Widgets.SystemTrayComponent {
                    barWindow: bar
                }

                Widgets.NotificationButton {
                    notificationCenter: bar.notificationCenter
                }

                Widgets.PowerButton {
                    onClicked: bar.showPowerMenu()
                }
            }
        }
    }
}
