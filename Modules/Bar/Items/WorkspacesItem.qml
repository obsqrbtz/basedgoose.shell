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
            readonly property bool focused: active && (Quickshell.screens.length <= 1 || root.onFocusedScreen)
            readonly property bool urgent: modelData.urgent

            readonly property color tint: urgent ? Theme.error : Theme.primary
            readonly property bool filled: focused || urgent
            readonly property int padding: focused ? Theme.spacingSm : Theme.spacingXs

            implicitWidth: Math.max(implicitHeight, Math.min(label.implicitWidth, 48) + padding * 2)
            implicitHeight: Theme.barItemInner

            radius: Theme.radius
            accent: tint

            baseColor: filled ? tint : "transparent"

            onClicked: Compositor.activate(modelData)

            StyledText {
                id: label

                anchors.centerIn: parent
                width: Math.min(implicitWidth, 48)
                text: Compositor.label(pill.modelData)
                horizontalAlignment: Text.AlignHCenter
                font.pixelSize: Theme.fontSmall
                font.bold: pill.focused
                color: pill.filled ? Theme.background : pill.active ? pill.tint : Theme.textMuted
            }

            Behavior on implicitWidth {
                NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
            }
        }
    }
}
