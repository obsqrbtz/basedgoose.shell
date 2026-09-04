import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets
import qs.Modules.Overlays

BarPopup {
    id: root

    contentWidth: 240
    contentHeight: column.implicitHeight + padding * 2

    function launch(name: string): void {
        open = false;
        Overlays.show(name);
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingXs

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.menu
            title: Compositor.displayName
        }

        Divider { Layout.fillWidth: true }

        ListRow {
            Layout.fillWidth: true
            icon: Icons.search
            title: "Applications"
            onClicked: root.launch("launcher")
        }

        ListRow {
            Layout.fillWidth: true
            icon: Icons.image
            title: "Wallpapers"
            onClicked: root.launch("wallpapers")
        }

        ListRow {
            Layout.fillWidth: true
            icon: Icons.display
            title: "Displays"
            onClicked: root.launch("displays")
        }

        ListRow {
            Layout.fillWidth: true
            icon: Icons.settings
            title: "Settings"
            onClicked: root.launch("settings")
        }

        ListRow {
            Layout.fillWidth: true
            icon: Icons.keyboard
            title: "IPC commands"
            onClicked: root.launch("cheatsheet")
        }
    }
}
