import QtQuick
import qs.Config

StyledText {
    property alias size: root.font.pixelSize

    id: root
    font.family: Theme.iconFontFamily
    font.pixelSize: Theme.iconNormal
    color: Theme.textMuted
    horizontalAlignment: Text.AlignHCenter
    verticalAlignment: Text.AlignVCenter

    topPadding: Math.max(0, metrics.descent - metrics.ascent + font.pixelSize * 0.72)
    bottomPadding: Math.max(0, metrics.ascent - metrics.descent - font.pixelSize * 0.72)

    FontMetrics {
        id: metrics
        font: root.font
    }
}
