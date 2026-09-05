import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    onOpenChanged: Bluetooth.setDiscovering(open)

    contentWidth: 320
    contentHeight: column.implicitHeight + padding * 2

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingSm

        PanelHeader {
            Layout.fillWidth: true
            icon: Bluetooth.powered ? Icons.bluetooth : Icons.bluetoothOff
            title: Bluetooth.statusText

            Toggle {
                checked: Bluetooth.powered
                onToggled: Bluetooth.togglePower()
            }
        }

        Divider { Layout.fillWidth: true }

        ScrollList {
            Layout.fillWidth: true
            Layout.preferredHeight: Math.min(260, contentHeight)
            visible: Bluetooth.powered
            model: Bluetooth.devices

            delegate: ListRow {
                required property var modelData

                width: ListView.view.width
                icon: Icons.bluetooth
                title: modelData.name || modelData.address
                subtitle: Bluetooth.statusOf(modelData)
                active: modelData.connected
                onClicked: Bluetooth.activate(modelData)

                IconButton {
                    icon: Icons.trash
                    size: Theme.controlHeight
                    visible: modelData.paired
                    onClicked: modelData.forget()
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingMd
            icon: Icons.bluetoothOff
            title: Bluetooth.powered ? "Looking for devices" : "Bluetooth is off"
            visible: Bluetooth.devices.length === 0 || !Bluetooth.powered
        }
    }
}
