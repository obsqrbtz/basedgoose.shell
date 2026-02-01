pragma Singleton
import QtQuick
import "../Services" as Services

QtObject {
    id: config

    readonly property string barPosition: Services.ConfigService.initialized ? Services.ConfigService.barPosition : "top"
    
    readonly property var defaultBarModules: ({
        "left": ["shellmenu", "workspaces", "mediaplayer"],
        "center": ["systemstats"],
        "right": ["clock", "systemtray", "volume", "bluetooth", "notifications", "power"]
    })
    
    readonly property var barModules: Services.ConfigService.initialized ? Services.ConfigService.barModules : defaultBarModules
    
    Component.onCompleted: {
        console.log("[Config] ConfigService initialized:", Services.ConfigService.initialized)
        console.log("[Config] barPosition:", barPosition)
        console.log("[Config] barModules type:", typeof barModules)
        console.log("[Config] barModules:", JSON.stringify(barModules))
        console.log("[Config] barModules.left:", barModules.left)
    }

    readonly property int barHeight: 42
    readonly property int barWidth: 48
    readonly property int barMargin: 6
    readonly property int barPadding: 6
    readonly property int barSpacing: 4

    readonly property int componentHeight: 30
    readonly property int componentPadding: 8

    readonly property int workspaceCount: 9
    readonly property int workspaceIndicatorWidth: 10
    readonly property int workspaceIndicatorActiveWidth: 32
    readonly property int workspaceIndicatorHeight: 10
    readonly property int workspaceIndicatorRadius: 5
    readonly property int workspaceSpacing: 8

    readonly property int statsSeparatorWidth: 1
    readonly property int statsSeparatorHeight: 14
    readonly property real statsSeparatorOpacity: 0.3
    readonly property int statsSpacing: 10
    readonly property int statsLabelSpacing: 8

    readonly property int trayIconSize: 28
    readonly property int trayIconImageSize: 18
    readonly property int trayIconRadius: 6
    readonly property int traySpacing: 0

    readonly property string clockFormat: "HH:mm  ddd MMM dd"
    readonly property int clockUpdateInterval: 1000

    readonly property int powerButtonSize: 28
    readonly property int powerButtonRadius: 6

    readonly property int popupMargin: 12

    readonly property int cpuUpdateInterval: 3000
    readonly property int memoryUpdateInterval: 3000

    readonly property string wallpaperDirectory: Services.ConfigService.initialized ? Services.ConfigService.wallpaperDirectory : "~/Pictures/walls"

    readonly property var notifications: ({
            popupWidth: 320,
            spacing: 10,
            margin: 12,
            maxVisible: 5,
            timeout: 8000,
            centerWidth: 420,
            centerHeight: 600,
            centerMargin: 12,
            itemHeight: 100,
            itemSpacing: 8,
            centerRadius: 16 // Use Theme.radius * 2 instead
            ,
            groupSpacing: 16
        })

    readonly property var mediaPlayer: ({
            popupWidth: 360,
            popupMargin: 36,
            albumArtSize: 280,
            controlSize: 44,
            playButtonSize: 56
        })
}
