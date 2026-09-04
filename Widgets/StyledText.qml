import QtQuick
import qs.Config

Text {
    color: Theme.text
    font.family: Theme.fontFamily
    font.pixelSize: Theme.fontNormal
    renderType: Text.NativeRendering
    textFormat: Text.PlainText
    elide: Text.ElideRight

    Behavior on color {
        ColorAnimation { duration: Theme.animNormal }
    }
}
