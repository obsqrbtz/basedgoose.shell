import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "power"

    onClicked: popupWindow.toggle()

    Icon {
        text: Icons.power
        color: root.hovered ? Theme.error : Theme.textMuted
    }

    PowerMenu {
        id: popupWindow
        anchorItem: root
    }
}
