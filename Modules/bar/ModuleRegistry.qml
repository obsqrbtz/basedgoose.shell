import QtQuick 6.10
import "../shellmenu" as ShellMenu
import "../clock" as Clock
import "../notifications" as Notifications
import "../power" as Power
import "../systemstats" as SystemStats
import "../systemtray" as SystemTray
import "../workspaces" as Workspaces
import "../bluetooth" as Bluetooth
import "../network" as Network
import "../mediaplayer" as MediaPlayer
import "../volume" as Volume

QtObject {
    id: registry

    property var barWindow
    property bool isVertical: false

    property real cpuUsage: 0
    property real memUsed:  0
    property real memTotal: 0

    property var shellMenuPopup
    property var powerMenuPopup
    property var notificationCenter
    property var mediaPopup

    property var bluetoothPopup
    property var networkPopup
    property var volumePopup
    property var calendarPopup

    property Component shellMenuComp: Component {
        ShellMenu.ShellMenuButton {
            id: shellMenuBtn
            barWindow:  registry.barWindow
            isVertical: registry.isVertical
            onClicked: {
                if (registry.shellMenuPopup) {
                    if (!registry.shellMenuPopup.shouldShow)
                        registry.shellMenuPopup.positionNear(shellMenuBtn, registry.barWindow)
                    registry.shellMenuPopup.toggle()
                }
            }
        }
    }

    property Component workspacesComp: Component {
        Workspaces.Workspaces {
            barWindow:  registry.barWindow
            isVertical: registry.isVertical
        }
    }

    property Component mediaPlayerComp: Component {
        MediaPlayer.MediaPlayer {
            barWindow:  registry.barWindow
            mediaPopup: registry.mediaPopup
            isVertical: registry.isVertical
        }
    }

    property Component systemStatsComp: Component {
        SystemStats.SystemStats {
            cpuUsage:   registry.cpuUsage
            memUsed:    registry.memUsed
            memTotal:   registry.memTotal
            barWindow:  registry.barWindow
            isVertical: registry.isVertical
        }
    }

    property Component clockComp: Component {
        Clock.Clock {
            barWindow:     registry.barWindow
            calendarPopup: registry.calendarPopup
            isVertical:    registry.isVertical
        }
    }

    property Component systemTrayComp: Component {
        SystemTray.SystemTrayComponent {
            barWindow:  registry.barWindow
            isVertical: registry.isVertical
        }
    }

    property Component volumeComp: Component {
        Volume.Volume {
            barWindow:   registry.barWindow
            volumePopup: registry.volumePopup
            isVertical:  registry.isVertical
        }
    }

    property Component bluetoothComp: Component {
        Bluetooth.Bluetooth {
            barWindow:      registry.barWindow
            bluetoothPopup: registry.bluetoothPopup
            isVertical:     registry.isVertical
        }
    }

    property Component networkComp: Component {
        Network.Network {
            barWindow:    registry.barWindow
            networkPopup: registry.networkPopup
            isVertical:   registry.isVertical
        }
    }

    property Component notificationsComp: Component {
        Notifications.NotificationButton {
            notificationCenter: registry.notificationCenter
            barWindow:          registry.barWindow
            isVertical:         registry.isVertical
        }
    }

    property Component powerComp: Component {
        Power.PowerButton {
            barWindow:      registry.barWindow
            powerMenuPopup: registry.powerMenuPopup
            isVertical:     registry.isVertical
            onClicked:      if (registry.barWindow) registry.barWindow.showPowerMenu()
        }
    }

    function getBarComponent(name) {
        switch (name) {
            case "shellmenu":     return shellMenuComp
            case "workspaces":    return workspacesComp
            case "mediaplayer":   return mediaPlayerComp
            case "systemstats":   return systemStatsComp
            case "clock":         return clockComp
            case "systemtray":    return systemTrayComp
            case "volume":        return volumeComp
            case "bluetooth":     return bluetoothComp
            case "network":       return networkComp
            case "notifications": return notificationsComp
            case "power":         return powerComp
            default:              return null
        }
    }
}
