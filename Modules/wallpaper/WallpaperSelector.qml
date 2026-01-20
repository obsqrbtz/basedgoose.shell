import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: popupWindow
    
    ipcTarget: "wallpaper"
    initialScale: 0.94
    transformOriginX: 0.5
    transformOriginY: 0.5
    closeOnClickOutside: true
    
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
        top: 100
        left: Quickshell.screens[0] ? (Quickshell.screens[0].width - implicitWidth) / 2 : 0
    }
    
    implicitWidth: 600
    implicitHeight: 500
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: cSurface
        radius: 16
        border.color: cBorder
        border.width: 1
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowBlur: 1.0
            shadowVerticalOffset: 6
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Rectangle {
                    width: 36
                    height: 36
                    radius: 12
                    color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰨳"
                        font.family: "Material Design Icons"
                        font.pixelSize: 18
                        color: cPrimary
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Text {
                        text: "Wallpaper Selector"
                        font.family: "Inter"
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: cText
                    }
                    
                    Text {
                        text: wallpaperList.count > 0 ? wallpaperList.count + " wallpapers found" : "Loading..."
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: cSubText
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: cSurfaceContainer
                clip: true
                
                GridView {
                    id: wallpaperGrid
                    anchors.fill: parent
                    anchors.margins: 8
                    cellWidth: 120
                    cellHeight: 120
                    model: wallpaperList
                    clip: true
                    
                    delegate: Rectangle {
                            id: wallpaperItem
                            width: wallpaperGrid.cellWidth - 8
                            height: wallpaperGrid.cellHeight - 8
                            radius: 8
                            color: itemArea.containsMouse ? cHover : "transparent"
                            border.width: itemArea.containsMouse ? 2 : 1
                            border.color: itemArea.containsMouse ? cPrimary : cBorder
                            
                            required property string filePath
                            required property string fileName
                            
                            Behavior on color { ColorAnimation { duration: 100 } }
                            Behavior on border.color { ColorAnimation { duration: 100 } }
                            
                            Rectangle {
                                anchors.fill: parent
                                anchors.margins: 4
                                radius: 6
                                color: cSurface
                                clip: true
                                
                                Image {
                                    id: wallpaperImage
                                    anchors.fill: parent
                                    source: "file://" + wallpaperItem.filePath
                                    sourceSize: Qt.size(240, 240)
                                    fillMode: Image.PreserveAspectCrop
                                    asynchronous: true
                                    smooth: true
                                    
                                    onStatusChanged: {
                                        if (status === Image.Error) {
                                            errorIcon.visible = true
                                        }
                                    }
                                }
                                
                                Text {
                                    id: errorIcon
                                    anchors.centerIn: parent
                                    text: "󰈙"
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 24
                                    color: cSubText
                                    visible: false
                                }
                            }
                            
                            MouseArea {
                                id: itemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: {
                                    setWallpaper(wallpaperItem.filePath)
                                }
                            }
                        }
                    }
                    
                Widgets.EmptyState {
                    anchors.centerIn: parent
                    visible: wallpaperList.count === 0 && !loadingProcess.running
                    icon: "󰈙"
                    iconSize: 32
                    iconOpacity: 0.2
                    title: "No wallpapers found"
                    subtitle: "Check the directory: " + Commons.Config.wallpaperDirectory
                    textOpacity: 1.0
                }
            }
        }
        
        ListModel {
            id: wallpaperList
        }
        
        Process {
            id: loadingProcess
            running: true
            property string wallpaperDir: Commons.Config.wallpaperDirectory.startsWith("~") 
                ? Commons.Config.wallpaperDirectory.replace("~", "$HOME")
                : Commons.Config.wallpaperDirectory
            command: ["sh", "-c", "find " + wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.svg' -o -iname '*.avif' -o -iname '*.jxl' \\) 2>/dev/null | head -100"]
            
            stdout: StdioCollector {
                onStreamFinished: {
                    var output = text.trim()
                    var lines = output.split('\n').filter(function(line) { return line.length > 0 })
                    wallpaperList.clear()
                    
                    for (var i = 0; i < lines.length; i++) {
                        var filePath = lines[i].trim()
                        if (filePath.length > 0) {
                            var fileName = filePath.substring(filePath.lastIndexOf("/") + 1)
                            wallpaperList.append({
                                filePath: filePath,
                                fileName: fileName
                            })
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
    
    function setWallpaper(filePath) {
        popupWindow.shouldShow = false
        processComponent.createObject(popupWindow, { 
            cmd: ["awww", "img", filePath] 
        })
    }
    
    function refresh() {
        loadingProcess.running = false
        wallpaperList.clear()
        loadingProcess.running = true
    }
}
