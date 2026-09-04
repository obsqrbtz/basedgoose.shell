import QtQuick
import qs.Config

StyledText {
    property alias size: root.font.pixelSize

    id: root
    font.pixelSize: Theme.iconNormal
    color: Theme.textMuted
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter
}
