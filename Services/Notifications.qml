pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Services.Notifications
import qs.Config

Singleton {
    id: root

    readonly property list<Notification> list: server.trackedNotifications.values.slice().reverse()
    readonly property int count: list.length

    property alias dnd: persist.dnd

    signal notified(Notification notification)

    readonly property var grouped: {
        const groups = {};
        for (const n of list) {
            const app = n.appName || "Unknown";
            groups[app] = (groups[app] ?? []).concat([n]);
        }
        return groups;
    }

    property var _times: ({})

    function age(notification: Notification): string {
        const at = _times[notification.id];
        return at ? Format.age(new Date(at)) : "";
    }

    function close(notification: Notification): void {
        notification.dismiss();
    }

    function clearApp(appName: string): void {
        for (const n of grouped[appName] ?? [])
            n.dismiss();
    }

    function clearAll(): void {
        for (const n of list.slice())
            n.dismiss();
    }

    NotificationServer {
        id: server

        keepOnReload: true
        actionsSupported: true
        actionIconsSupported: true
        bodyMarkupSupported: true
        imageSupported: true

        onNotification: notification => {
            notification.tracked = true;
            root._times[notification.id] = Date.now();
            if (!root.dnd || notification.urgency === NotificationUrgency.Critical)
                root.notified(notification);
        }
    }

    FileView {
        path: `${Settings.cacheDir}/notifications.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: persist
            property bool dnd: false
        }
    }
}
