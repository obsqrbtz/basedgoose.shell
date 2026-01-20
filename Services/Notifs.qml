pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Services.Notifications

Singleton {
    id: root

    property list<Notif> notifications: []
    property var activeNotifications: []
    
    readonly property int maxNotifications: 100
    
    readonly property var recentNotifications: notifications.filter(n => {
        const hoursSinceNotif = (new Date().getTime() - n.timestamp.getTime()) / (1000 * 60 * 60);
        return hoursSinceNotif < 24;
    }).sort((a, b) => b.timestamp.getTime() - a.timestamp.getTime())
    
    readonly property var groupedNotifications: {
        const groups = {}
        const active = activeNotifications
        for (let i = 0; i < active.length; i++) {
            const n = active[i]
            const key = n.appName || "Unknown"
            if (!groups[key]) {
                groups[key] = []
            }
            groups[key].push(n)
        }
        return groups
    }
    
    readonly property var notificationCounts: {
        const counts = {}
        const grouped = groupedNotifications
        for (let app in grouped) {
            counts[app] = grouped[app].length
        }
        return counts
    }
    
    property bool dnd: false
    
    Timer {
        interval: 3600000
        repeat: true
        running: true
        triggeredOnStart: false
        
        onTriggered: {
            const oneDayAgo = new Date().getTime() - (24 * 60 * 60 * 1000)
            const oldCount = root.notifications.length
            root.notifications = root.notifications.filter(n =>
                n.timestamp.getTime() > oneDayAgo
            )
            root.refreshActiveNotifications()
            const cleaned = oldCount - root.notifications.length
            if (cleaned > 0) {
                console.log("[Notifs] Cleaned up", cleaned, "old notifications")
            }
        }
    }
    
    function addNotification(notif) {
        if (dnd && notif.urgency < 2) {
            console.log("[Notifs Service] DND active - suppressing notification:", notif.summary);
            return;
        }
        
        console.log("[Notifs Service] Adding notification:", notif.summary);
        
        const notifWrapper = notifComponent.createObject(root, {
            notification: notif
        });
        
        root.notifications = [notifWrapper, ...root.notifications].slice(0, root.maxNotifications);
        root.refreshActiveNotifications();
        console.log("Total notifications:", root.notifications.length);
    }
    
    function toggleDnd() {
        dnd = !dnd;
        console.log("[Notifs Service] DND mode:", dnd ? "enabled" : "disabled");
    }
    
    function clearAll() {
        notifications.forEach(n => n.close());
        console.log("[Notifs Service] All notifications cleared");
    }
    
    function clearApp(appName) {
        notifications.filter(n => n.appName === appName).forEach(n => n.close());
        console.log("[Notifs Service] Cleared notifications from:", appName);
    }

    function refreshActiveNotifications() {
        root.activeNotifications = root.notifications.filter(n => !n.closed);
    }

    component Notif: QtObject {
        id: notifWrapper
        
        property var notification
        property date timestamp: new Date()
        property bool closed: false
        property bool hasAnimated: false 
        
        property string id: ""
        property string summary: ""
        property string body: ""
        property string appName: ""
        property string appIcon: ""
        property string image: ""
        property int urgency: 0
        property list<var> actions: []
        
        readonly property string timeString: {
            const diff = new Date().getTime() - timestamp.getTime();
            const minutes = Math.floor(diff / 60000);
            const hours = Math.floor(minutes / 60);
            const days = Math.floor(hours / 24);
            
            if (days > 0) return days + "d ago";
            if (hours > 0) return hours + "h ago";
            if (minutes > 0) return minutes + "m ago";
            return "Just now";
        }
        
        readonly property Connections conn: Connections {
            target: notifWrapper.notification
            
            function onClosed() {
                notifWrapper.close();
            }
            
            function onSummaryChanged() {
                notifWrapper.summary = notifWrapper.notification.summary;
            }
            
            function onBodyChanged() {
                notifWrapper.body = notifWrapper.notification.body;
            }
            
            function onAppNameChanged() {
                notifWrapper.appName = notifWrapper.notification.appName;
            }
            
            function onAppIconChanged() {
                notifWrapper.appIcon = notifWrapper.notification.appIcon;
            }
            
            function onImageChanged() {
                notifWrapper.image = notifWrapper.notification.image;
            }
            
            function onUrgencyChanged() {
                notifWrapper.urgency = notifWrapper.notification.urgency;
            }
            
            function onActionsChanged() {
                notifWrapper.actions = notifWrapper.notification.actions.map(a => ({
                    identifier: a.identifier,
                    text: a.text,
                    invoke: () => a.invoke()
                }));
            }
        }
        
        function close() {
            if (closed) return;
            
            closed = true;
            
            if (notification) {
                notification.dismiss();
            }
            
            console.log("[Notifs] Notification closed but kept in history:", summary);
            root.refreshActiveNotifications();
        }
        
        function invokeAction(actionId) {
            const action = actions.find(a => a.identifier === actionId);
            if (action && action.invoke) {
                action.invoke();
            }
        }
        
        Component.onCompleted: {
            if (!notification)
                return;
            
            id = notification.id;
            summary = notification.summary;
            body = notification.body;
            appName = notification.appName;
            appIcon = notification.appIcon;
            image = notification.image;
            urgency = notification.urgency;
            actions = notification.actions.map(a => ({
                identifier: a.identifier,
                text: a.text,
                invoke: () => a.invoke()
            }));
        }
    }
    
    Component {
        id: notifComponent
        
        Notif {}
    }
    
    function deleteNotification(notif) {
        if (root.notifications.includes(notif)) {
            root.notifications = root.notifications.filter(n => n !== notif);
            if (notif.notification) {
                notif.notification.dismiss();
            }
            notif.destroy();
            root.refreshActiveNotifications();
            console.log("[Notifs] Notification permanently deleted");
        }
    }
}