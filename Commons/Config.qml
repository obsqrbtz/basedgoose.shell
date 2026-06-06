pragma Singleton
import QtQuick
import "../Services" as Services

QtObject {
    id: config

    readonly property string barPosition: Services.ConfigService.initialized ? Services.ConfigService.barPosition : "top"
    
    readonly property var defaultBarModules: ({
        "left": ["shellmenu", "workspaces", "mediaplayer"],
        "center": ["systemstats"],
        "right": ["network", "clock", "systemtray", "volume", "bluetooth", "notifications", "power"]
    })
    
    readonly property var barModules: Services.ConfigService.initialized ? Services.ConfigService.barModules : defaultBarModules
    
    Component.onCompleted: {
        console.log("[Config] ConfigService initialized:", Services.ConfigService.initialized)
        console.log("[Config] barPosition:", barPosition)
        console.log("[Config] barModules type:", typeof barModules)
        console.log("[Config] barModules:", JSON.stringify(barModules))
        console.log("[Config] barModules.left:", barModules.left)
    }

    readonly property int barHeight: 36
    readonly property int barWidth: 44
    readonly property int barMargin: 0
    readonly property int barPadding: 6
    readonly property int barSpacing: 4
    readonly property int sectionPillPadding: 6

    readonly property int componentHeight: 26
    readonly property int componentPadding: 6

    readonly property int workspaceCount: 9
    readonly property int workspaceIndicatorWidth: 8
    readonly property int workspaceIndicatorActiveWidth: 28
    readonly property int workspaceIndicatorHeight: 8
    readonly property int workspaceIndicatorInactiveHeight: 5
    readonly property int workspaceIndicatorRadius: 3
    readonly property int workspaceSpacing: 6

    readonly property int statsSeparatorWidth: 1
    readonly property int statsSeparatorHeight: 12
    readonly property real statsSeparatorOpacity: 0.4
    readonly property int statsSpacing: 8
    readonly property int statsLabelSpacing: 4

    readonly property int trayIconSize: 18
    readonly property int trayIconImageSize: 12
    readonly property int trayIconRadius: Theme.radiusSm
    readonly property int traySpacing: 2

    readonly property string clockFormat: "HH:mm  ddd MMM dd"
    readonly property int clockUpdateInterval: 1000

    readonly property int powerButtonSize: 24
    readonly property int powerButtonRadius: Theme.radiusLg

    readonly property int popupMargin: 12
    readonly property int popupContentPadding: 14

    readonly property int cpuUpdateInterval: 3000
    readonly property int memoryUpdateInterval: 3000
    readonly property int driveUpdateInterval: 3000

    readonly property string wallpaperDirectory: Services.ConfigService.initialized ? Services.ConfigService.wallpaperDirectory : "~/Pictures/walls"
    readonly property string wallpaperDownloadDirectory: Services.ConfigService.initialized ? Services.ConfigService.wallpaperDownloadDirectory : "~/Pictures/walls/downloaded"

    readonly property var notifications: ({
            popupWidth: 300,
            spacing: 8,
            margin: 12,
            maxVisible: 5,
            timeout: 8000,
            centerWidth: 380,
            centerHeight: 520,
            centerMargin: 14,
            itemHeight: 76,
            itemSpacing: 6,
            centerRadius: Theme.radiusPanel,
            groupSpacing: 12
        })

    readonly property var mediaPlayer: ({
            popupWidth: 300,
            popupMargin: 28,
            albumArtSize: 200,
            controlSize: 34,
            playButtonSize: 44
        })
}
