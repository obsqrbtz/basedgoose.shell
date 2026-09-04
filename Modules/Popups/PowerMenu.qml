import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    readonly property var actions: [
        { label: "Lock", icon: Icons.lock, command: Compositor.lockCommand, confirm: false },
        { label: "Suspend", icon: Icons.suspend, command: ["systemctl", "suspend"], confirm: false },
        { label: "Log out", icon: Icons.logout, command: Compositor.logoutCommand, confirm: true },
        { label: "Reboot", icon: Icons.reboot, command: ["systemctl", "reboot"], confirm: true },
        { label: "Shut down", icon: Icons.power, command: ["systemctl", "poweroff"], confirm: true }
    ]

    property var pending: null

    onOpenChanged: if (!open) pending = null

    contentWidth: 240
    contentHeight: column.implicitHeight + padding * 2

    function run(action: var): void {
        if (action.confirm && pending !== action) {
            pending = action;
            return;
        }
        Quickshell.execDetached(action.command);
        open = false;
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingXs

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.power
            title: root.pending ? `${root.pending.label}?` : "Session"
        }

        Divider { Layout.fillWidth: true }

        Repeater {
            model: root.actions

            ListRow {
                required property var modelData

                Layout.fillWidth: true
                icon: modelData.icon
                title: modelData.title ?? modelData.label
                active: root.pending === modelData
                iconColor: modelData.confirm ? Theme.error : Theme.primary
                visible: !root.pending || root.pending === modelData
                onClicked: root.run(modelData)
            }
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingXs
            spacing: Theme.spacingSm
            visible: root.pending !== null

            Button {
                Layout.fillWidth: true
                label: "Cancel"
                variant: Button.Outlined
                onClicked: root.pending = null
            }

            Button {
                Layout.fillWidth: true
                label: "Confirm"
                variant: Button.Filled
                contentColor: Theme.error
                onClicked: root.run(root.pending)
            }
        }
    }
}
