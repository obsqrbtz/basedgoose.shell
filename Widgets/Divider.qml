import QtQuick
import qs.Config

Rectangle {
    property bool vertical: false

    implicitWidth: vertical ? 1 : parent?.width ?? 0
    implicitHeight: vertical ? Theme.spacingMd : 1
    color: Theme.border
    opacity: 0.6
}
