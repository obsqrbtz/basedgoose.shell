import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: appLauncherButton
    
    signal clicked()
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    color: launcherMa.containsMouse ? Commons.Theme.surfaceBase : "transparent"
    radius: Commons.Config.powerButtonRadius
   
    Text {
        anchors.centerIn: parent
        text: "\udb83\udec0"
        color: Commons.Theme.secondary
        font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize + 2; }
    }
    
    MouseArea {
        id: launcherMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: appLauncherButton.clicked()
    }
}
