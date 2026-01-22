import QtQuick 6.10
import Quickshell
import Quickshell.Io
import "." as Services

Item {
    id: root
    
    // Reference to ConfigService for getting config path
    property var configService: Services.ConfigService
    
    // Expose monitors list model
    readonly property alias monitorsList: monitorsListModel
    
    // Expose loading state
    readonly property bool isLoading: monitorProcess.running
    
    // Monitors list model
    ListModel {
        id: monitorsListModel
    }
    
    // Pending changes - staged changes that will be applied when user clicks Apply
    // Format: { monitorName: { mode: {...}, scale: number, transform: number, mirror: string, positionX: number, positionY: number } }
    property var pendingChanges: ({})
    
    // Previous state - saved before applying changes, used for revert
    // Format: { monitorName: { mode: string, scale: number, transform: number, mirror: string, positionX: number, positionY: number } }
    property var previousState: ({})
    
    // Signal emitted when changes are applied (for showing confirmation dialog)
    signal changesApplied(var previousState)
    
    // Track if there are unsaved changes
    readonly property bool hasUnsavedChanges: {
        return Object.keys(pendingChanges).length > 0
    }
    
    // wlr-randr transform string -> Hyprland int (0-7)
    readonly property var _transformMap: ({
        "normal": 0, "90": 1, "180": 2, "270": 3,
        "flipped": 4, "flipped-90": 5, "flipped-180": 6, "flipped-270": 7
    })
    
    // Function to detect mirrors based on position (monitors at same position are mirrors)
    function _detectMirrors(monitors) {
        // Build a map of position -> list of monitors at that position
        var positionMap = {}
        for (var i = 0; i < monitors.length; i++) {
            var m = monitors[i]
            if (!m.enabled) continue
            
            var pos = m.position || {}
            var posX = pos.x !== undefined ? pos.x : 0
            var posY = pos.y !== undefined ? pos.y : 0
            var posKey = posX + "," + posY
            
            if (!positionMap[posKey]) {
                positionMap[posKey] = []
            }
            positionMap[posKey].push({
                index: i,
                name: m.name || "Unknown"
            })
        }
        
        // For each position with multiple monitors, mark all but first as mirrors
        var mirrorMap = {}
        for (var posKey in positionMap) {
            var monitorsAtPos = positionMap[posKey]
            if (monitorsAtPos.length > 1) {
                // First monitor is the source, others mirror it
                var sourceName = monitorsAtPos[0].name
                for (var j = 1; j < monitorsAtPos.length; j++) {
                    mirrorMap[monitorsAtPos[j].name] = sourceName
                }
            }
        }
        
        return mirrorMap
    }
    
    // Process for fetching monitors via wlr-randr --json (includes disabled outputs)
    Process {
        id: monitorProcess
        running: false
        command: ["sh", "-c", "wlr-randr --json 2>/dev/null"]
        
        stdout: StdioCollector {
            id: monitorStdout
            onStreamFinished: {
                var output = monitorStdout.text.trim()
                if (output.length === 0) {
                    monitorsListModel.clear()
                    return
                }
                
                try {
                    var arr = JSON.parse(output)
                    if (!Array.isArray(arr)) {
                        monitorsListModel.clear()
                        return
                    }
                    monitorsListModel.clear()
                    
                    // First pass: detect mirrors based on position
                    var mirrorMap = root._detectMirrors(arr)
                    
                    for (var i = 0; i < arr.length; i++) {
                        var m = arr[i]
                        var name = m.name || "Unknown"
                        var modes = m.modes || []
                        var formattedModes = []
                        var currentMode = ""
                        var monWidth = 1920
                        var monHeight = 1080
                        var preferredMode = null
                        
                        for (var j = 0; j < modes.length; j++) {
                            var mo = modes[j]
                            var w = mo.width || 1920
                            var h = mo.height || 1080
                            var rr = (mo.refresh !== undefined ? mo.refresh : 60)
                            var rrStr = (rr % 1 === 0) ? rr.toString() : rr.toFixed(2)
                            var fmt = w + "x" + h + "@" + rrStr + "Hz"
                            formattedModes.push({
                                width: w,
                                height: h,
                                refresh: rr,
                                formatted: fmt,
                                preferred: !!mo.preferred
                            })
                            if (mo.current) {
                                currentMode = fmt
                                monWidth = w
                                monHeight = h
                            }
                            if (mo.preferred && !preferredMode) {
                                preferredMode = { width: w, height: h, refresh: rr, formatted: fmt }
                            }
                        }
                        if (!currentMode && formattedModes.length > 0) {
                            var use = preferredMode || formattedModes[0]
                            currentMode = use.formatted
                            monWidth = use.width
                            monHeight = use.height
                        }
                        
                        var scale = (m.scale !== undefined && m.scale > 0) ? m.scale : 1.0
                        var trStr = (m.transform || "normal").toLowerCase()
                        var transform = root._transformMap[trStr] !== undefined ? root._transformMap[trStr] : 0
                        
                        var pos = m.position || {}
                        var posX = pos.x !== undefined ? pos.x : 0
                        var posY = pos.y !== undefined ? pos.y : 0
                        var enabled = m.enabled !== false
                        
                        // Get mirror target from position-based detection
                        var mirrorTarget = mirrorMap[name] || ""
                        
                        monitorsListModel.append({
                            name: name,
                            enabled: enabled,
                            currentMode: currentMode,
                            availableModesJson: JSON.stringify(formattedModes),
                            monitorScale: scale,
                            monitorTransform: transform,
                            mirrorTarget: mirrorTarget,
                            positionX: posX,
                            positionY: posY,
                            monitorWidth: monWidth,
                            monitorHeight: monHeight
                        })
                    }
                } catch (err) {
                    console.error("[DisplayManagerService] Failed to parse wlr-randr output:", err, output)
                    monitorsListModel.clear()
                }
            }
        }
    }
    
    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: root.refreshMonitors()
    }
    
    
    function refreshMonitors() {
        monitorProcess.running = false
        monitorsListModel.clear()
        monitorProcess.running = true
    }
    
    function toggleDisplay(monitorName, enabled) {
        for (var k = 0; k < monitorsListModel.count; k++) {
            var item = monitorsListModel.get(k)
            if (item.name === monitorName) {
                if (enabled && !item.currentMode && item.availableModesJson) {
                    try {
                        var modes = JSON.parse(item.availableModesJson)
                        var use = null
                        for (var j = 0; j < modes.length; j++) {
                            if (modes[j].preferred) { use = modes[j]; break }
                        }
                        if (!use && modes.length > 0) use = modes[0]
                        if (use) {
                            var rr = use.refresh
                            var rrStr = (rr % 1 === 0) ? rr.toString() : rr.toFixed(2)
                            var fmt = use.width + "x" + use.height + "@" + rrStr + "Hz"
                            monitorsListModel.setProperty(k, "currentMode", fmt)
                            monitorsListModel.setProperty(k, "monitorWidth", use.width)
                            monitorsListModel.setProperty(k, "monitorHeight", use.height)
                        }
                    } catch (e) {}
                }
                monitorsListModel.setProperty(k, "enabled", enabled)
                break
            }
        }
        writeMonitorConfig()
        refreshTimer.restart()
    }
    
    // Stage a mode change (does not apply until applyAllPendingChanges is called)
    function stageMode(monitorName, modeData) {
        console.log("[DisplayManagerService] stageMode called for:", monitorName, "mode:", JSON.stringify(modeData))
        
        var changes = pendingChanges[monitorName] || {}
        changes.mode = modeData
        
        // Create a new object to trigger property change notification
        var newPendingChanges = JSON.parse(JSON.stringify(pendingChanges))
        newPendingChanges[monitorName] = changes
        pendingChanges = newPendingChanges
        
        console.log("[DisplayManagerService] Pending changes updated:", JSON.stringify(pendingChanges))
    }
    
    // Arrange all enabled monitors side by side
    function arrangeMonitorsSideBySide() {
        console.log("[DisplayManagerService] Arranging monitors side by side")
        
        var positions = {}
        var currentX = 0
        
        // Get all enabled monitors, sorted by name for consistent ordering
        var enabledMonitors = []
        for (var i = 0; i < monitorsListModel.count; i++) {
            var monitor = monitorsListModel.get(i)
            if (monitor.enabled !== false) {
                enabledMonitors.push(monitor)
            }
        }
        
        // Sort by name for consistent ordering
        enabledMonitors.sort(function(a, b) {
            return a.name.localeCompare(b.name)
        })
        
        // Arrange side by side
        for (var j = 0; j < enabledMonitors.length; j++) {
            var m = enabledMonitors[j]
            positions[m.name] = { x: currentX, y: 0 }
            currentX += m.monitorWidth
        }
        
        // Stage all positions
        stageAllPositions(positions)
    }
    
    // Stage a setting change (scale, transform, mirror, position)
    function stageSetting(monitorName, settingName, value) {
        console.log("[DisplayManagerService] stageSetting called for:", monitorName, settingName, "=", value)
        
        // Check if mirroring is being stopped (mirror changed from non-empty to empty)
        if (settingName === "mirror" && (value === "" || value === null || value === undefined)) {
            // Find the monitor to check its current mirror state (check actual state, not pending)
            for (var i = 0; i < monitorsListModel.count; i++) {
                var monitor = monitorsListModel.get(i)
                if (monitor.name === monitorName) {
                    // Check the actual current mirror state (not pending changes)
                    var currentMirror = monitor.mirrorTarget || ""
                    // Also check if there's a pending mirror change that's non-empty
                    var pendingMirror = (pendingChanges[monitorName] && pendingChanges[monitorName].mirror !== undefined) ? pendingChanges[monitorName].mirror : null
                    var wasMirrored = (currentMirror && currentMirror !== "") || (pendingMirror && pendingMirror !== "")
                    
                    // If monitor was previously mirrored, arrange all monitors side by side
                    if (wasMirrored) {
                        console.log("[DisplayManagerService] Mirroring stopped for", monitorName, "- arranging monitors side by side")
                        // First stage the mirror change
                        var changes = pendingChanges[monitorName] || {}
                        changes[settingName] = value
                        var newPendingChanges = JSON.parse(JSON.stringify(pendingChanges))
                        newPendingChanges[monitorName] = changes
                        pendingChanges = newPendingChanges
                        // Then arrange monitors side by side (this will preserve the mirror change)
                        arrangeMonitorsSideBySide()
                        return
                    }
                    break
                }
            }
        }
        
        var changes = pendingChanges[monitorName] || {}
        changes[settingName] = value
        
        // Create a new object to trigger property change notification
        var newPendingChanges = JSON.parse(JSON.stringify(pendingChanges))
        newPendingChanges[monitorName] = changes
        pendingChanges = newPendingChanges
        
        console.log("[DisplayManagerService] Pending changes updated:", JSON.stringify(pendingChanges))
    }
    
    // Stage position changes for all monitors at once (for layout drag operations)
    function stageAllPositions(positions) {
        console.log("[DisplayManagerService] stageAllPositions called:", JSON.stringify(positions))
        
        var newPendingChanges = JSON.parse(JSON.stringify(pendingChanges))
        
        for (var monitorName in positions) {
            var pos = positions[monitorName]
            var changes = newPendingChanges[monitorName] || {}
            changes.positionX = Math.round(pos.x)
            changes.positionY = Math.round(pos.y)
            newPendingChanges[monitorName] = changes
        }
        
        pendingChanges = newPendingChanges
        console.log("[DisplayManagerService] Pending changes updated:", JSON.stringify(pendingChanges))
    }
    
    // Get the effective value for a monitor setting (pending value if exists, otherwise current)
    function getEffectiveValue(monitorName, settingName, currentValue) {
        var changes = pendingChanges[monitorName]
        if (changes && changes[settingName] !== undefined) {
            return changes[settingName]
        }
        return currentValue
    }
    
    // Get the effective mode for a monitor
    function getEffectiveMode(monitorName, currentMode) {
        var changes = pendingChanges[monitorName]
        if (changes && changes.mode) {
            return changes.mode.formatted
        }
        return currentMode
    }
    
    // Discard all pending changes
    function discardChanges() {
        console.log("[DisplayManagerService] Discarding all pending changes")
        pendingChanges = {}
    }
    
    // Apply all pending changes at once (config-only; Hyprland hot-reloads)
    function applyAllPendingChanges() {
        console.log("[DisplayManagerService] Applying all pending changes:", JSON.stringify(pendingChanges))
        
        if (!hasUnsavedChanges) {
            console.log("[DisplayManagerService] No pending changes to apply")
            return
        }
        
        // Save previous state before applying changes
        previousState = {}
        for (var i = 0; i < monitorsListModel.count; i++) {
            var monitor = monitorsListModel.get(i)
            var name = monitor.name
            var changes = pendingChanges[name]
            if (changes) {
                previousState[name] = {
                    mode: monitor.currentMode || "",
                    scale: monitor.monitorScale !== undefined ? monitor.monitorScale : 1.0,
                    transform: monitor.monitorTransform !== undefined ? monitor.monitorTransform : 0,
                    mirror: monitor.mirrorTarget || "",
                    positionX: monitor.positionX !== undefined ? monitor.positionX : 0,
                    positionY: monitor.positionY !== undefined ? monitor.positionY : 0
                }
            }
        }
        
        for (var i = 0; i < monitorsListModel.count; i++) {
            var monitor = monitorsListModel.get(i)
            var name = monitor.name
            var changes = pendingChanges[name]
            if (!changes) continue
            
            var mode = changes.mode
            if (mode) {
                monitorsListModel.setProperty(i, "currentMode", mode.formatted)
                monitorsListModel.setProperty(i, "monitorWidth", mode.width)
                monitorsListModel.setProperty(i, "monitorHeight", mode.height)
            }
            if (changes.scale !== undefined) {
                monitorsListModel.setProperty(i, "monitorScale", changes.scale)
            }
            if (changes.transform !== undefined) {
                monitorsListModel.setProperty(i, "monitorTransform", changes.transform)
            }
            if (changes.mirror !== undefined) {
                monitorsListModel.setProperty(i, "mirrorTarget", changes.mirror)
            }
            if (changes.positionX !== undefined) {
                monitorsListModel.setProperty(i, "positionX", changes.positionX)
            }
            if (changes.positionY !== undefined) {
                monitorsListModel.setProperty(i, "positionY", changes.positionY)
            }
        }
        
        pendingChanges = {}
        writeMonitorConfig()
        changesApplied(previousState)
        refreshTimer.restart()
    }
    
    // Revert to previous state (config-only; Hyprland hot-reloads)
    function revertToPreviousState() {
        console.log("[DisplayManagerService] Reverting to previous state:", JSON.stringify(previousState))
        
        if (Object.keys(previousState).length === 0) {
            console.log("[DisplayManagerService] No previous state to revert to")
            return
        }
        
        for (var i = 0; i < monitorsListModel.count; i++) {
            var monitor = monitorsListModel.get(i)
            var name = monitor.name
            var prev = previousState[name]
            if (!prev) continue
            
            monitorsListModel.setProperty(i, "currentMode", prev.mode || monitor.currentMode)
            if (prev.scale !== undefined) {
                monitorsListModel.setProperty(i, "monitorScale", prev.scale)
            }
            if (prev.transform !== undefined) {
                monitorsListModel.setProperty(i, "monitorTransform", prev.transform)
            }
            if (prev.mirror !== undefined) {
                monitorsListModel.setProperty(i, "mirrorTarget", prev.mirror)
            }
            if (prev.positionX !== undefined) {
                monitorsListModel.setProperty(i, "positionX", prev.positionX)
            }
            if (prev.positionY !== undefined) {
                monitorsListModel.setProperty(i, "positionY", prev.positionY)
            }
        }
        
        previousState = {}
        writeMonitorConfig()
        refreshTimer.restart()
    }
    
    
    // Generate Hyprland monitor configuration content (all outputs; disabled -> "monitor=NAME,disable")
    function generateMonitorConfig() {
        var lines = []
        lines.push("# Hyprland Monitor Configuration")
        lines.push("# Generated by basedgoose.shell Display Manager")
        lines.push("# See https://wiki.hypr.land/Configuring/Monitors/")
        lines.push("")
        
        for (var i = 0; i < monitorsListModel.count; i++) {
            var monitor = monitorsListModel.get(i)
            var name = monitor.name
            var enabled = monitor.enabled !== false
            
            if (!enabled) {
                lines.push("monitor = " + name + ", disable")
                continue
            }
            
            var currentMode = monitor.currentMode || ""
            var scale = monitor.monitorScale !== undefined ? monitor.monitorScale : 1.0
            var transform = monitor.monitorTransform !== undefined ? monitor.monitorTransform : 0
            var mirror = monitor.mirrorTarget || ""
            var posX = monitor.positionX !== undefined ? monitor.positionX : 0
            var posY = monitor.positionY !== undefined ? monitor.positionY : 0
            
            var match = currentMode.match(/(\d+x\d+)@([\d.]+)Hz/)
            if (!match) {
                var fallback = ""
                try {
                    var modes = JSON.parse(monitor.availableModesJson || "[]")
                    if (modes.length > 0) {
                        var m0 = modes[0]
                        var r = m0.refresh
                        var rs = (r % 1 === 0) ? r.toString() : r.toFixed(2)
                        fallback = m0.width + "x" + m0.height + "@" + rs + "Hz"
                    }
                } catch (e) {}
                if (!fallback) {
                    console.warn("[DisplayManagerService] Skipping monitor with invalid mode:", name, currentMode)
                    continue
                }
                match = fallback.match(/(\d+x\d+)@([\d.]+)Hz/)
            }
            
            var resolution = match[1] + "@" + match[2]
            var position = posX + "x" + posY
            var monitorLine = "monitor = " + name + ", " + resolution + ", " + position + ", " + scale
            if (transform !== 0) {
                monitorLine += ", transform, " + transform
            }
            if (mirror && mirror !== "") {
                monitorLine += ", mirror, " + mirror
            }
            lines.push(monitorLine)
        }
        
        lines.push("")
        return lines.join("\n")
    }
    
    // Write monitor configuration to file
    function writeMonitorConfig() {
        var configPath = configService.hyprlandMonitorsConfigPath
        if (!configPath || configPath === "") {
            console.warn("[DisplayManagerService] No monitor config path configured")
            return
        }
        
        // Expand ~ to $HOME
        var expandedPath = configPath.replace(/^~/, "$HOME")
        
        var configContent = generateMonitorConfig()
        console.log("[DisplayManagerService] Writing monitor config to:", expandedPath)
        console.log("[DisplayManagerService] Config content:\n" + configContent)
        
        // Ensure parent directory exists, then write config
        var escapedContent = configContent.replace(/'/g, "'\"'\"'")
        writeMonitorConfigProcess.command = ["sh", "-c", 
            "mkdir -p \"$(dirname " + expandedPath + ")\" && printf '%s' '" + escapedContent + "' > " + expandedPath
        ]
        writeMonitorConfigProcess.running = true
    }
    
    Process {
        id: writeMonitorConfigProcess
        running: false
        
        stdout: StdioCollector {
            onStreamFinished: {
                console.log("[DisplayManagerService] Monitor config written successfully")
            }
        }
        
        stderr: StdioCollector {
            onStreamFinished: {
                if (text.trim().length > 0) {
                    console.error("[DisplayManagerService] Error writing monitor config:", text.trim())
                }
            }
        }
    }
    
    Component.onCompleted: {
        refreshMonitors()
    }
}
