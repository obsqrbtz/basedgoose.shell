import QtQuick 6.10
import "../Commons" as Commons

Text {
    id: root
    
    property color labelColor: Qt.rgba(Commons.Theme.foreground.r, Commons.Theme.foreground.g, Commons.Theme.foreground.b, 0.6)
    
    font.family: Commons.Theme.fontUI
    font.pixelSize: 11
    color: root.labelColor
}
