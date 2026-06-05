import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import Quickshell
import "../../Commons" as Commons
import "../../Services" as Services
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: monitorPopup

    ipcTarget: "monitor"
    barPosition: Commons.Config.barPosition
    initialScale: 0.94

    // Local machine stats — bound from Bar.qml
    property int  cpuUsage: 0
    property var  cpuHistory: []
    property int  memUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    property var  memHistory: []
    property real netRxSpeed: 0
    property real netTxSpeed: 0
    property var  netRxHistory: []
    property var  netTxHistory: []
    property var  drives: []

    property int activeTab: 0

    implicitWidth: 400
    implicitHeight: 560

    Rectangle {
        anchors.fill: backgroundRect
        anchors.margins: -6
        radius: backgroundRect.radius + 3
        color: "transparent"
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, Commons.Theme.popupShadowOpacity)
            shadowBlur: Commons.Theme.popupShadowBlur
            shadowVerticalOffset: Commons.Theme.popupShadowOffset
        }
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radiusPanel
        border.color: Commons.Theme.border
        border.width: 1
        clip: true

        Connections {
            target: Services.ConfigService
            function onMonitorServersChanged() {
                var max = (Services.ConfigService.monitorServers || []).length
                if (monitorPopup.activeTab > max) monitorPopup.activeTab = 0
            }
        }

        ColumnLayout {
            anchors.fill: parent
            spacing: 0

            // ── Header ────────────────────────────────────────
            RowLayout {
                Layout.fillWidth: true
                Layout.leftMargin:   Commons.Config.popupContentPadding
                Layout.rightMargin:  Commons.Config.popupContentPadding
                Layout.topMargin:    Commons.Config.popupContentPadding
                Layout.bottomMargin: Commons.Theme.spacingMd

                Text {
                    text: "System Monitor"
                    font.family: Commons.Theme.fontUI
                    font.pixelSize: Commons.Theme.fontSizeHeading
                    font.weight: Font.Bold
                    color: Commons.Theme.foreground
                    Layout.fillWidth: true
                }
            }

            // ── Tab bar ───────────────────────────────────────
            Flickable {
                Layout.fillWidth: true
                Layout.preferredHeight: 26
                Layout.leftMargin:   Commons.Config.popupContentPadding
                Layout.rightMargin:  Commons.Config.popupContentPadding
                Layout.bottomMargin: Commons.Theme.spacingMd
                contentWidth: tabRow.implicitWidth
                contentHeight: 26
                clip: true
                interactive: tabRow.implicitWidth > width

                RowLayout {
                    id: tabRow
                    spacing: Commons.Theme.spacingXs
                    height: 26

                    // Local tab (always first)
                    Rectangle {
                        Layout.preferredHeight: 26
                        implicitWidth: localTabLabel.implicitWidth + 20
                        radius: Commons.Theme.radiusSm
                        color: monitorPopup.activeTab === 0
                            ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.15)
                            : (localTabMa.containsMouse ? Qt.rgba(Commons.Theme.foreground.r, Commons.Theme.foreground.g, Commons.Theme.foreground.b, 0.05) : "transparent")
                        border.color: monitorPopup.activeTab === 0
                            ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.35)
                            : Commons.Theme.border
                        border.width: 1
                        Behavior on color { ColorAnimation { duration: 100 } }

                        Text {
                            id: localTabLabel
                            anchors.centerIn: parent
                            text: "Local"
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: Commons.Theme.fontSize
                            font.weight: monitorPopup.activeTab === 0 ? Font.Medium : Font.Normal
                            color: monitorPopup.activeTab === 0 ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                            Behavior on color { ColorAnimation { duration: 100 } }
                        }
                        MouseArea {
                            id: localTabMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: monitorPopup.activeTab = 0
                        }
                    }

                    // Server tabs — one per configured server
                    Repeater {
                        model: Services.ConfigService.monitorServers || []
                        delegate: Rectangle {
                            required property var modelData
                            required property int index
                            readonly property bool active: monitorPopup.activeTab === index + 1

                            Layout.preferredHeight: 26
                            implicitWidth: serverTabLabel.implicitWidth + 20
                            radius: Commons.Theme.radiusSm
                            color: active
                                ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.15)
                                : (serverTabMa.containsMouse ? Qt.rgba(Commons.Theme.foreground.r, Commons.Theme.foreground.g, Commons.Theme.foreground.b, 0.05) : "transparent")
                            border.color: active
                                ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.35)
                                : Commons.Theme.border
                            border.width: 1
                            Behavior on color { ColorAnimation { duration: 100 } }

                            Text {
                                id: serverTabLabel
                                anchors.centerIn: parent
                                text: modelData.name || ("Server " + (index + 1))
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: Commons.Theme.fontSize
                                font.weight: active ? Font.Medium : Font.Normal
                                color: active ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                                Behavior on color { ColorAnimation { duration: 100 } }
                            }
                            MouseArea {
                                id: serverTabMa
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: monitorPopup.activeTab = index + 1
                            }
                        }
                    }
                }
            }

            // ── Divider ───────────────────────────────────────
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Commons.Theme.border
            }

            // ── Local stats ───────────────────────────────────
            StatsPanel {
                Layout.fillWidth: true
                Layout.fillHeight: true
                visible: monitorPopup.activeTab === 0
                cpuUsage:    monitorPopup.cpuUsage
                cpuHistory:  monitorPopup.cpuHistory
                memUsage:    monitorPopup.memUsage
                memUsed:     monitorPopup.memUsed
                memTotal:    monitorPopup.memTotal
                memHistory:  monitorPopup.memHistory
                netRxSpeed:  monitorPopup.netRxSpeed
                netTxSpeed:  monitorPopup.netTxSpeed
                netRxHistory: monitorPopup.netRxHistory
                netTxHistory: monitorPopup.netTxHistory
                drives:      monitorPopup.drives
            }

            // ── Server stats — one panel per server ───────────
            Repeater {
                model: Services.ConfigService.monitorServers || []
                delegate: Item {
                    required property var modelData
                    required property int index
                    id: serverDelegate

                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    visible: monitorPopup.activeTab === index + 1

                    Services.PrometheusClient {
                        id: promClient
                        host: serverDelegate.modelData.host || ""
                        port: serverDelegate.modelData.port || "9091"
                        active: monitorPopup.shouldShow && serverDelegate.visible
                    }

                    StatsPanel {
                        anchors.fill: parent
                        cpuUsage:    promClient.cpuUsage
                        cpuHistory:  promClient.cpuHistory
                        memUsage:    promClient.memUsage
                        memUsed:     promClient.memUsed
                        memTotal:    promClient.memTotal
                        memHistory:  promClient.memHistory
                        netRxSpeed:  promClient.netRxSpeed
                        netTxSpeed:  promClient.netTxSpeed
                        netRxHistory: promClient.netRxHistory
                        netTxHistory: promClient.netTxHistory
                        drives:      promClient.drives
                        loading:     promClient.loading
                        hasError:    promClient.hasError
                        errorText:   promClient.errorText
                    }
                }
            }
        }
    }
}
