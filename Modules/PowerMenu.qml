import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../Services" as Services
import "../Commons" as Commons

Commons.PopupWindow {
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
        top: 46
        right: 8
    }
      
    Rectangle {
        id: contentRect
        anchors.fill: parent
        color: Services.Theme.background
        radius: Services.Theme.radius
        border.color: Services.Theme.border
        border.width: 1
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                color: shutdownMa.containsMouse ? Services.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\udc25 Shutdown"
                        color: Services.Theme.error
                        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.DemiBold }
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
                color: rebootMa.containsMouse ? Services.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\udf09 Reboot"
                        color: Services.Theme.warning
                        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.DemiBold }
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
                color: logoutMa.containsMouse ? Services.Theme.surfaceBase : "transparent"
                radius: 6
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Text {
                        text: "\udb81\uddfd Logout"
                        color: Services.Theme.secondary
                        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.DemiBold }
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
        
        Connections {
            target: bar
            function onShowPowerMenu() {
                powerMenu.toggle();
            }
        }
    }
}
