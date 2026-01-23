pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io

Singleton {
    id: root
    
    readonly property string configPath: "$HOME/.config/basedgoose.shell/config.json"
    
    property string wallpaperDirectory: "~/Pictures/walls"
    property string hyprlandMonitorsConfigPath: "~/.config/hypr/hyprland/monitors.conf"
    property bool initialized: false
    
    Component.onCompleted: {
        loadConfig()
    }
    
    function loadConfig() {
        var configDir = "$HOME/.config/basedgoose.shell"
        
        createDirProcess.command = ["sh", "-c", "mkdir -p " + configDir]
        createDirProcess.running = true
    }
    
    Process {
        id: createDirProcess
        stdout: StdioCollector {
            onStreamFinished: {
                readConfigProcess.running = true
            }
        }
    }
    
    Process {
        id: readConfigProcess
        running: false
        command: ["sh", "-c", "cat " + root.configPath + " 2>/dev/null || echo '{}'"]
        
        stdout: StdioCollector {
            onStreamFinished: {
                var configText = text.trim()
                if (configText.length === 0) {
                    configText = "{}"
                }
                
                try {
                    var config = JSON.parse(configText)
                    if (config.wallpaperDirectory) {
                        root.wallpaperDirectory = config.wallpaperDirectory
                    }
                    if (config.hyprlandMonitorsConfigPath) {
                        root.hyprlandMonitorsConfigPath = config.hyprlandMonitorsConfigPath
                    }
                    // Save config if any defaults are missing
                    if (!config.wallpaperDirectory || !config.hyprlandMonitorsConfigPath) {
                        root.saveConfig()
                    }
                } catch (e) {
                    console.error("[ConfigService] Failed to parse config:", e)
                    root.saveConfig()
                }
                
                root.initialized = true
            }
        }
    }
    
    function saveConfig() {
        var config = {
            wallpaperDirectory: root.wallpaperDirectory,
            hyprlandMonitorsConfigPath: root.hyprlandMonitorsConfigPath
        }
        
        var configJson = JSON.stringify(config, null, 2)
        var escapedJson = configJson.replace(/%/g, "%%").replace(/'/g, "'\"'\"'")
        writeConfigProcess.command = ["sh", "-c", "printf '%s' '" + escapedJson + "' > " + root.configPath]
        writeConfigProcess.running = true
    }
    
    Process {
        id: writeConfigProcess
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[ConfigService] Config saved to", root.configPath)
            }
        }
    }
    
    function setWallpaperDirectory(path) {
        root.wallpaperDirectory = path
        root.saveConfig()
    }
    
    function setHyprlandMonitorsConfigPath(path) {
        root.hyprlandMonitorsConfigPath = path
        root.saveConfig()
    }
}
