import QtQuick
import Quickshell
import Quickshell.Services.SystemTray
import qs.Config
import qs.Modules.Bar
import qs.Widgets

BarItem {
    id: root

    interactive: false
    visible: SystemTray.items.values.length > 0
    spacing: 2

    Repeater {
        model: SystemTray.items

        Surface {
            id: entry

            required property SystemTrayItem modelData

            width: 20
            height: 20
            accent: Theme.primary
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: modelData.activate()
            onRightClicked: {
                if (modelData.hasMenu)
                    menu.open();
            }

            Image {
                anchors.centerIn: parent
                width: 14
                height: 14
                source: entry.modelData.icon
                asynchronous: true
                sourceSize.width: 28
                sourceSize.height: 28
            }

            QsMenuAnchor {
                id: menu
                menu: entry.modelData.menu
                anchor.item: entry
                anchor.edges: Settings.barPosition === "bottom" ? Edges.Top : Edges.Bottom
            }
        }
    }
}
