import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Widgets

BarPopup {
    id: root

    property int offset: 0

    readonly property date shown: {
        const now = new Date();
        return new Date(now.getFullYear(), now.getMonth() + offset, 1);
    }

    onOpenChanged: if (!open) offset = 0

    contentWidth: 260
    contentHeight: column.implicitHeight + padding * 2

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingSm

        PanelHeader {
            Layout.fillWidth: true
            title: Qt.formatDate(root.shown, "MMMM yyyy")

            IconButton {
                icon: Icons.chevronDown
                size: 20
                rotation: 90
                onClicked: root.offset--
            }
            IconButton {
                icon: Icons.chevronRight
                size: 20
                onClicked: root.offset++
            }
        }

        GridLayout {
            Layout.fillWidth: true
            columns: 7
            rowSpacing: 2
            columnSpacing: 2

            Repeater {
                model: ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"]

                SectionLabel {
                    required property string modelData
                    Layout.fillWidth: true
                    text: modelData
                    horizontalAlignment: Text.AlignHCenter
                }
            }

            Repeater {
                model: {
                    const first = root.shown;
                    const start = new Date(first);
                    start.setDate(1 - ((first.getDay() + 6) % 7));
                    return Array.from({ length: 42 }, (_, i) => new Date(start.getFullYear(), start.getMonth(), start.getDate() + i));
                }

                Surface {
                    required property date modelData

                    readonly property bool thisMonth: modelData.getMonth() === root.shown.getMonth()
                    readonly property bool today: modelData.toDateString() === new Date().toDateString()

                    Layout.fillWidth: true
                    implicitHeight: 24
                    interactive: false
                    radius: Theme.radius
                    baseColor: today ? Theme.primaryMuted : "transparent"
                    border.width: today ? 1 : 0
                    border.color: Theme.primary

                    StyledText {
                        anchors.centerIn: parent
                        text: parent.modelData.getDate()
                        font.pixelSize: Theme.fontSmall
                        color: parent.today ? Theme.primary : parent.thisMonth ? Theme.text : Theme.alpha(Theme.textMuted, 0.5)
                    }
                }
            }
        }
    }
}
