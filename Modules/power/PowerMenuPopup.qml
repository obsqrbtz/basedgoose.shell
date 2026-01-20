import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: powerMenu
    
    ipcTarget: "power"
    initialScale: 0.9
    transformOriginX: 1.0
    transformOriginY: 0.0
    closeOnClickOutside: true
    
    implicitWidth: 240
    implicitHeight: 180
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: Commons.Config.popupMargin
        right: Commons.Config.popupMargin
    }
      
    Rectangle {
        id: contentRect
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radius
        border.color: Commons.Theme.border
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: shutdownMa.containsMouse ? Commons.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\udc25 Shutdown"
                        color: Commons.Theme.error
                        font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize + 2; weight: Font.DemiBold }
                    }
                }
                
                MouseArea {
                    id: shutdownMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powerMenu.shouldShow = false;
                        processComponent.createObject(powerMenu, { cmd: ["systemctl", "poweroff"] });
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: rebootMa.containsMouse ? Commons.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\udf09 Reboot"
                        color: Commons.Theme.warning
                        font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize + 2; weight: Font.DemiBold }
                    }
                }
                
                MouseArea {
                    id: rebootMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powerMenu.shouldShow = false;
                        processComponent.createObject(powerMenu, { cmd: ["systemctl", "reboot"] });
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: logoutMa.containsMouse ? Commons.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\uddfd Logout"
                        color: Commons.Theme.secondary
                        font { family: Commons.Theme.font; pixelSize: Commons.Theme.fontSize + 2; weight: Font.DemiBold }
                    }
                }
                
                MouseArea {
                    id: logoutMa
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        powerMenu.shouldShow = false;
                        processComponent.createObject(powerMenu, { cmd: ["hyprctl", "dispatch", "exit"] });
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

