import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import "../../Widgets" as Widgets
import "../../Services" as Services
import "." as Wallpaper

ColumnLayout {
    id: root
    
    signal wallpaperSelected(string filePath)
    signal copyRequested(string filePath)
    signal openRequested(string filePath)
    signal deleteRequested(string filePath, string fileName)
    
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 12
    
    RowLayout {
        Layout.fillWidth: true
        Item {
            Layout.fillWidth: true
        }
        Widgets.IconButton {
            width: 28
            height: 28
            icon: "\uf01e"
            iconSize: 12
            iconColor: Wallpaper.WallpaperColors.subText
            hoverIconColor: Wallpaper.WallpaperColors.primary
            baseColor: "transparent"
            hoverColor: Qt.rgba(Wallpaper.WallpaperColors.primary.r, Wallpaper.WallpaperColors.primary.g, Wallpaper.WallpaperColors.primary.b, 0.15)
            onClicked: Services.WallpaperService.refresh()
        }
    }
    
    Widgets.ImageGrid {
        Layout.fillWidth: true
        Layout.fillHeight: true
        model: Services.WallpaperService.wallpaperList
        backgroundColor: Wallpaper.WallpaperColors.surfaceContainer
        
        delegate: Widgets.ImageGridItem {
            required property string filePath
            required property string fileName
            
            width: 180 - 8
            height: 180 * 9 / 16 + 8 - 8
            imageSource: "file://" + filePath
            tooltipText: fileName
            
            onClicked: root.wallpaperSelected(filePath)
            onRightClicked: {
                contextMenu.filePath = filePath
                contextMenu.fileName = fileName
                contextMenu.popup()
            }
        }
        
        Widgets.EmptyState {
            anchors.centerIn: parent
            visible: Services.WallpaperService.wallpaperList.count === 0 && !Services.WallpaperService.loading
            icon: "󰈙"
            iconSize: 32
            iconOpacity: 0.2
            title: "No wallpapers found"
            subtitle: "Check the directory: " + (Services.ConfigService.wallpaperDirectory || "")
            textOpacity: 1.0
        }
    }
    
    Menu {
        id: contextMenu
        property string filePath: ""
        property string fileName: ""
        
        MenuItem {
            text: qsTr("Copy path")
            onTriggered: root.copyRequested(contextMenu.filePath)
        }
        MenuItem {
            text: qsTr("Open in file manager")
            onTriggered: root.openRequested(contextMenu.filePath)
        }
        MenuItem {
            text: qsTr("Delete")
            onTriggered: root.deleteRequested(contextMenu.filePath, contextMenu.fileName)
        }
    }
}