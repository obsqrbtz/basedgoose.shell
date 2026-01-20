//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick 6.10
import "./Modules/bar" as BarModule
import "./Modules/power" as Power
import "./Modules/applauncher" as AppLauncher
import "./Modules/bluetooth" as Bluetooth
import "./Modules/mediaplayer" as MediaPlayer
import "./Modules/volume" as Volume
import "./Modules/notifications" as Notifications
import "./Modules/osd" as Osd
import "./Modules/wallpaper" as Wallpaper
import "./Services" as Services

Scope {
    readonly property var notificationServer: Services.NotificationServer
    
    Component.onCompleted: {
        if (notificationServer && notificationServer.server) {
            console.log("[Shell] Notification server initialized")
        } else {
            console.error("[Shell] Failed to initialize notification server")
        }
    }
    
    Connections {
        target: Services.NotificationServer
        function onNotificationReceived(notification) {
            Services.Notifs.addNotification(notification)
        }
    }
    
    BarModule.Bar {
        id: bar
    }
    
    Power.PowerMenuPopup {
        id: powerMenu
    }
    
    AppLauncher.AppLauncher {
        id: appLauncher
    }

    Osd.Wrapper {
        id: osdWrapper
    }

    Bluetooth.BluetoothPopup {
        id: bluetoothPopup
    }

    MediaPlayer.MediaPlayerPopup {
        id: mediaPopup
    }

    Notifications.NotificationPopups {
        id: notificationPopups
    }
    
    Notifications.NotificationCenter {
        id: notificationCenter
    }
    
    Wallpaper.WallpaperSelector {
        id: wallpaperSelector
    }
    
    Process {
        id: awwwDaemon
        running: true
        command: ["awww-daemon"]
        onStarted: console.log("[Shell] awww-daemon started")
    }

    QtObject {
        id: wiring
        Component.onCompleted: {
            if (bluetoothPopup) bar.bluetoothPopup = bluetoothPopup
            if (mediaPopup) bar.mediaPopup = mediaPopup
            if (notificationPopups) bar.notificationPopups = notificationPopups
            if (notificationCenter) bar.notificationCenter = notificationCenter
        }
    }
    Connections {
        target: bar
        function onVolumePopupChanged() {
            if (bar.volumePopup) osdWrapper.volumePopup = bar.volumePopup
        }
    }
}