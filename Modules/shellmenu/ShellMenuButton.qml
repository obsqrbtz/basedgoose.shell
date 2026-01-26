import QtQuick
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.HoverButton {
    id: shellMenuButton
    
    icon: "\uf219"
    iconSize: Commons.Theme.fontSize + 2
    iconColor: Commons.Theme.primary
    hoverIconColor: Commons.Theme.primary
    baseColor: "transparent"
    hoverColor: Commons.Theme.surfaceBase
    
    width: Commons.Config.powerButtonSize
    height: Commons.Config.powerButtonSize
    radius: Commons.Config.powerButtonRadius
}
