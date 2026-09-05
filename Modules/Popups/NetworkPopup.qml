import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    property var pending: null

    onOpenChanged: {
        Network.setScanning(open);
        if (!open)
            pending = null;
    }

    focusable: true

    contentWidth: 320
    contentHeight: column.implicitHeight + padding * 2

    function activate(network: var): void {
        if (!Network.activate(network))
            pending = network;
    }

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingSm

        PanelHeader {
            Layout.fillWidth: true
            icon: Network.ethernetConnected ? Icons.ethernet : Network.wifiConnected ? Icons.wifi : Icons.wifiOff
            title: "Network"

            StyledText {
                text: Network.statusText
                font.pixelSize: Theme.fontSmall
                color: Network.connected ? Theme.textMuted : Theme.warning
            }
        }

        Divider { Layout.fillWidth: true }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs
            visible: Network.wiredDevices.length > 0

            SectionLabel { text: "Wired" }

            Repeater {
                model: Network.wiredDevices

                ListRow {
                    id: wiredRow

                    required property var modelData

                    Layout.fillWidth: true
                    interactive: false
                    icon: Icons.ethernet
                    title: modelData.name
                    subtitle: Network.deviceStatus(modelData)
                    active: modelData.connected

                    Icon {
                        text: Icons.check
                        color: Theme.primary
                        visible: wiredRow.active
                    }
                }
            }
        }

        Divider {
            Layout.fillWidth: true
            visible: Network.wiredDevices.length > 0 && Network.wifiAvailable
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs
            visible: Network.wifiAvailable

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                SectionLabel { text: "Wi-Fi" }

                StyledText {
                    Layout.fillWidth: true
                    text: Network.wifiDevice?.name ?? ""
                    font.pixelSize: Theme.fontSmall
                    color: Theme.textMuted
                }

                Toggle {
                    checked: Network.wifiEnabled
                    onToggled: checked => Network.setWifiEnabled(checked)
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingXs
                visible: root.pending !== null

                SectionLabel { text: `Password for ${root.pending?.name ?? ""}` }

                TextField {
                    id: password
                    Layout.fillWidth: true
                    echoMode: TextInput.Password
                    placeholder: "Network password"
                    icon: Icons.lock
                    onAccepted: text => {
                        root.pending.connectWithPsk(text);
                        root.pending = null;
                        password.text = "";
                    }
                }
            }

            ScrollList {
                Layout.fillWidth: true
                Layout.preferredHeight: Math.min(240, contentHeight)
                visible: Network.networks.length > 0
                model: Network.networks

                delegate: ListRow {
                    required property var modelData

                    width: ListView.view.width
                    icon: Icons.wifiLevel(modelData.signalStrength * 100)
                    title: modelData.name || "Hidden network"
                    subtitle: modelData.connected ? "Connected" : modelData.known ? "Saved" : Network.securityName(modelData)
                    active: modelData.connected
                    onClicked: root.activate(modelData)

                    Icon {
                        text: Icons.check
                        color: Theme.primary
                        visible: modelData.connected
                    }
                }
            }

            EmptyState {
                Layout.fillWidth: true
                Layout.topMargin: Theme.spacingMd
                Layout.bottomMargin: Theme.spacingMd
                icon: Icons.wifiOff
                title: Network.wifiEnabled ? "Looking for networks" : "Wi-Fi is off"
                visible: Network.networks.length === 0
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.topMargin: Theme.spacingMd
            Layout.bottomMargin: Theme.spacingMd
            icon: Icons.wifiOff
            title: "No network devices"
            visible: !Network.wifiAvailable && Network.wiredDevices.length === 0
        }
    }
}
