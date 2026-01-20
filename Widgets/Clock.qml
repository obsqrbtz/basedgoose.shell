import QtQuick
import "../Services" as Services

Text {
    id: clockText
    
    color: Services.Theme.foreground
    font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize; weight: Font.Medium }
    text: Qt.formatDateTime(new Date(), Services.Config.clockFormat)
    
    Timer {
        interval: Services.Config.clockUpdateInterval
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), Services.Config.clockFormat)
    }
}
