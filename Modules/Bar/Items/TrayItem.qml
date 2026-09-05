import QtQuick
import QtQuick.Effects
import Quickshell
import Quickshell.Services.SystemTray
import qs.Config
import qs.Modules.Bar
import qs.Widgets

BarItem {
    id: root

    readonly property bool monochrome: true

    interactive: false
    visible: SystemTray.items.values.length > 0
    spacing: Theme.spacingXs

    Repeater {
        model: SystemTray.items

        Surface {
            id: entry

            required property SystemTrayItem modelData

            width: Theme.barItemInner
            height: Theme.barItemInner
            accent: Theme.primary
            acceptedButtons: Qt.LeftButton | Qt.RightButton

            onClicked: modelData.activate()
            onRightClicked: {
                if (modelData.hasMenu)
                    menu.open();
            }

            Image {
                id: icon

                anchors.centerIn: parent
                width: Theme.iconNormal
                height: Theme.iconNormal
                source: entry.modelData.icon
                fillMode: Image.PreserveAspectFit
                asynchronous: true
                smooth: true
                mipmap: true
                sourceSize.width: Theme.iconNormal * 2
                sourceSize.height: Theme.iconNormal * 2
                visible: false
            }

            MultiEffect {
                anchors.centerIn: parent
                width: icon.width
                height: icon.height
                source: icon

                colorization: root.monochrome && !entry.hovered ? 1 : 0
                colorizationColor: Theme.text
                saturation: colorization - 1

                Behavior on colorization {
                    NumberAnimation { duration: Theme.animFast }
                }
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
