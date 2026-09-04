import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config
import qs.Services

PanelWindow {
    id: root

    property bool open: false
    property int contentWidth: 480
    property int contentHeight: 400
    property int padding: Theme.spacingLg
    property bool dim: true

    default property alias content: panel.content

    signal closeRequested

    visible: open || panel.opacity > 0
    screen: Compositor.focusedScreen
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: open ? WlrKeyboardFocus.Exclusive : WlrKeyboardFocus.None
    WlrLayershell.namespace: "basedgoose-overlay"

    Rectangle {
        anchors.fill: parent
        color: "black"
        opacity: root.open && root.dim ? 0.35 : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }

        MouseArea {
            anchors.fill: parent
            onClicked: root.closeRequested()
        }
    }

    Panel {
        id: panel

        anchors.centerIn: parent
        width: Math.min(root.contentWidth, root.width - Theme.spacingXl * 2)
        height: Math.min(root.contentHeight, root.height - Theme.spacingXl * 2)
        padding: root.padding

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.97

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            z: -1
        }
    }

    Item {
        anchors.fill: parent
        focus: root.open
        Keys.onEscapePressed: root.closeRequested()
    }
}
