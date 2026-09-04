import QtQuick
import qs.Config

Rectangle {
    property color accent: Theme.primary

    anchors.right: parent.right
    anchors.rightMargin: -width
    anchors.top: parent.top
    anchors.topMargin: -1

    width: 5
    height: 5
    radius: width / 2
    color: accent
}
