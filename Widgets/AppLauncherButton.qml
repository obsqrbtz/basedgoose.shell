import QtQuick
import "../Services" as Services

Rectangle {
    id: appLauncherButton
    
    signal clicked()
    
    width: Services.Config.powerButtonSize
    height: Services.Config.powerButtonSize
    color: launcherMa.containsMouse ? Services.Theme.surfaceBase : "transparent"
    radius: Services.Config.powerButtonRadius
   
    Text {
        anchors.centerIn: parent
        text: "\udb83\udec0"
        color: Services.Theme.secondary
        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; }
    }
    
    MouseArea {
        id: launcherMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: appLauncherButton.clicked()
    }
}
