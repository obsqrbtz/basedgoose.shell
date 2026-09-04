import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Notifications
import qs.Config
import qs.Services
import qs.Widgets
import qs.Modules.Popups

PanelWindow {
    id: root

    readonly property int limit: 5
    readonly property int dwell: 6000

    property list<Notification> queue: []

    function push(notification: Notification): void {
        queue = [notification].concat(queue.filter(n => n !== notification)).slice(0, limit);
    }

    function drop(notification: Notification): void {
        queue = queue.filter(n => n !== notification);
    }

    visible: queue.length > 0
    screen: Compositor.focusedScreen
    color: "transparent"
    implicitWidth: 340 + Theme.spacingLg * 2
    implicitHeight: Math.max(1, column.implicitHeight + Theme.spacingLg * 2)
    exclusionMode: ExclusionMode.Ignore

    anchors {
        top: Settings.barPosition !== "bottom"
        bottom: Settings.barPosition === "bottom"
        right: Settings.barPosition !== "left"
        left: Settings.barPosition === "left"
    }

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "basedgoose-toasts"

    mask: Region {
        item: column
    }

    Connections {
        target: Notifications

        function onNotified(notification: Notification): void {
            root.push(notification);
        }
    }

    ColumnLayout {
        id: column
        anchors.centerIn: parent
        width: 340
        spacing: Theme.spacingSm

        Repeater {
            model: root.queue

            NotificationCard {
                required property Notification modelData

                Layout.fillWidth: true
                notification: modelData
                onDismissed: root.drop(modelData)

                Timer {
                    running: !hovered
                    interval: root.dwell
                    onTriggered: root.drop(modelData)
                }

                opacity: 0
                Component.onCompleted: opacity = 1
                Behavior on opacity {
                    NumberAnimation { duration: Theme.animNormal }
                }
            }
        }
    }
}
