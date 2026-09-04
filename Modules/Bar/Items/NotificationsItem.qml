import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "notifications"

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: popupWindow.toggle()
    onRightClicked: Notifications.dnd = !Notifications.dnd

    Icon {
        text: Notifications.dnd ? Icons.bellOff : Icons.bell
        color: root.hovered ? Theme.primary : Notifications.count > 0 ? Theme.text : Theme.textMuted

        Dot {
            visible: Notifications.count > 0 && !Notifications.dnd
        }
    }

    NotificationCenter {
        id: popupWindow
        anchorItem: root
    }
}
