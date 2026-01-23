import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: popupWindow
    
    ipcTarget: "shellmenu"
    initialScale: 0.94
    transformOriginX: 0.5
    transformOriginY: 0.0
    closeOnClickOutside: true
    
    property var cheatsheetPopup: null
    property var wallpaperSelector: null
    property var displayManager: null
    
    readonly property color cSurface: Commons.Theme.background
    readonly property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        left: Commons.Config.popupMargin
        top: Commons.Config.popupMargin
    }
    
    implicitWidth: 240
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
        color: Commons.Theme.surfaceBase
        radius: Commons.Theme.radius * 2
        
        border.color: Commons.Theme.border
        border.width: 1
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Commons.Theme.radius
                color: cheatsheetMouse.containsMouse ? cHover : "transparent"
                border.width: 1
                border.color: cBorder
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰌌"
                            font.family: Commons.Theme.fontIcon
                            font.pixelSize: 14
                            color: cPrimary
                        }
                    }
                    
                    Text {
                        text: "IPC Cheatsheet"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: cText
                        Layout.fillWidth: true
                    }
                }
                
                MouseArea {
                    id: cheatsheetMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupWindow.shouldShow = false
                        if (cheatsheetPopup) {
                            cheatsheetPopup.shouldShow = true
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Commons.Theme.radius
                color: wallpaperMouse.containsMouse ? cHover : "transparent"
                border.width: 1
                border.color: cBorder
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "\uf03e"
                            font.family: Commons.Theme.fontIcon
                            font.pixelSize: 14
                            color: cPrimary
                        }
                    }
                    
                    Text {
                        text: "Wallpaper Selector"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: cText
                        Layout.fillWidth: true
                    }
                }
                
                MouseArea {
                    id: wallpaperMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupWindow.shouldShow = false
                        if (wallpaperSelector) {
                            wallpaperSelector.shouldShow = true
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 48
                radius: Commons.Theme.radius
                color: displayMouse.containsMouse ? cHover : "transparent"
                border.width: 1
                border.color: cBorder
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    spacing: 12
                    
                    Rectangle {
                        width: 28
                        height: 28
                        radius: 6
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰍹"
                            font.family: Commons.Theme.fontIcon
                            font.pixelSize: 14
                            color: cPrimary
                        }
                    }
                    
                    Text {
                        text: "Display Manager"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        font.weight: Font.Medium
                        color: cText
                        Layout.fillWidth: true
                    }
                }
                
                MouseArea {
                    id: displayMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        popupWindow.shouldShow = false
                        if (displayManager) {
                            displayManager.shouldShow = true
                        }
                    }
                }
            }
        }
    }
}
