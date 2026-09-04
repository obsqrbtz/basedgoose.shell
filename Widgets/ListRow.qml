import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Config

Surface {
    id: root

    property string icon: ""
    property string iconSource: ""
    property string title: ""
    property string subtitle: ""
    property bool active: false
    property color iconColor: active ? Theme.primary : Theme.textMuted

    default property alias trailing: trailingRow.data

    implicitHeight: Math.max(38, column.implicitHeight + Theme.spacingMd)
    accent: Theme.primary
    baseColor: active ? Theme.primaryMuted : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: Theme.spacingMd
        anchors.rightMargin: Theme.spacingMd
        spacing: Theme.spacingMd

        IconImage {
            implicitSize: 22
            source: root.iconSource
            visible: root.iconSource !== ""
        }

        Icon {
            text: root.icon
            font.pixelSize: Theme.iconLarge
            color: root.iconColor
            visible: root.iconSource === "" && root.icon !== ""
        }

        ColumnLayout {
            id: column
            Layout.fillWidth: true
            spacing: 1

            StyledText {
                Layout.fillWidth: true
                text: root.title
                font.pixelSize: Theme.fontSmall
                color: root.active ? Theme.primary : Theme.text
            }

            StyledText {
                Layout.fillWidth: true
                text: root.subtitle
                font.pixelSize: Theme.fontCaption
                color: Theme.textMuted
                visible: root.subtitle !== ""
            }
        }

        RowLayout {
            id: trailingRow
            spacing: Theme.spacingSm
        }
    }
}
