import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Io
import "../../Commons" as Commons
import "../../Widgets" as Widgets
import "../../Services" as Services

Widgets.PopupWindow {
    id: popupWindow
    
    ipcTarget: "wallpaper"
    initialScale: 0.94
    transformOriginX: 0.5
    transformOriginY: 0.5
    closeOnClickOutside: !directoryDialogProcess.running
    
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
                Layout.preferredHeight: 40
                radius: 10
                color: cSurfaceContainer
                
                RowLayout {
                    anchors.left: parent.left
                    anchors.right: parent.right
                    anchors.verticalCenter: parent.verticalCenter
                    anchors.leftMargin: 8
                    anchors.rightMargin: 8
                    spacing: 8
                    
                    Text {
                        text: "Directory:"
                        font.family: "Inter"
                        font.pixelSize: 12
                        color: cText
                    }
                    
                    TextInput {
                        id: directoryInput
                        Layout.fillWidth: true
                        text: Services.ConfigService.wallpaperDirectory
                        font.family: "Inter"
                        font.pixelSize: 11
                        color: cText
                        selectByMouse: true
                        
                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: -4
                            radius: 6
                            color: directoryInput.activeFocus ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.1) : "transparent"
                            border.width: directoryInput.activeFocus ? 1 : 0
                            border.color: cPrimary
                            z: -1
                        }
                        
                        Keys.onReturnPressed: {
                            saveDirectory()
                        }
                        Keys.onEscapePressed: {
                            text = Services.ConfigService.wallpaperDirectory
                            focus = false
                        }
                    }
                    
                    Widgets.IconButton {
                        width: 32
                        height: 32
                        Layout.alignment: Qt.AlignVCenter
                        icon: "󰈔"
                        iconSize: 14
                        iconColor: cSubText
                        hoverIconColor: cPrimary
                        baseColor: "transparent"
                        hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        onClicked: {
                            openDirectoryDialog()
                        }
                    }
                    
                    Widgets.IconButton {
                        width: 32
                        height: 32
                        visible: directoryInput.text !== Services.ConfigService.wallpaperDirectory
                        icon: "󰄬"
                        iconSize: 14
                        iconColor: cPrimary
                        hoverIconColor: cPrimary
                        baseColor: "transparent"
                        hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        onClicked: {
                            saveDirectory()
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: cSurfaceContainer
                clip: true
                
                Item {
                    anchors.fill: parent
                    anchors.margins: 8
                    
                    GridView {
                        id: wallpaperGrid
                        anchors.centerIn: parent
                        width: Math.floor((parent.width / 120)) * 120
                        height: Math.min(
                            parent.height,
                            Math.ceil(wallpaperList.count / Math.max(1, Math.floor(parent.width / 120))) * (120 * 9 / 16 + 8)
                        )
                        cellWidth: 120
                        cellHeight: 120 * 9 / 16 + 8
                        model: wallpaperList
                        clip: true
                    
                    delegate: Rectangle {
                            id: wallpaperItem
                            width: wallpaperGrid.cellWidth - 8
                            height: 120 * 9 / 16
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
            running: Services.ConfigService.initialized
            property string wallpaperDir: {
                var dir = Services.ConfigService.initialized ? Services.ConfigService.wallpaperDirectory : Commons.Config.wallpaperDirectory
                return dir.startsWith("~") ? dir.replace("~", "$HOME") : dir
            }
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
        
        Process {
            id: directoryDialogProcess
            running: false
            command: ["sh", "-c", "zenity --file-selection --directory --title='Select Wallpaper Directory' 2>/dev/null || yad --file --directory --title='Select Wallpaper Directory' 2>/dev/null || echo ''"]
            
            onRunningChanged: {
                if (running) {
                    popupWindow.shouldShow = true
                }
            }
            
            stdout: StdioCollector {
                onStreamFinished: {
                    var selectedDir = text.trim()
                    if (selectedDir.length > 0) {
                        directoryInput.text = selectedDir
                        saveDirectory()
                    }
                }
            }
        }
        
        Connections {
            target: Services.ConfigService
            function onWallpaperDirectoryChanged() {
                directoryInput.text = Services.ConfigService.wallpaperDirectory
                refresh()
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
    
    function saveDirectory() {
        var newDir = directoryInput.text.trim()
        if (newDir.length > 0) {
            Services.ConfigService.setWallpaperDirectory(newDir)
            directoryInput.focus = false
            refresh()
        }
    }
    
    function openDirectoryDialog() {
        directoryDialogProcess.running = true
    }
}
