import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config

PanelWindow {
    id: root

    property Item anchorItem: null
    property var anchorWindow: null

    property int contentWidth: 320
    property int contentHeight: 200
    property int padding: Theme.spacingMd
    property bool open: false
    property bool focusable: false

    default property alias content: panel.content

    readonly property int gap: Theme.spacingXs
    readonly property int barThickness: Settings.barVertical ? (anchorWindow?.width ?? 0) : (anchorWindow?.height ?? 0)

    function toggle(): void {
        place();
        open = !open;
    }

    function request(action: string): void {
        place();
        open = action === "toggle" ? !open : action === "open";
    }

    function place(): void {
        if (!anchorItem)
            return;

        const pos = anchorItem.mapToItem(null, 0, 0);
        _itemX = pos.x;
        _itemY = pos.y;
        _itemWidth = anchorItem.width;
        _itemHeight = anchorItem.height;
    }

    property int _itemX: 0
    property int _itemY: 0
    property int _itemWidth: 0
    property int _itemHeight: 0

    readonly property int panelX: Settings.barVertical ? (Settings.barPosition === "left" ? barThickness + gap : root.width - barThickness - gap - contentWidth) : Math.max(gap, Math.min(root.width - contentWidth - gap, _itemX + _itemWidth / 2 - contentWidth / 2))
    readonly property int panelY: Settings.barVertical ? Math.max(gap, Math.min(root.height - contentHeight - gap, _itemY + _itemHeight / 2 - contentHeight / 2)) : (Settings.barPosition === "top" ? barThickness + gap : root.height - barThickness - gap - contentHeight)

    visible: open || panel.opacity > 0
    screen: root.anchorWindow?.screen ?? null
    color: "transparent"
    anchors { top: true; bottom: true; left: true; right: true }
    exclusionMode: ExclusionMode.Ignore

    WlrLayershell.layer: WlrLayer.Top
    WlrLayershell.keyboardFocus: root.open && root.focusable ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    WlrLayershell.namespace: "basedgoose-popup"

    MouseArea {
        anchors.fill: parent
        acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
        onPressed: root.open = false
    }

    Panel {
        id: panel

        x: root.panelX
        y: root.panelY
        width: root.contentWidth
        height: root.contentHeight
        padding: root.padding

        opacity: root.open ? 1 : 0
        scale: root.open ? 1 : 0.96

        Behavior on opacity {
            NumberAnimation { duration: Theme.animNormal }
        }
        Behavior on scale {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }

        MouseArea {
            anchors.fill: parent
            acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
            z: -1
        }
    }

    Item {
        anchors.fill: parent
        focus: root.open && root.focusable
        Keys.onEscapePressed: root.open = false
    }
}
