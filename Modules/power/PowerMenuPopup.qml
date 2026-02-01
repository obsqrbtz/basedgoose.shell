import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: powerMenu
    
    ipcTarget: "power"
    initialScale: 0.85
    closeOnClickOutside: true
    barPosition: Commons.Config.barPosition
    
    implicitWidth: 280
    implicitHeight: contentColumn.implicitHeight + 32
    
    Rectangle {
        anchors.fill: backgroundRect
        anchors.margins: -6
        radius: backgroundRect.radius + 3
        color: "transparent"
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowBlur: 0.8
            shadowVerticalOffset: 8
        }
    }
      
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radius * 2
        border.color: Commons.Theme.border
        border.width: 1
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Widgets.HeaderWithIcon {
                Layout.fillWidth: true
                icon: "\udb81\udc25"
                title: "Power Menu"
                iconColor: Commons.Theme.secondary
            }
            
            Widgets.Divider {
                Layout.fillWidth: true
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Widgets.MenuButton {
                    Layout.fillWidth: true
                    icon: "\udb81\udc25"
                    text: "Shutdown"
                    onClicked: {
                        powerMenu.shouldShow = false
                        processComponent.createObject(powerMenu, { cmd: ["systemctl", "poweroff"] })
                    }
                }
                
                Widgets.MenuButton {
                    Layout.fillWidth: true
                    icon: "\udb81\udf09"
                    text: "Reboot"
                    onClicked: {
                        powerMenu.shouldShow = false
                        processComponent.createObject(powerMenu, { cmd: ["systemctl", "reboot"] })
                    }
                }
                
                Widgets.MenuButton {
                    Layout.fillWidth: true
                    icon: "\udb81\uddfd"
                    text: "Logout"
                    onClicked: {
                        powerMenu.shouldShow = false
                        processComponent.createObject(powerMenu, { cmd: ["hyprctl", "dispatch", "exit"] })
                    }
                }
            }
        }
        
        Component {
            id: processComponent
            Process {
                property var cmd: []
                running: true
                command: cmd
            }
        }
    }
}

