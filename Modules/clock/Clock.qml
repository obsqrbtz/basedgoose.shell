import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Text {
    id: clockText
    
    color: Commons.Theme.foreground
    font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
    text: Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
    
    Timer {
        interval: Commons.Config.clockUpdateInterval
        running: true
        repeat: true
        onTriggered: clockText.text = Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
    }
}
