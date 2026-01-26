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
        command: ["sh", "-c", "find " + wallpaperDir + " -type f \\( -iname '*.jpg' -o -iname '*.jpeg' -o -iname '*.png' -o -iname '*.gif' -o -iname '*.webp' -o -iname '*.bmp' -o -iname '*.tiff' -o -iname '*.svg' -o -iname '*.avif' -o -iname '*.jxl' \\) 2>/dev/null"]

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

    property var popupWindow: null
    
    Process {
        id: directoryDialogProcess
        running: false
        command: ["sh", "-c", "zenity --file-selection --directory --title='Select Wallpaper Directory' 2>/dev/null || yad --file --directory --title='Select Wallpaper Directory' 2>/dev/null || echo ''"]

        stdout: StdioCollector {
            onStreamFinished: {
                if (root.popupWindow) {
                    root.popupWindow.shouldShow = true
                }
                var selectedDir = text.trim()
                if (selectedDir.length > 0) {
                    Services.ConfigService.setWallpaperDirectory(selectedDir)
                }
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                // Silent error handling
            }
        }
        
        onRunningChanged: {
            // Silent state tracking
        }
    }

    Process {
        id: copyProcess
        running: false
    }

    Process {
        id: openProcess
        running: false
    }

    Process {
        id: deleteProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                if (root.popupWindow) {
                    root.popupWindow.shouldShow = true
                }
                root.refresh()
            }
        }
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

    function openDirectoryDialog() {
        directoryDialogProcess.running = true
    }
    
    function copyToClipboard(text) {
        var escapedText = text.replace(/'/g, "'\"'\"'")
        copyProcess.command = ["sh", "-c", "printf '%s' '" + escapedText + "' | wl-copy"]
        copyProcess.running = false
        copyProcess.running = true
    }

    function openFile(path) {
        var escaped = path.replace(/'/g, "'\"'\"'")
        openProcess.command = ["sh", "-c", "xdg-open '" + escaped + "' 2>/dev/null &"]
        openProcess.running = false
        openProcess.running = true
    }

    function deleteFile(path, name) {
        var ePath = path.replace(/'/g, "'\"'\"'")
        var eName = name.replace(/'/g, "'\"'\"'")
        deleteProcess.command = ["sh", "-c", "(zenity --question --text='Delete " + eName + "?' 2>/dev/null || yad --question --text='Delete " + eName + "?' 2>/dev/null) && rm -f '" + ePath + "' && echo deleted || echo canceled"]
        deleteProcess.running = false
        deleteProcess.running = true
    }
}
