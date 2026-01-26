import QtQuick
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.HoverButton {
    id: powerButton
    
    property var barWindow
    property var powerMenuPopup
    
    icon: "\udb81\udc25"
    iconSize: Commons.Theme.fontSize + 2
    iconColor: Commons.Theme.secondary
    hoverIconColor: Commons.Theme.secondary
    baseColor: "transparent"
    hoverColor: Commons.Theme.background
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    radius: Commons.Config.powerButtonRadius
    
    onClicked: {
        if (!powerButton.powerMenuPopup) return
        
        powerButton.powerMenuPopup.shouldShow = !powerButton.powerMenuPopup.shouldShow
        if (!powerButton.powerMenuPopup.shouldShow) return
        if (!powerButton.barWindow || !powerButton.barWindow.screen) return
        
        const pos = powerButton.mapToItem(powerButton.barWindow.contentItem, 0, 0)
        const rightEdge = pos.x + powerButton.width
        const screenWidth = powerButton.barWindow.screen.width
        const barHeight = powerButton.barWindow.implicitHeight || 36
        
        powerButton.powerMenuPopup.margins.right = Commons.Config.popupMargin
    }
}
