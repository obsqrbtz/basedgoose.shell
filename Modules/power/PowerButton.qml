import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: powerButton
    
    signal clicked()
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    color: powerMa.containsMouse ? Commons.Theme.background : "transparent"
    radius: Commons.Config.powerButtonRadius
    
    Text {
        anchors.centerIn: parent
        text: "\udb81\udc25"
        color: Commons.Theme.error
        font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize + 2; weight: Font.Bold }
    }
    
    MouseArea {
        id: powerMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: powerButton.clicked()
    }
}
