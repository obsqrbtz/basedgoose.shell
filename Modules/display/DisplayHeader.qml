import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../Commons" as Commons
import "../../Widgets" as Widgets

RowLayout {
    id: root

    property int monitorCount: 0
    property bool isLoading: false

    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)

    signal refreshClicked

    spacing: 12

    Rectangle {
        width: 36
        height: 36
        radius: 12
        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)

        Text {
            anchors.centerIn: parent
            text: "󰍹"
            font.family: Commons.Theme.fontIcon
            font.pixelSize: 18
            color: cPrimary
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: 2

        Text {
            text: "Display Management"
            font.family: Commons.Theme.fontUI
            font.pixelSize: 15
            font.weight: Font.Bold
            color: cText
        }

        Text {
            text: root.isLoading ? "Loading..." : (root.monitorCount > 0 ? root.monitorCount + " display(s)" : "No displays")
            font.family: Commons.Theme.fontUI
            font.pixelSize: 11
            color: cSubText
        }
    }

    Widgets.IconButton {
        width: 32
        height: 32
        Layout.alignment: Qt.AlignVCenter
        icon: "󰑓"
        iconSize: 14
        iconColor: cSubText
        hoverIconColor: cPrimary
        baseColor: "transparent"
        hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
        onClicked: {
            root.refreshClicked();
        }
    }
}
