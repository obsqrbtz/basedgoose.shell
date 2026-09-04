import QtQuick
import Quickshell
import Quickshell.WindowManager
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets

BarItem {
    id: root

    interactive: false
    spacing: Theme.spacingXs
    visible: Compositor.workspaces.length > 0

    Repeater {
        model: Compositor.workspacesFor(root.QsWindow.window?.screen ?? null)

        Surface {
            id: pill

            required property Windowset modelData

            readonly property bool active: modelData.active

            width: root.vertical ? 8 : active ? 26 : 8
            height: root.vertical ? (active ? 26 : 8) : 8

            radius: 4
            accent: Theme.primary
            baseColor: active ? Theme.primary : modelData.urgent ? Theme.error : Theme.alpha(Theme.text, 0.25)

            onClicked: Compositor.activate(modelData)

            Behavior on width {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
            Behavior on height {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }
}
