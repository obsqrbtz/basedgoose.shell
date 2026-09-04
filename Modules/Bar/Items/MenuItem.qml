import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "menu"

    onClicked: popupWindow.toggle()

    Icon {
        text: Icons.menu
        font.pixelSize: Theme.iconLarge
        color: root.hovered ? Theme.primary : Theme.primary
    }

    ShellMenuPopup {
        id: popupWindow
        anchorItem: root
    }
}
