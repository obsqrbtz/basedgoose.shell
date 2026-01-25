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
    transformOriginX: 1.0
    transformOriginY: 0.0
    closeOnClickOutside: true
    
    implicitWidth: 280
    implicitHeight: contentColumn.implicitHeight + 32
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: Commons.Config.popupMargin
        right: Commons.Config.popupMargin
    }
    
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
        color: Commons.Theme.surfaceBase
        radius: Commons.Theme.radius * 2
        border.color: Commons.Theme.border
        border.width: 1
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            Text {
                text: "Power Menu"
                font.family: Commons.Theme.fontUI
                font.pixelSize: 14
                font.weight: Font.DemiBold
                color: Commons.Theme.foreground
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 8
                
                // Shutdown Button
                Rectangle {
                    id: shutdownButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 10
                    color: shutdownMa.pressed ? shutdownPressedColor : 
                           (shutdownMa.containsMouse ? shutdownHoverColor : shutdownBaseColor)
                    
                    property color shutdownBaseColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.1)
                    property color shutdownHoverColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.18)
                    property color shutdownPressedColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.25)
                    
                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12
                        
                        Text {
                            text: "\udb81\udc25"
                            font.family: Commons.Theme.fontMono
                            font.pixelSize: 20
                            color: Commons.Theme.secondary
                        }
                        
                        Text {
                            text: "Shutdown"
                            Layout.fillWidth: true
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Commons.Theme.foreground
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
                
                // Reboot Button
                Rectangle {
                    id: rebootButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 10
                    color: rebootMa.pressed ? rebootPressedColor : 
                           (rebootMa.containsMouse ? rebootHoverColor : rebootBaseColor)
                    
                    property color rebootBaseColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.1)
                    property color rebootHoverColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.18)
                    property color rebootPressedColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.25)

                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12
                        
                        Text {
                            text: "\udb81\udf09"
                            font.family: Commons.Theme.fontMono
                            font.pixelSize: 20
                            color: Commons.Theme.secondary
                        }
                        
                        Text {
                            text: "Reboot"
                            Layout.fillWidth: true
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Commons.Theme.foreground
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
                
                // Logout Button
                Rectangle {
                    id: logoutButton
                    Layout.fillWidth: true
                    Layout.preferredHeight: 52
                    radius: 10
                    color: logoutMa.pressed ? logoutPressedColor : 
                           (logoutMa.containsMouse ? logoutHoverColor : logoutBaseColor)
                    
                    property color logoutBaseColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.1)
                    property color logoutHoverColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.18)
                    property color logoutPressedColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.25)
                    
                    Behavior on color {
                        ColorAnimation { duration: 150; easing.type: Easing.OutCubic }
                    }
                    
                    RowLayout {
                        anchors.left: parent.left
                        anchors.right: parent.right
                        anchors.verticalCenter: parent.verticalCenter
                        anchors.leftMargin: 16
                        anchors.rightMargin: 16
                        spacing: 12
                        
                        Text {
                            text: "\udb81\uddfd"
                            font.family: Commons.Theme.fontMono
                            font.pixelSize: 20
                            color: Commons.Theme.secondary
                        }
                        
                        Text {
                            text: "Logout"
                            Layout.fillWidth: true
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Commons.Theme.foreground
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

