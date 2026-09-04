import QtQuick
import qs.Config

Rectangle {
    id: root

    property string text: ""
    property color accent: Theme.primary

    implicitWidth: Math.max(implicitHeight, label.implicitWidth + Theme.spacingSm)
    implicitHeight: 14
    radius: Theme.radius
    color: Theme.alpha(accent, 0.2)
    border.width: 1
    border.color: accent

    StyledText {
        id: label
        anchors.centerIn: parent
        text: root.text
        font.pixelSize: Theme.fontTiny
        font.weight: Font.DemiBold
        color: root.accent
    }
}
