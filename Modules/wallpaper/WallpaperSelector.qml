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
    Component.onCompleted: {
        if (Services.ConfigService.initialized)
            Services.WallpaperService.refresh()
    }
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
    
    property int currentTab: 0  // 0 = Local, 1 = Wallhaven, 2 = Settings
    property string wallhavenSorting: "date_added"
    property string wallhavenTopRange: "1M"
    property int wallhavenPage: 1
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: 100
        left: Quickshell.screens[0] ? (Quickshell.screens[0].width - implicitWidth) / 2 : 0
    }
    
    implicitWidth: 600
    implicitHeight: 540
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: cSurface
        radius: Commons.Theme.radius * 2
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
                        text: "\uf03e"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 18
                        color: cPrimary
                    }
                }
                
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    
                    Text {
                        text: "Wallpaper Selector"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 15
                        font.weight: Font.Bold
                        color: cText
                    }
                    
                    Text {
                        text: currentTab === 0
                            ? (Services.WallpaperService.wallpaperList.count > 0 ? Services.WallpaperService.wallpaperList.count + " wallpapers found" : "Loading...")
                            : (currentTab === 1
                                ? (Services.WallhavenAPIService.running ? "Loading..." : "Page " + wallhavenPage + " of " + Services.WallhavenAPIService.lastPage)
                                : "Directory and resize mode")
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 11
                        color: cSubText
                    }
                }
            }
            
            Row {
                Layout.fillWidth: true
                spacing: 4
                Rectangle {
                    width: 100
                    height: 32
                    radius: 8
                    color: currentTab === 0 ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.2) : cSurfaceContainer
                    border.width: 1
                    border.color: currentTab === 0 ? cPrimary : cBorder
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentTab = 0
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Local"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        color: cText
                    }
                }
                Rectangle {
                    width: 100
                    height: 32
                    radius: 8
                    color: currentTab === 1 ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.2) : cSurfaceContainer
                    border.width: 1
                    border.color: currentTab === 1 ? cPrimary : cBorder
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            currentTab = 1
                            if (Services.WallhavenAPIService.wallhavenList.count === 0 && !Services.WallhavenAPIService.running) refreshWallhaven()
                        }
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Wallhaven"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        color: cText
                    }
                }
                Rectangle {
                    width: 100
                    height: 32
                    radius: 8
                    color: currentTab === 2 ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.2) : cSurfaceContainer
                    border.width: 1
                    border.color: currentTab === 2 ? cPrimary : cBorder
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: currentTab = 2
                    }
                    Text {
                        anchors.centerIn: parent
                        text: "Settings"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        color: cText
                    }
                }
            }
            
            StackLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                currentIndex: currentTab
                
                // Local tab
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    
                    RowLayout {
                        Layout.fillWidth: true
                        Item { Layout.fillWidth: true }
                        Widgets.IconButton {
                            width: 28
                            height: 28
                            icon: "\uf01e"
                            iconSize: 12
                            iconColor: cSubText
                            hoverIconColor: cPrimary
                            baseColor: "transparent"
                            hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                            onClicked: Services.WallpaperService.refresh()
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
                            Math.ceil(Services.WallpaperService.wallpaperList.count / Math.max(1, Math.floor(parent.width / 120))) * (120 * 9 / 16 + 8)
                        )
                        cellWidth: 120
                        cellHeight: 120 * 9 / 16 + 8
                        model: Services.WallpaperService.wallpaperList
                        clip: true
                    
                    delegate: Rectangle {
                            id: wallpaperItem
                            width: wallpaperGrid.cellWidth - 8
                            height: 120 * 9 / 16
                            radius: Commons.Theme.radius
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
                                    font.family: Commons.Theme.fontIcon
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
                                    Services.WallpaperService.setWallpaper(wallpaperItem.filePath)
                                }
                            }
                        }
                    }
                }
                    
                Widgets.EmptyState {
                    anchors.centerIn: parent
                    visible: Services.WallpaperService.wallpaperList.count === 0 && !Services.WallpaperService.loading
                    icon: "󰈙"
                    iconSize: 32
                    iconOpacity: 0.2
                    title: "No wallpapers found"
                    subtitle: "Check the directory: " + Commons.Config.wallpaperDirectory
                    textOpacity: 1.0
                }
            }
                }
                
                // Wallhaven tab
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 8
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 6
                        Repeater {
                            model: [
                                { key: "date_added", label: "Latest" },
                                { key: "hot", label: "Hot" },
                                { key: "toplist", label: "Top" },
                                { key: "random", label: "Random" }
                            ]
                            Rectangle {
                                Layout.preferredWidth: 72
                                Layout.preferredHeight: 28
                                radius: 6
                                color: wallhavenSorting === modelData.key ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.25) : cSurfaceContainer
                                border.width: 1
                                border.color: wallhavenSorting === modelData.key ? cPrimary : cBorder
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallhavenSorting = modelData.key
                                        wallhavenPage = 1
                                        refreshWallhaven()
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: Commons.Theme.fontUI
                                    font.pixelSize: 11
                                    color: cText
                                }
                            }
                        }
                        Item { Layout.fillWidth: true }
                        Widgets.IconButton {
                            width: 28
                            height: 28
                            icon: "\uf01e"
                            iconSize: 12
                            iconColor: cSubText
                            hoverIconColor: cPrimary
                            baseColor: "transparent"
                            hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                            onClicked: refreshWallhaven()
                        }
                    }
                    
                    Row {
                        Layout.fillWidth: true
                        visible: wallhavenSorting === "toplist"
                        spacing: 4
                        Repeater {
                            model: ["1d", "3d", "1w", "1M", "3M", "6M", "1y"]
                            Rectangle {
                                width: 36
                                height: 24
                                radius: 4
                                color: wallhavenTopRange === modelData ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.2) : cSurfaceContainer
                                border.width: 1
                                border.color: wallhavenTopRange === modelData ? cPrimary : cBorder
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        wallhavenTopRange = modelData
                                        wallhavenPage = 1
                                        refreshWallhaven()
                                    }
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData
                                    font.family: Commons.Theme.fontUI
                                    font.pixelSize: 10
                                    color: cText
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
                                id: wallhavenGrid
                                anchors.centerIn: parent
                                width: Math.floor((parent.width / 120)) * 120
                                height: Math.min(
                                    parent.height,
                                    Math.ceil(Services.WallhavenAPIService.wallhavenList.count / Math.max(1, Math.floor(parent.width / 120))) * (120 * 9 / 16 + 8)
                                )
                                cellWidth: 120
                                cellHeight: 120 * 9 / 16 + 8
                                model: Services.WallhavenAPIService.wallhavenList
                                clip: true
                                
                                delegate: Rectangle {
                                    id: whItem
                                    width: wallhavenGrid.cellWidth - 8
                                    height: 120 * 9 / 16
                                    radius: Commons.Theme.radius
                                    color: whArea.containsMouse ? cHover : "transparent"
                                    border.width: whArea.containsMouse ? 2 : 1
                                    border.color: whArea.containsMouse ? cPrimary : cBorder
                                    
                                    required property string id
                                    required property string thumbUrl
                                    required property string fullUrl
                                    required property string resolution
                                    
                                    Behavior on color { ColorAnimation { duration: 100 } }
                                    Behavior on border.color { ColorAnimation { duration: 100 } }
                                    
                                    Rectangle {
                                        anchors.fill: parent
                                        anchors.margins: 4
                                        radius: 6
                                        color: cSurface
                                        clip: true
                                        
                                        Image {
                                            anchors.fill: parent
                                            source: whItem.thumbUrl
                                            sourceSize: Qt.size(240, 240)
                                            fillMode: Image.PreserveAspectCrop
                                            asynchronous: true
                                            smooth: true
                                            
                                            onStatusChanged: {
                                                if (status === Image.Error) whError.visible = true
                                            }
                                        }
                                        
                                        Text {
                                            id: whError
                                            anchors.centerIn: parent
                                            text: "󰈙"
                                            font.family: Commons.Theme.fontIcon
                                            font.pixelSize: 24
                                            color: cSubText
                                            visible: false
                                        }
                                        
                                        Text {
                                            anchors.left: parent.left
                                            anchors.bottom: parent.bottom
                                            anchors.margins: 4
                                            text: whItem.resolution
                                            font.family: Commons.Theme.fontUI
                                            font.pixelSize: 9
                                            color: cText
                                            style: Text.Outline
                                            styleColor: Qt.rgba(0,0,0,0.8)
                                        }
                                    }
                                    
                                    MouseArea {
                                        id: whArea
                                        anchors.fill: parent
                                        hoverEnabled: true
                                        cursorShape: Qt.PointingHandCursor
                                        onClicked: Services.WallhavenAPIService.downloadAndSet(whItem.id, whItem.fullUrl)
                                    }
                                }
                            }
                            
                            Widgets.EmptyState {
                                anchors.centerIn: parent
                                visible: Services.WallhavenAPIService.wallhavenList.count === 0 && !Services.WallhavenAPIService.running
                                icon: "󰈙"
                                iconSize: 32
                                iconOpacity: 0.2
                                title: Services.WallhavenAPIService.wallhavenList.count === 0 && !Services.WallhavenAPIService.running && Services.WallhavenAPIService.loadedOnce ? "Failed to load" : "Choose a category to load"
                                subtitle: ""
                                textOpacity: 1.0
                            }
                        }
                    }
                    
                    Row {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 32
                        spacing: 8
                        Widgets.IconButton {
                            width: 32
                            height: 32
                            icon: "\uf060"
                            iconSize: 12
                            iconColor: wallhavenPage <= 1 ? cSubText : cText
                            hoverIconColor: cPrimary
                            baseColor: "transparent"
                            hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                            onClicked: { if (wallhavenPage > 1) { wallhavenPage--; refreshWallhaven() } }
                        }
                        Text {
                            anchors.verticalCenter: parent.verticalCenter
                            text: "Page " + wallhavenPage + " of " + Services.WallhavenAPIService.lastPage
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 11
                            color: cSubText
                        }
                        Widgets.IconButton {
                            width: 32
                            height: 32
                            icon: "\uf061"
                            iconSize: 12
                            iconColor: wallhavenPage >= Services.WallhavenAPIService.lastPage ? cSubText : cText
                            hoverIconColor: cPrimary
                            baseColor: "transparent"
                            hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                            onClicked: { if (wallhavenPage < Services.WallhavenAPIService.lastPage) { wallhavenPage++; refreshWallhaven() } }
                        }
                    }
                }
                
                // Settings tab
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    spacing: 12
                    
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
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cText
                            }
                            TextInput {
                                id: directoryInput
                                Layout.fillWidth: true
                                text: Services.ConfigService.wallpaperDirectory
                                font.family: Commons.Theme.fontUI
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
                                Keys.onReturnPressed: saveDirectory()
                                Keys.onEscapePressed: {
                                    text = Services.ConfigService.wallpaperDirectory
                                    focus = false
                                }
                            }
                            Widgets.IconButton {
                                width: 32
                                height: 32
                                Layout.alignment: Qt.AlignVCenter
                                icon: "\uf4d3"
                                iconSize: 14
                                iconColor: cSubText
                                hoverIconColor: cPrimary
                                baseColor: "transparent"
                                hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                                onClicked: openDirectoryDialog()
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
                                onClicked: saveDirectory()
                            }
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Layout.leftMargin: 8
                        Layout.rightMargin: 8
                        spacing: 6
                        Text {
                            text: "Resize:"
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 12
                            color: cText
                            Layout.alignment: Qt.AlignVCenter
                        }
                        Repeater {
                            model: [
                                { key: "no", label: "No" },
                                { key: "crop", label: "Crop" },
                                { key: "fit", label: "Fit" },
                                { key: "stretch", label: "Stretch" }
                            ]
                            Rectangle {
                                Layout.preferredWidth: 64
                                Layout.preferredHeight: 28
                                radius: 6
                                color: Services.ConfigService.wallpaperResizeMode === modelData.key ? Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.25) : cSurfaceContainer
                                border.width: 1
                                border.color: Services.ConfigService.wallpaperResizeMode === modelData.key ? cPrimary : cBorder
                                MouseArea {
                                    anchors.fill: parent
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: Services.ConfigService.setWallpaperResizeMode(modelData.key)
                                }
                                Text {
                                    anchors.centerIn: parent
                                    text: modelData.label
                                    font.family: Commons.Theme.fontUI
                                    font.pixelSize: 11
                                    color: cText
                                }
                            }
                        }
                    }
                }
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
                Services.WallpaperService.refresh()
            }
            function onInitializedChanged() {
                if (Services.ConfigService.initialized) {
                    directoryInput.text = Services.ConfigService.wallpaperDirectory
                    Services.WallpaperService.refresh()
                }
            }
        }

        Connections {
            target: Services.WallpaperService
            function onWallpaperApplied() {
                popupWindow.shouldShow = false
            }
        }
    }

    function saveDirectory() {
        var newDir = directoryInput.text.trim()
        if (newDir.length > 0) {
            Services.ConfigService.setWallpaperDirectory(newDir)
            directoryInput.focus = false
            Services.WallpaperService.refresh()
        }
    }

    function openDirectoryDialog() {
        directoryDialogProcess.running = true
    }

    function refreshWallhaven() {
        Services.WallhavenAPIService.refresh(wallhavenSorting, wallhavenPage, wallhavenTopRange, Services.WallhavenAPIService.seed)
    }
}
