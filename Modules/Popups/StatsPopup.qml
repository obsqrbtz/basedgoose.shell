import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    property int tab: 0

    readonly property var servers: Settings.monitorServers ?? []

    contentWidth: 340
    contentHeight: Math.min(560, column.implicitHeight + padding * 2)

    onOpenChanged: open ? SystemUsage.watch() : SystemUsage.unwatch()
    Component.onDestruction: if (open)
        SystemUsage.unwatch()

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingSm

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.cpu
            title: root.tab === 0 ? "This machine" : root.servers[root.tab - 1]?.name ?? ""
        }

        Tabs {
            Layout.fillWidth: true
            visible: root.servers.length > 0
            currentIndex: root.tab
            model: [{ label: "Local", icon: Icons.cpu }].concat(root.servers.map(s => ({ label: s.name, icon: Icons.server })))
            onCurrentIndexChanged: root.tab = currentIndex
        }

        Divider { Layout.fillWidth: true }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredHeight: panel.implicitHeight
            contentHeight: panel.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            StatsPanel {
                id: panel
                width: parent.width
                source: (root.tab === 0 ? SystemUsage : remotes.objectAt(root.tab - 1)) ?? SystemUsage
            }
        }
    }

    Instantiator {
        id: remotes
        model: root.servers

        delegate: PrometheusSource {
            required property var modelData

            host: modelData.host ?? ""
            port: modelData.port || "9090"
            active: root.open && root.servers[root.tab - 1]?.host === host
        }
    }
}
