import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

ColumnLayout {
    id: root

    required property var source

    spacing: Theme.spacingMd

    EmptyState {
        Layout.fillWidth: true
        Layout.topMargin: Theme.spacingLg
        icon: Icons.server
        title: "Unavailable"
        hint: root.source.errorText
        visible: root.source.hasError
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Theme.spacingMd
        visible: !root.source.hasError

        Reading {
            label: "CPU"
            icon: Icons.cpu
            value: root.source.cpuUsage
            detail: Format.percent(root.source.cpuUsage)
            history: root.source.cpuHistory
        }

        Reading {
            label: "Memory"
            icon: Icons.memory
            value: root.source.memUsage
            detail: `${root.source.memUsed.toFixed(1)} / ${root.source.memTotal.toFixed(1)} GB`
            history: root.source.memHistory
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            RowLayout {
                Layout.fillWidth: true

                SectionLabel { text: "Network" }
                Item { Layout.fillWidth: true }

                StyledText {
                    text: `${Icons.download}  ${Format.speed(root.source.netRxSpeed)}`
                    font.pixelSize: Theme.fontCaption
                    color: Theme.info
                }

                StyledText {
                    text: `${Icons.upload}  ${Format.speed(root.source.netTxSpeed)}`
                    font.pixelSize: Theme.fontCaption
                    color: Theme.secondary
                }
            }

            Item {
                Layout.fillWidth: true
                implicitHeight: 34

                Spark {
                    anchors.fill: parent
                    values: root.source.netRxHistory
                    accent: Theme.info
                    maximum: 0
                }

                Spark {
                    anchors.fill: parent
                    values: root.source.netTxHistory
                    accent: Theme.secondary
                    maximum: 0
                    filled: false
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs
            visible: root.source.drives.length > 0

            SectionLabel { text: "Storage" }

            Repeater {
                model: root.source.drives.length

                ColumnLayout {
                    id: driveRow

                    required property int index
                    readonly property var drive: root.source.drives[index] ?? ({ name: "", used: 0, total: 0, usage: 0 })

                    Layout.fillWidth: true
                    spacing: 2

                    RowLayout {
                        Layout.fillWidth: true

                        StyledText {
                            Layout.fillWidth: true
                            text: driveRow.drive.name
                            font.pixelSize: Theme.fontCaption
                        }

                        StyledText {
                            text: `${Format.bytes(driveRow.drive.used)} / ${Format.bytes(driveRow.drive.total)}`
                            font.pixelSize: Theme.fontTiny
                            color: Theme.textMuted
                        }
                    }

                    Meter {
                        Layout.fillWidth: true
                        value: driveRow.drive.usage
                    }
                }
            }
        }
    }

    component Reading: ColumnLayout {
        id: reading

        property string label: ""
        property string icon: ""
        property string detail: ""
        property real value: 0
        property var history: []

        Layout.fillWidth: true
        spacing: Theme.spacingXs

        RowLayout {
            Layout.fillWidth: true

            Icon {
                text: reading.icon
                font.pixelSize: Theme.iconSmall
            }

            SectionLabel { text: reading.label }

            Item { Layout.fillWidth: true }

            StyledText {
                text: reading.detail
                font.pixelSize: Theme.fontCaption
                color: Theme.textMuted
            }
        }

        Spark {
            Layout.fillWidth: true
            implicitHeight: 34
            values: reading.history
            accent: reading.value >= 90 ? Theme.error : reading.value >= 75 ? Theme.warning : Theme.primary
        }
    }
}
