import QtQuick
import "../Services" as Services

Rectangle {
    id: powerButton
    
    signal clicked()
    
    width: Services.Config.powerButtonSize
    height: Services.Config.powerButtonSize
    color: powerMa.containsMouse ? Services.Theme.background : "transparent"
    radius: Services.Config.powerButtonRadius
    
    Text {
        anchors.centerIn: parent
        text: "\udb81\udc25"
        color: Services.Theme.error
        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.Bold }
    }
    
    MouseArea {
        id: powerMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: powerButton.clicked()
    }
}
