import QtQuick
import QtQuick.Layouts
import qs.Config

Surface {
    id: root

    enum Variant {
        Flat,
        Filled,
        Outlined
    }

    property string icon: ""
    property string label: ""
    property int variant: Button.Flat
    property bool active: false

    property color contentColor: active || variant === Button.Filled ? Theme.primary : Theme.text
    property alias iconSize: iconItem.font.pixelSize
    property alias fontSize: labelItem.font.pixelSize
    property int padding: Theme.spacingMd

    accent: Theme.primary
    baseColor: variant === Button.Filled || active ? Theme.primaryMuted : "transparent"
    border.width: variant === Button.Outlined ? 1 : 0
    border.color: active ? Theme.primary : Theme.border

    implicitWidth: content.implicitWidth + padding * 2
    implicitHeight: Math.max(26, content.implicitHeight + Theme.spacingSm)

    RowLayout {
        id: content

        x: Math.round((root.width - width) / 2)
        y: Math.round((root.height - height) / 2)
        spacing: Theme.spacingSm

        Icon {
            id: iconItem
            text: root.icon
            visible: root.icon !== ""
            color: root.hovered ? Theme.primary : root.contentColor
        }

        StyledText {
            id: labelItem
            text: root.label
            visible: root.label !== ""
            font.pixelSize: Theme.fontSmall
            font.weight: Font.Medium
            color: root.hovered ? Theme.primary : root.contentColor
        }
    }
}
