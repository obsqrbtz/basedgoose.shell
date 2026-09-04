pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string configDir: `${Quickshell.env("HOME")}/.config/basedgoose.shell`
    readonly property string cacheDir: `${Quickshell.env("HOME")}/.cache/basedgoose.shell`
    readonly property string schemeDir: `${configDir}/colorschemes`

    property alias colorScheme: adapter.colorScheme
    property alias barPosition: adapter.barPosition
    property alias barModules: adapter.barModules
    property alias wallpaperDir: adapter.wallpaperDir
    property alias wallpaperDownloadDir: adapter.wallpaperDownloadDir
    property alias wallpaperResizeMode: adapter.wallpaperResizeMode
    property alias monitorServers: adapter.monitorServers
    property alias outputConfigPath: adapter.outputConfigPath

    readonly property bool barVertical: barPosition === "left" || barPosition === "right"
    readonly property var barPositions: ["top", "bottom", "left", "right"]

    function expand(path: string): string {
        return path.startsWith("~") ? Quickshell.env("HOME") + path.slice(1) : path;
    }

    FileView {
        path: `${root.configDir}/config.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: adapter

            property string colorScheme: "based-goose"
            property string barPosition: "top"
            property var barModules: ({
                left: ["menu", "workspaces", "media"],
                center: ["stats"],
                right: ["network", "clock", "tray", "volume", "bluetooth", "notifications", "power"]
            })
            property string wallpaperDir: "~/Pictures/walls"
            property string wallpaperDownloadDir: "~/Pictures/walls/downloaded"
            property string wallpaperResizeMode: "fit"
            property var monitorServers: []
            property string outputConfigPath: ""
        }
    }
}
