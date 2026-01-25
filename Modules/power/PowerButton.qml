import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: powerButton
    
    property var barWindow
    property var powerMenuPopup
    
    signal clicked()
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    color: powerMa.containsMouse ? Commons.Theme.background : "transparent"
    radius: Commons.Config.powerButtonRadius
    
    Text {
        anchors.centerIn: parent
        text: "\udb81\udc25"
        color: Commons.Theme.secondary
        font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize + 2; weight: Font.Bold }
    }
    
    MouseArea {
        id: powerMa
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: {
            powerButton.clicked()
            
            if (!powerMenuPopup) return
            
            powerMenuPopup.shouldShow = !powerMenuPopup.shouldShow
            if (!powerMenuPopup.shouldShow) return
            if (!barWindow || !barWindow.screen) return
            
            const pos = powerButton.mapToItem(barWindow.contentItem, 0, 0)
            const rightEdge = pos.x + powerButton.width
            const screenWidth = barWindow.screen.width
            const barHeight = barWindow.implicitHeight || 36
            
            powerMenuPopup.margins.right = Commons.Config.popupMargin
        }
    }
}
