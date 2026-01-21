import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: shellMenuButton
    
    signal clicked()
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    color: menuMa.containsMouse ? Commons.Theme.surfaceBase : "transparent"
    radius: Commons.Config.powerButtonRadius
   
    Text {
        anchors.centerIn: parent
        text: "\uf219"
        color: Commons.Theme.primary
        font { family: Commons.Theme.fontIcon; pixelSize: Commons.Theme.fontSize + 2; }
    }
    
    MouseArea {
        id: menuMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: shellMenuButton.clicked()
    }
}
