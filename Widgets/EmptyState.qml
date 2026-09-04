import QtQuick
import qs.Config

Column {
    id: root

    property string icon: ""
    property string title: ""
    property string hint: ""

    spacing: Theme.spacingSm

    Icon {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.icon
        font.pixelSize: 28
        color: Theme.alpha(Theme.textMuted, 0.6)
        visible: root.icon !== ""
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.title
        color: Theme.textMuted
        horizontalAlignment: Text.AlignHCenter
    }

    StyledText {
        anchors.horizontalCenter: parent.horizontalCenter
        text: root.hint
        font.pixelSize: Theme.fontCaption
        color: Theme.alpha(Theme.textMuted, 0.7)
        horizontalAlignment: Text.AlignHCenter
        visible: root.hint !== ""
    }
}
