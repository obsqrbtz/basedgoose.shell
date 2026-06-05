import QtQuick
import QtQuick.Layouts
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Item {
    id: panel

    property real cpuUsage: 0
    property var  cpuHistory: []
    property real memUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    property var  memHistory: []
    property real netRxSpeed: 0
    property real netTxSpeed: 0
    property var  netRxHistory: []
    property var  netTxHistory: []
    property var  drives: []
    property bool loading: false
    property bool hasError: false
    property string errorText: ""

    function formatSpeed(kbps) {
        if (kbps >= 1024) return (kbps / 1024).toFixed(1) + " MB/s"
        if (kbps < 0.5)   return "0 KB/s"
        return kbps.toFixed(0) + " KB/s"
    }

    function formatBytes(bytes) {
        if (bytes >= 1099511627776) return (bytes / 1099511627776).toFixed(1) + " TB"
        if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + " GB"
        if (bytes >= 1048576) return (bytes / 1048576).toFixed(0) + " MB"
        return Math.round(bytes / 1024) + " KB"
    }

    // Loading / error overlay — shown only when no data yet
    Item {
        anchors.fill: parent
        visible: (panel.hasError || panel.loading) &&
                 panel.cpuHistory.length === 0 &&
                 panel.memHistory.length === 0 &&
                 panel.netRxHistory.length === 0 &&
                 (!(panel.drives) || panel.drives.length === 0)
        z: 1

        Text {
            anchors.centerIn: parent
            text: panel.hasError  ? ("  " + (panel.errorText || "Connection failed"))
                : panel.loading   ? "  Loading…"
                : ""
            font.family: Commons.Theme.fontUI
            font.pixelSize: Commons.Theme.fontSize
            color: panel.hasError ? Commons.Theme.error : Commons.Theme.foregroundMuted
        }
    }

        Flickable {
            anchors.fill: parent
            contentHeight: statsCol.implicitHeight + Commons.Config.popupContentPadding * 2
            clip: true
            visible: panel.cpuHistory.length > 0 ||
                     panel.memHistory.length > 0 ||
                     panel.netRxHistory.length > 0 ||
                     (panel.drives && panel.drives.length > 0)

        ColumnLayout {
            id: statsCol
            anchors {
                left: parent.left;  leftMargin:  Commons.Config.popupContentPadding
                right: parent.right; rightMargin: Commons.Config.popupContentPadding
                top: parent.top;    topMargin:   Commons.Config.popupContentPadding
            }
            spacing: Commons.Theme.spacingLg

            // ── CPU ───────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Commons.Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: ""
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: Commons.Theme.iconSize
                        color: Commons.Theme.primary
                    }
                    Text {
                        text: "  CPU"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: Commons.Theme.fontSizeSubheading
                        font.weight: Font.DemiBold
                        color: Commons.Theme.foreground
                        Layout.fillWidth: true
                    }
                    Text {
                        text: Math.round(panel.cpuUsage) + "%"
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: Commons.Theme.fontSizeSubheading
                        font.weight: Font.Bold
                        color: panel.cpuUsage > 80 ? Commons.Theme.error
                             : panel.cpuUsage > 60 ? Commons.Theme.warning
                             : Commons.Theme.primary
                    }
                }

                Widgets.SparkGraph {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    data: panel.cpuHistory
                    maxValue: 100
                    lineColor: Commons.Theme.primary
                    fillColor: Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.12)
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Commons.Theme.border; opacity: 0.5 }

            // ── Memory ────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Commons.Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: ""
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: Commons.Theme.iconSize
                        color: Commons.Theme.secondary
                    }
                    Text {
                        text: "  Memory"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: Commons.Theme.fontSizeSubheading
                        font.weight: Font.DemiBold
                        color: Commons.Theme.foreground
                        Layout.fillWidth: true
                    }
                    Text {
                        text: panel.memTotal > 0
                            ? (panel.memUsed.toFixed(1) + " / " + panel.memTotal.toFixed(0) + " GB")
                            : "—"
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: 11
                        font.weight: Font.Bold
                        color: panel.memUsage > 80 ? Commons.Theme.error
                             : panel.memUsage > 60 ? Commons.Theme.warning
                             : Commons.Theme.secondary
                    }
                }

                Widgets.SparkGraph {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    data: panel.memHistory
                    maxValue: 100
                    lineColor: Commons.Theme.secondary
                    fillColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.12)
                }
            }

            Rectangle { Layout.fillWidth: true; Layout.preferredHeight: 1; color: Commons.Theme.border; opacity: 0.5 }

            // ── Network ───────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Commons.Theme.spacingSm

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: ""
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: Commons.Theme.iconSize
                        color: Commons.Theme.info
                    }
                    Text {
                        text: "  Network"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: Commons.Theme.fontSizeSubheading
                        font.weight: Font.DemiBold
                        color: Commons.Theme.foreground
                        Layout.fillWidth: true
                    }
                    RowLayout {
                        spacing: Commons.Theme.spacingMd
                        RowLayout {
                            spacing: 3
                            Text { text: "↓"; font.family: Commons.Theme.fontUI; font.pixelSize: 11; color: Commons.Theme.info }
                            Text {
                                text: panel.formatSpeed(panel.netRxSpeed)
                                font.family: Commons.Theme.fontMono; font.pixelSize: 11
                                color: Commons.Theme.foreground
                            }
                        }
                        RowLayout {
                            spacing: 3
                            Text { text: "↑"; font.family: Commons.Theme.fontUI; font.pixelSize: 11; color: Commons.Theme.secondary }
                            Text {
                                text: panel.formatSpeed(panel.netTxSpeed)
                                font.family: Commons.Theme.fontMono; font.pixelSize: 11
                                color: Commons.Theme.foreground
                            }
                        }
                    }
                }

                Widgets.SparkGraph {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 56
                    data:  panel.netRxHistory
                    data2: panel.netTxHistory
                        lineColor:  Commons.Theme.info
                        fillColor:  Qt.rgba(Commons.Theme.info.r, Commons.Theme.info.g, Commons.Theme.info.b, 0.10)
                        lineColor2: Commons.Theme.secondary
                        fillColor2: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.08)
                }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: Commons.Theme.border
                opacity: 0.5
                visible: panel.drives && panel.drives.length > 0
            }

            // ── Drives ────────────────────────────────────────
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Commons.Theme.spacingMd
                visible: panel.drives && panel.drives.length > 0

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 0
                    Text {
                        text: "󰋊"
                        font.family: Commons.Theme.fontMono
                        font.pixelSize: Commons.Theme.iconSize
                        color: Commons.Theme.success
                    }
                    Text {
                        text: "  Drives"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: Commons.Theme.fontSizeSubheading
                        font.weight: Font.DemiBold
                        color: Commons.Theme.foreground
                        Layout.fillWidth: true
                    }
                }

                Repeater {
                    model: panel.drives || []
                    delegate: ColumnLayout {
                        required property var modelData

                        Layout.fillWidth: true
                        spacing: Commons.Theme.spacingSm

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Commons.Theme.spacingSm

                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 2

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.model || modelData.name
                                    font.family: Commons.Theme.fontUI
                                    font.pixelSize: Commons.Theme.fontSize
                                    font.weight: Font.Medium
                                    color: Commons.Theme.foreground
                                    elide: Text.ElideRight
                                }
                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.name + "  " + (modelData.mountPoints || []).map(function(m) { return m.path }).join(", ")
                                    font.family: Commons.Theme.fontMono
                                    font.pixelSize: Commons.Theme.fontSizeCaption
                                    color: Commons.Theme.foregroundMuted
                                    elide: Text.ElideRight
                                }
                            }

                            Text {
                                text: modelData.total > 0
                                    ? (panel.formatBytes(modelData.used) + " / " + panel.formatBytes(modelData.total))
                                    : panel.formatBytes(modelData.size || 0)
                                font.family: Commons.Theme.fontMono
                                font.pixelSize: 11
                                font.weight: Font.Bold
                                color: modelData.usage > 85 ? Commons.Theme.error
                                     : modelData.usage > 70 ? Commons.Theme.warning
                                     : Commons.Theme.success
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 6
                            radius: 3
                            color: Qt.rgba(Commons.Theme.foreground.r, Commons.Theme.foreground.g, Commons.Theme.foreground.b, 0.08)

                            Rectangle {
                                anchors.left: parent.left
                                anchors.top: parent.top
                                anchors.bottom: parent.bottom
                                width: parent.width * Math.min(100, Math.max(0, modelData.usage || 0)) / 100
                                radius: parent.radius
                                  color: modelData.usage > 85 ? Commons.Theme.error
                                      : modelData.usage > 70 ? Commons.Theme.warning
                                      : Commons.Theme.success
                            }
                        }

                        RowLayout {
                            Layout.fillWidth: true
                            spacing: Commons.Theme.spacingMd

                            RowLayout {
                                spacing: 3
                                Text { text: "R"; font.family: Commons.Theme.fontMono; font.pixelSize: 10; color: Commons.Theme.info }
                                Text {
                                    text: panel.formatSpeed(modelData.readSpeed || 0)
                                    font.family: Commons.Theme.fontMono
                                    font.pixelSize: 10
                                    color: Commons.Theme.foreground
                                }
                            }
                            RowLayout {
                                spacing: 3
                                Text { text: "W"; font.family: Commons.Theme.fontMono; font.pixelSize: 10; color: Commons.Theme.secondary }
                                Text {
                                    text: panel.formatSpeed(modelData.writeSpeed || 0)
                                    font.family: Commons.Theme.fontMono
                                    font.pixelSize: 10
                                    color: Commons.Theme.foreground
                                }
                            }
                            Item { Layout.fillWidth: true }
                            Text {
                                text: (modelData.usage || 0) + "%"
                                font.family: Commons.Theme.fontMono
                                font.pixelSize: 10
                                color: Commons.Theme.foregroundMuted
                            }
                        }

                        Widgets.SparkGraph {
                            Layout.fillWidth: true
                            Layout.preferredHeight: 42
                            data: modelData.readHistory || []
                            data2: modelData.writeHistory || []
                            lineColor: Commons.Theme.info
                            fillColor: Qt.rgba(Commons.Theme.info.r, Commons.Theme.info.g, Commons.Theme.info.b, 0.10)
                            lineColor2: Commons.Theme.secondary
                            fillColor2: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.08)
                        }

                        Repeater {
                            model: modelData.mountPoints || []
                            delegate: RowLayout {
                                required property var modelData

                                Layout.fillWidth: true
                                spacing: Commons.Theme.spacingSm

                                Text {
                                    Layout.fillWidth: true
                                    text: modelData.path
                                    font.family: Commons.Theme.fontMono
                                    font.pixelSize: Commons.Theme.fontSizeCaption
                                    color: Commons.Theme.foregroundMuted
                                    elide: Text.ElideRight
                                }
                                Text {
                                    text: panel.formatBytes(modelData.used) + " / " + panel.formatBytes(modelData.total)
                                    font.family: Commons.Theme.fontMono
                                    font.pixelSize: Commons.Theme.fontSizeCaption
                                    color: Commons.Theme.foregroundMuted
                                }
                            }
                        }
                    }
                }
            }

            Item { Layout.preferredHeight: Commons.Theme.spacingSm }
        }
    }
}
