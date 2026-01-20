pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root
    
    signal notificationReceived(var notification)
    
    Component.onCompleted: {
        console.log("[NotificationServer] Initializing notification server...")
    }
    
    property NotificationServer server: NotificationServer {
        Component.onCompleted: {
            console.log("[NotificationServer] Notification server ready")
        }
        
        onNotification: notif => {
            console.log("[NotificationServer] Received notification:", notif.summary, "from", notif.appName || "unknown app")
            root.notificationReceived(notif)
        }
    }
}


