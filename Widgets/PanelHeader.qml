import QtQuick
import QtQuick.Layouts
import qs.Config

RowLayout {
    id: root

    property string icon: ""
    property string title: ""
    property bool closable: false

    default property alias trailing: trailingRow.data

    signal closeRequested

    spacing: Theme.spacingSm

    Icon {
        text: root.icon
        font.pixelSize: Theme.iconLarge
        color: Theme.primary
        visible: root.icon !== ""
    }

    StyledText {
        Layout.fillWidth: true
        text: root.title
        font.pixelSize: Theme.fontLarge
        font.weight: Font.DemiBold
    }

    RowLayout {
        id: trailingRow
        spacing: Theme.spacingXs
    }

    IconButton {
        icon: Icons.close
        size: Theme.controlHeight
        visible: root.closable
        onClicked: root.closeRequested()
    }
}
