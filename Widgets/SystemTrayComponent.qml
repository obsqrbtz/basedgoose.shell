import Quickshell
import Quickshell.Services.SystemTray
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "../Services" as Services

RowLayout {
    id: systemTrayComponent
    
    property var barWindow: null
    
    spacing: Services.Config.traySpacing
    visible: SystemTray.items.values.length > 0
    
    Repeater {
        model: SystemTray.items
        
        Rectangle {
            width: Services.Config.trayIconSize
            height: Services.Config.trayIconSize
            color: trayMa.containsMouse ? Services.Theme.background : "transparent"
            radius: Services.Config.trayIconRadius
            
            Image {
                anchors.centerIn: parent
                width: Services.Config.trayIconImageSize
                height: Services.Config.trayIconImageSize
                source: modelData.icon
                smooth: true
            }
            
            MouseArea {
                id: trayMa
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                acceptedButtons: Qt.LeftButton | Qt.RightButton | Qt.MiddleButton
                
                onClicked: (mouse) => {
                    if (mouse.button === Qt.LeftButton) {
                        modelData.activate();
                    } else if (mouse.button === Qt.RightButton) {
                        if (modelData.hasMenu) {
                            var window = systemTrayComponent.barWindow;
                            
                            if (window) {
                                var pos = mapToItem(null, mouse.x, mouse.y);
                                modelData.display(window, pos.x, pos.y);
                            } else {
                                console.error("Could not find parent window for tray menu");
                            }
                        }
                    } else if (mouse.button === Qt.MiddleButton) {
                        modelData.secondaryActivate();
                    }
                }
                
                onWheel: (wheel) => {
                    modelData.scroll(wheel.angleDelta.y / 120, false);
                }
            }
            
            ToolTip {
                visible: trayMa.containsMouse
                text: modelData.tooltipTitle || modelData.title
                delay: 500
                contentWidth: 200
            }
        }
    }
}