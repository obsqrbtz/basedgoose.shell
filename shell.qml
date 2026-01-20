//@ pragma UseQApplication
import Quickshell
import Quickshell.Io
import QtQuick 6.10
import "./Modules/bar" as BarModule
import "./Modules" as Modules
import "./Modules/notifications" as Notifications
import "./Modules/osd" as Osd
import "./Widgets" as Widgets
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
    
    Modules.PowerMenu {
        id: powerMenu
    }
    
    Modules.AppLauncher {
        id: appLauncher
    }

    Osd.Wrapper {
        id: osdWrapper
    }

    Widgets.BluetoothPopupWindow {
        id: bluetoothPopup
    }

    Widgets.MediaPlayerPopupWindow {
        id: mediaPopup
    }

    Notifications.NotificationPopups {
        id: notificationPopups
    }
    
    Notifications.NotificationCenter {
        id: notificationCenter
    }
    
    IpcHandler {
        target: "launcher"
        
        function toggle(): void {
            appLauncher.toggle();
        }
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