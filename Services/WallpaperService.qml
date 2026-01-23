pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "." as Services

Singleton {
    id: root

    signal wallpaperApplied()

    readonly property alias wallpaperList: listModel
    readonly property bool loading: loadingProcess.running

    ListModel {
        id: listModel
    }

    Process {
        id: loadingProcess
        running: false
        property string wallpaperDir: Services.ConfigService.initialized
            ? (Services.ConfigService.wallpaperDirectory.startsWith("~")
               ? Services.ConfigService.wallpaperDirectory.replace("~", "$HOME")
               : Services.ConfigService.wallpaperDirectory)
            : ""
        command: ["sh", "-c", "find " + wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.svg' -o -iname '*.avif' -o -iname '*.jxl' \\) 2>/dev/null | head -100"]

        stdout: StdioCollector {
            onStreamFinished: {
                var output = text.trim()
                var lines = output.split('\n').filter(function(line) { return line.length > 0 })
                listModel.clear()

                for (var i = 0; i < lines.length; i++) {
                    var filePath = lines[i].trim()
                    if (filePath.length > 0) {
                        var fileName = filePath.substring(filePath.lastIndexOf("/") + 1)
                        listModel.append({
                            filePath: filePath,
                            fileName: fileName
                        })
                    }
                }
            }
        }
    }

    Process {
        id: setWallpaperProcess
        running: false
        command: []
        stdout: StdioCollector { }
    }

    function refresh() {
        loadingProcess.running = false
        listModel.clear()
        loadingProcess.running = true
    }

    function setWallpaper(filePath) {
        var mode = Services.ConfigService.wallpaperResizeMode
        setWallpaperProcess.command = ["awww", "img", filePath, "--resize", mode, "--transition-fps", "60", "--transition-type", "outer"]
        setWallpaperProcess.running = true
        wallpaperApplied()
    }
}
