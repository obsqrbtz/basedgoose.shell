import QtQuick
import qs.Config

Rectangle {
    id: root

    property alias text: input.text
    property alias placeholder: placeholderText.text
    property alias echoMode: input.echoMode
    property alias inputItem: input
    property string icon: ""

    signal accepted(string text)

    implicitWidth: 200
    implicitHeight: 30
    radius: Theme.radius
    color: Theme.alpha(Theme.text, 0.05)
    border.width: 1
    border.color: input.activeFocus ? Theme.primary : Theme.border

    Behavior on border.color {
        ColorAnimation { duration: Theme.animNormal }
    }

    function forceFocus(): void {
        input.forceActiveFocus();
    }

    Icon {
        id: iconItem
        anchors.left: parent.left
        anchors.leftMargin: Theme.spacingSm
        anchors.verticalCenter: parent.verticalCenter
        text: root.icon
        visible: root.icon !== ""
    }

    TextInput {
        id: input
        anchors.fill: parent
        anchors.leftMargin: (iconItem.visible ? iconItem.width + Theme.spacingSm : 0) + Theme.spacingSm
        anchors.rightMargin: Theme.spacingSm
        verticalAlignment: TextInput.AlignVCenter
        color: Theme.text
        font.family: Theme.fontFamily
        font.pixelSize: Theme.fontNormal
        selectionColor: Theme.primary
        selectedTextColor: Theme.background
        clip: true

        onAccepted: root.accepted(text)

        StyledText {
            id: placeholderText
            anchors.verticalCenter: parent.verticalCenter
            color: Theme.textMuted
            visible: input.text === ""
        }
    }
}
