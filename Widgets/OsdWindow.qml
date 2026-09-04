import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config

PanelWindow {
    id: root

    property int timeout: 1800
    property int contentWidth: 220
    property int contentHeight: 60
    property bool shown: false

    default property alias content: panel.content

    function trigger(): void {
        shown = true;
        hideTimer.restart();
    }

    visible: shown || panel.opacity > 0
    color: "transparent"
    implicitWidth: contentWidth + Theme.spacingXl * 2
    implicitHeight: contentHeight + Theme.spacingXl * 2
    exclusionMode: ExclusionMode.Ignore

    anchors { bottom: true }
    margins.bottom: 80

    WlrLayershell.layer: WlrLayer.Overlay
    WlrLayershell.keyboardFocus: WlrKeyboardFocus.None
    WlrLayershell.namespace: "basedgoose-osd"

    mask: Region {}

    Panel {
        id: panel
        anchors.centerIn: parent
        width: root.contentWidth
        height: root.contentHeight

        opacity: root.shown ? 1 : 0
        scale: root.shown ? 1 : 0.95

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
    }

    Timer {
        id: hideTimer
        interval: root.timeout
        onTriggered: root.shown = false
    }
}
