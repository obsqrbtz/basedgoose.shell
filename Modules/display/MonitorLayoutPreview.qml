import QtQuick 6.10
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Rectangle {
    id: root
    
    // Model containing monitors with: name, positionX, positionY, monitorWidth, monitorHeight, monitorScale
    property var monitorsModel: null
    
    // Pending changes from the service
    property var pendingChanges: ({})
    
    // Theme colors
    property color cSurface: Commons.Theme.background
    property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    property color cPrimary: Commons.Theme.secondary
    property color cText: Commons.Theme.foreground
    property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.15)
    
    // Signal emitted when positions change
    signal positionsChanged(var positions)
    
    // Currently selected/dragging monitor
    property string selectedMonitor: ""
    property bool isDragging: false
    
    // Helper function to get effective position for a monitor
    function getEffectivePosition(monitor) {
        var changes = pendingChanges[monitor.name]
        return {
            x: (changes && changes.positionX !== undefined) ? changes.positionX : monitor.positionX,
            y: (changes && changes.positionY !== undefined) ? changes.positionY : monitor.positionY
        }
    }
    
    // Get all monitors at the same position (for mirrored monitors)
    function getMonitorsAtPosition(posX, posY) {
        var monitors = []
        if (!monitorsModel) return monitors
        
        for (var i = 0; i < monitorsModel.count; i++) {
            var monitor = monitorsModel.get(i)
            var pos = getEffectivePosition(monitor)
            if (pos.x === posX && pos.y === posY) {
                monitors.push(monitor)
            }
        }
        return monitors
    }
    
    // Check if two monitors are adjacent (share an edge)
    function areMonitorsAdjacent(mon1, pos1, mon2, pos2) {
        var m1Left = pos1.x
        var m1Right = pos1.x + mon1.monitorWidth
        var m1Top = pos1.y
        var m1Bottom = pos1.y + mon1.monitorHeight
        
        var m2Left = pos2.x
        var m2Right = pos2.x + mon2.monitorWidth
        var m2Top = pos2.y
        var m2Bottom = pos2.y + mon2.monitorHeight
        
        // Check horizontal adjacency (left/right edges touch and y ranges overlap)
        var horizontalAdjacent = (m1Right === m2Left || m1Left === m2Right) && 
                                  !(m1Bottom <= m2Top || m1Top >= m2Bottom)
        
        // Check vertical adjacency (top/bottom edges touch and x ranges overlap)
        var verticalAdjacent = (m1Bottom === m2Top || m1Top === m2Bottom) && 
                               !(m1Right <= m2Left || m1Left >= m2Right)
        
        return horizontalAdjacent || verticalAdjacent
    }
    
    // Find the nearest adjacent position for a monitor
    // Allows placement anywhere along an edge (not just corners) while maintaining adjacency
    function findNearestAdjacentPosition(monitor, targetX, targetY) {
        if (!monitorsModel || monitorsModel.count <= 1) {
            // If only one monitor, just ensure non-negative
            return { x: Math.max(0, targetX), y: Math.max(0, targetY) }
        }
        
        var bestX = Math.max(0, targetX)
        var bestY = Math.max(0, targetY)
        var bestDistance = Infinity
        
        // Try all possible adjacent positions to other monitors
        for (var i = 0; i < monitorsModel.count; i++) {
            var other = monitorsModel.get(i)
            if (other.name === monitor.name) continue
            
            var otherPos = getEffectivePosition(other)
            var otherLeft = otherPos.x
            var otherRight = otherPos.x + other.monitorWidth
            var otherTop = otherPos.y
            var otherBottom = otherPos.y + other.monitorHeight
            
            // Right of other monitor: x is fixed, y can vary along the edge
            var x1 = otherRight
            if (x1 >= 0) {
                // Find valid y range for adjacency (must have vertical overlap)
                // Adjacency requires: monitor.y + monitor.monitorHeight > otherTop && monitor.y < otherBottom
                // Which means: monitor.y > otherTop - monitor.monitorHeight && monitor.y < otherBottom
                var yMin1 = Math.max(0, otherTop - monitor.monitorHeight + 1)
                var yMax1 = otherBottom - 1
                if (yMin1 <= yMax1) {
                    // Clamp targetY to valid range
                    var y1 = Math.max(yMin1, Math.min(yMax1, targetY))
                    var dist = Math.abs(x1 - targetX) + Math.abs(y1 - targetY)
                    if (dist < bestDistance) {
                        bestX = x1
                        bestY = y1
                        bestDistance = dist
                    }
                }
            }
            
            // Left of other monitor: x is fixed, y can vary along the edge
            var x2 = otherLeft - monitor.monitorWidth
            if (x2 >= 0) {
                // Find valid y range for adjacency
                var yMin2 = Math.max(0, otherTop - monitor.monitorHeight + 1)
                var yMax2 = otherBottom - 1
                if (yMin2 <= yMax2) {
                    var y2 = Math.max(yMin2, Math.min(yMax2, targetY))
                    var dist = Math.abs(x2 - targetX) + Math.abs(y2 - targetY)
                    if (dist < bestDistance) {
                        bestX = x2
                        bestY = y2
                        bestDistance = dist
                    }
                }
            }
            
            // Below other monitor: y is fixed, x can vary along the edge
            var y3 = otherBottom
            if (y3 >= 0) {
                // Find valid x range for adjacency (must have horizontal overlap)
                // Adjacency requires: monitor.x + monitor.monitorWidth > otherLeft && monitor.x < otherRight
                // Which means: monitor.x > otherLeft - monitor.monitorWidth && monitor.x < otherRight
                var xMin3 = Math.max(0, otherLeft - monitor.monitorWidth + 1)
                var xMax3 = otherRight - 1
                if (xMin3 <= xMax3) {
                    var x3 = Math.max(xMin3, Math.min(xMax3, targetX))
                    var dist = Math.abs(x3 - targetX) + Math.abs(y3 - targetY)
                    if (dist < bestDistance) {
                        bestX = x3
                        bestY = y3
                        bestDistance = dist
                    }
                }
            }
            
            // Above other monitor: y is fixed, x can vary along the edge
            var y4 = otherTop - monitor.monitorHeight
            if (y4 >= 0) {
                // Find valid x range for adjacency
                var xMin4 = Math.max(0, otherLeft - monitor.monitorWidth + 1)
                var xMax4 = otherRight - 1
                if (xMin4 <= xMax4) {
                    var x4 = Math.max(xMin4, Math.min(xMax4, targetX))
                    var dist = Math.abs(x4 - targetX) + Math.abs(y4 - targetY)
                    if (dist < bestDistance) {
                        bestX = x4
                        bestY = y4
                        bestDistance = dist
                    }
                }
            }
        }
        
        return { x: bestX, y: bestY }
    }
    
    // Normalize positions so that the leftmost monitor is at x=0 and topmost at y=0
    function normalizePositions(positions) {
        if (!monitorsModel || monitorsModel.count === 0) return positions
        
        // Find minimum X and Y across all monitors
        var minX = Infinity
        var minY = Infinity
        
        for (var i = 0; i < monitorsModel.count; i++) {
            var monitor = monitorsModel.get(i)
            var pos = positions[monitor.name]
            if (!pos) {
                // Use effective position if not in positions object
                pos = getEffectivePosition(monitor)
            }
            if (pos.x < minX) minX = pos.x
            if (pos.y < minY) minY = pos.y
        }
        
        // If minX or minY is not 0, shift all positions
        if (minX !== 0 || minY !== 0) {
            var normalized = {}
            for (var i = 0; i < monitorsModel.count; i++) {
                var monitor = monitorsModel.get(i)
                var pos = positions[monitor.name]
                if (!pos) {
                    pos = getEffectivePosition(monitor)
                }
                normalized[monitor.name] = {
                    x: pos.x - minX,
                    y: pos.y - minY
                }
            }
            return normalized
        }
        
        return positions
    }
    
    // Reset monitors to side-by-side layout starting from zero
    function resetLayout() {
        if (!monitorsModel || monitorsModel.count === 0) return
        
        var positions = {}
        var currentX = 0
        
        for (var i = 0; i < monitorsModel.count; i++) {
            var monitor = monitorsModel.get(i)
            positions[monitor.name] = { x: currentX, y: 0 }
            currentX += monitor.monitorWidth
        }
        
        positionsChanged(positions)
    }
    
    color: Qt.darker(cSurface, 1.3)
    radius: 8
    border.color: cBorder
    border.width: 1
    
    // Calculate bounds of all monitors using effective positions
    // minX and minY are always 0 since we don't allow negative values
    property real minX: 0
    property real minY: 0
    
    property real maxX: {
        var max = 1920
        if (!monitorsModel) return 1920
        for (var i = 0; i < monitorsModel.count; i++) {
            var m = monitorsModel.get(i)
            var pos = getEffectivePosition(m)
            var right = pos.x + m.monitorWidth
            if (right > max) max = right
        }
        return max
    }
    
    property real maxY: {
        var max = 1080
        if (!monitorsModel) return 1080
        for (var i = 0; i < monitorsModel.count; i++) {
            var m = monitorsModel.get(i)
            var pos = getEffectivePosition(m)
            var bottom = pos.y + m.monitorHeight
            if (bottom > max) max = bottom
        }
        return max
    }
    
    property real totalWidth: maxX - minX
    property real totalHeight: maxY - minY
    
    // Calculate scale to fit all monitors with padding
    property real padding: 24
    property real availableWidth: width - padding * 2
    property real availableHeight: height - padding * 2
    property real scaleX: totalWidth > 0 ? availableWidth / totalWidth : 1
    property real scaleY: totalHeight > 0 ? availableHeight / totalHeight : 1
    property real displayScale: Math.min(scaleX, scaleY, 0.15) // Cap at 0.15 to not make tiny monitors too big
    
    // Offset to center the layout
    property real offsetX: padding + (availableWidth - totalWidth * displayScale) / 2
    property real offsetY: padding + (availableHeight - totalHeight * displayScale) / 2
    
    // Container for monitors
    Item {
        id: monitorContainer
        anchors.fill: parent
        
        Repeater {
            model: monitorsModel
            
            delegate: Rectangle {
                id: monitorRect
                
                required property string name
                required property int positionX
                required property int positionY
                required property int monitorWidth
                required property int monitorHeight
                required property real monitorScale
                required property int index
                
                // Track original position when drag starts
                property real originalMonitorX: 0
                property real originalMonitorY: 0
                
                // Flag to prevent recursive position updates during snapping
                property bool isSnapping: false
                
                // Get effective position (pending if exists, otherwise current)
                readonly property int effectivePosX: 
                    (root.pendingChanges[name] && root.pendingChanges[name].positionX !== undefined) ? root.pendingChanges[name].positionX : positionX
                readonly property int effectivePosY: 
                    (root.pendingChanges[name] && root.pendingChanges[name].positionY !== undefined) ? root.pendingChanges[name].positionY : positionY
                
                // Check if this monitor has pending position changes
                readonly property bool hasPendingPosition: root.pendingChanges[name] && 
                    (root.pendingChanges[name].positionX !== undefined || root.pendingChanges[name].positionY !== undefined)
                
                // Convert monitor position to preview position
                // During drag, drag.target controls position; otherwise use base position
                property real baseX: root.offsetX + (effectivePosX - root.minX) * root.displayScale
                property real baseY: root.offsetY + (effectivePosY - root.minY) * root.displayScale
                
                // Position - drag system will override during drag
                x: baseX
                y: baseY
                
                // Function to apply snapping during drag
                function applySnapping() {
                    if (!monitorArea.drag.active || isSnapping) return
                    
                    isSnapping = true
                    
                    // Calculate the current dragged position in preview coordinates
                    var draggedPreviewX = x
                    var draggedPreviewY = y
                    
                    // Convert to monitor coordinates
                    var monitorPos = previewToMonitor(draggedPreviewX, draggedPreviewY)
                    
                    // Ensure non-negative values
                    var clampedX = Math.max(0, monitorPos.x)
                    var clampedY = Math.max(0, monitorPos.y)
                    
                    // Create monitor object for adjacency checking
                    var currentMonitor = {
                        name: name,
                        monitorWidth: monitorWidth,
                        monitorHeight: monitorHeight
                    }
                    
                    // Check if this position is adjacent to at least one other monitor
                    var testPos = { x: clampedX, y: clampedY }
                    var isAdjacent = false
                    for (var i = 0; i < root.monitorsModel.count; i++) {
                        var other = root.monitorsModel.get(i)
                        if (other.name === name) continue
                        var otherPos = root.getEffectivePosition(other)
                        if (root.areMonitorsAdjacent(currentMonitor, testPos, other, otherPos)) {
                            isAdjacent = true
                            break
                        }
                    }
                    
                    // If not adjacent, find the nearest adjacent position
                    var finalPos = isAdjacent ? testPos : root.findNearestAdjacentPosition(currentMonitor, clampedX, clampedY)
                    
                    // Snap to grid of 10 pixels
                    var snappedMonitorX = Math.round(finalPos.x / 10) * 10
                    var snappedMonitorY = Math.round(finalPos.y / 10) * 10
                    
                    // Ensure still non-negative after snapping
                    snappedMonitorX = Math.max(0, snappedMonitorX)
                    snappedMonitorY = Math.max(0, snappedMonitorY)
                    
                    // Convert back to preview coordinates and update position
                    var snappedPreviewX = root.offsetX + (snappedMonitorX - root.minX) * root.displayScale
                    var snappedPreviewY = root.offsetY + (snappedMonitorY - root.minY) * root.displayScale
                    
                    // Update position directly (this will be smoothed by the drag system)
                    x = snappedPreviewX
                    y = snappedPreviewY
                    
                    isSnapping = false
                }
                
                // Apply snapping whenever position changes during drag
                // Use a single handler to avoid duplicate calls when both x and y change
                onXChanged: {
                    if (monitorArea.drag.active && !isSnapping) {
                        applySnapping()
                    }
                }
                
                onYChanged: {
                    if (monitorArea.drag.active && !isSnapping) {
                        applySnapping()
                    }
                }
                width: monitorWidth * root.displayScale
                height: monitorHeight * root.displayScale
                
                // Helper function to convert preview coordinates to monitor coordinates
                function previewToMonitor(previewX, previewY) {
                    return {
                        x: ((previewX - root.offsetX) / root.displayScale) + root.minX,
                        y: ((previewY - root.offsetY) / root.displayScale) + root.minY
                    }
                }
                
                color: monitorArea.drag.active ? Qt.lighter(root.cSurfaceContainer, 1.2) : 
                       (monitorArea.containsMouse ? Qt.lighter(root.cSurfaceContainer, 1.1) : root.cSurfaceContainer)
                border.color: hasPendingPosition ? root.cPrimary : (root.selectedMonitor === name ? root.cPrimary : root.cBorder)
                border.width: (root.selectedMonitor === name || hasPendingPosition) ? 2 : 1
                radius: 4
                
                Behavior on color {
                    enabled: !monitorArea.drag.active
                    ColorAnimation { duration: 100 }
                }
                
                Behavior on border.color {
                    enabled: !monitorArea.drag.active
                    ColorAnimation { duration: 100 }
                }
                
                // Disable position animations during drag for smooth movement
                Behavior on x {
                    enabled: !monitorArea.drag.active
                    NumberAnimation { duration: 0 }
                }
                
                Behavior on y {
                    enabled: !monitorArea.drag.active
                    NumberAnimation { duration: 0 }
                }
                
                // Get all monitors at this position (for mirrored monitors)
                readonly property var monitorsAtThisPosition: root.getMonitorsAtPosition(effectivePosX, effectivePosY)
                readonly property bool isMirrored: monitorsAtThisPosition.length > 1
                
                // Monitor labels - show all monitors at this position when mirrored
                Column {
                    anchors.centerIn: parent
                    spacing: 2
                    visible: parent.width > 60 && parent.height > 40
                    
                    Repeater {
                        model: isMirrored ? monitorsAtThisPosition.length : 1
                        
                        delegate: Column {
                            spacing: 1
                            
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                text: isMirrored ? monitorsAtThisPosition[index].name : name
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: Math.max(9, Math.min(12, parent.parent.parent.width / (isMirrored ? 10 : 8)))
                                font.weight: Font.Medium
                                color: root.cText
                                opacity: 0.9
                            }
                            
                            // Resolution label (only show for first monitor when mirrored, or always when not mirrored)
                            Text {
                                anchors.horizontalCenter: parent.horizontalCenter
                                visible: (isMirrored && index === 0) || !isMirrored
                                text: {
                                    if (isMirrored) {
                                        var m = monitorsAtThisPosition[index]
                                        return m.monitorWidth + "x" + m.monitorHeight
                                    } else {
                                        return monitorWidth + "x" + monitorHeight
                                    }
                                }
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: Math.max(7, Math.min(9, parent.parent.parent.width / 14))
                                color: root.cSubText
                            }
                        }
                    }
                }
                
                MouseArea {
                    id: monitorArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: drag.active ? Qt.ClosedHandCursor : Qt.OpenHandCursor
                    
                    // Enable dragging with Qt Quick's built-in drag system
                    drag.target: parent
                    drag.axis: Drag.XAndYAxis
                    // Allow free dragging - no constraints as monitors can be positioned anywhere
                    
                    onPressed: function(mouse) {
                        root.selectedMonitor = name
                        // Store original position when drag starts
                        originalMonitorX = effectivePosX
                        originalMonitorY = effectivePosY
                        root.isDragging = true
                    }
                    
                    onReleased: function(mouse) {
                        if (!drag.active) return
                        
                        // Calculate the dragged position in preview coordinates
                        var draggedPreviewX = monitorRect.x
                        var draggedPreviewY = monitorRect.y
                        
                        // Convert to monitor coordinates
                        var monitorPos = previewToMonitor(draggedPreviewX, draggedPreviewY)
                        
                        // Ensure non-negative values
                        var clampedX = Math.max(0, monitorPos.x)
                        var clampedY = Math.max(0, monitorPos.y)
                        
                        // Create monitor object for adjacency checking
                        var currentMonitor = {
                            name: name,
                            monitorWidth: monitorWidth,
                            monitorHeight: monitorHeight
                        }
                        
                        // Check if this position is adjacent to at least one other monitor
                        var testPos = { x: clampedX, y: clampedY }
                        var isAdjacent = false
                        for (var i = 0; i < root.monitorsModel.count; i++) {
                            var other = root.monitorsModel.get(i)
                            if (other.name === name) continue
                            var otherPos = root.getEffectivePosition(other)
                            if (root.areMonitorsAdjacent(currentMonitor, testPos, other, otherPos)) {
                                isAdjacent = true
                                break
                            }
                        }
                        
                        // If not adjacent, find the nearest adjacent position
                        var finalPos = isAdjacent ? testPos : root.findNearestAdjacentPosition(currentMonitor, clampedX, clampedY)
                        
                        // Snap to grid of 10 pixels
                        var snappedX = Math.round(finalPos.x / 10) * 10
                        var snappedY = Math.round(finalPos.y / 10) * 10
                        
                        // Ensure still non-negative after snapping
                        snappedX = Math.max(0, snappedX)
                        snappedY = Math.max(0, snappedY)
                        
                        root.isDragging = false
                        
                        // Check if position actually changed from the original
                        if (snappedX !== originalMonitorX || snappedY !== originalMonitorY) {
                            // Build positions object with all monitors
                            var positions = {}
                            
                            // Add the new position for the dragged monitor
                            positions[name] = { x: snappedX, y: snappedY }
                            
                            // Add current positions for all other monitors
                            for (var i = 0; i < root.monitorsModel.count; i++) {
                                var other = root.monitorsModel.get(i)
                                if (other.name !== name) {
                                    var otherPos = root.getEffectivePosition(other)
                                    positions[other.name] = { x: otherPos.x, y: otherPos.y }
                                }
                            }
                            
                            // Normalize positions so leftmost/topmost is at (0, 0)
                            var normalizedPositions = root.normalizePositions(positions)
                            
                            // Emit all normalized positions
                            root.positionsChanged(normalizedPositions)
                        }
                    }
                }
            }
        }
    }
    
    // Bottom controls
    Row {
        anchors.bottom: parent.bottom
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottomMargin: 6
        spacing: 12
        height: 20
        
        // Help text
        Text {
            anchors.verticalCenter: parent.verticalCenter
            text: isDragging ? "Release to set position" : "Drag monitors to reposition"
            font.family: Commons.Theme.fontUI
            font.pixelSize: 10
            color: cSubText
            opacity: 0.7
        }
        
        // Reset button
        Widgets.IconButton {
            anchors.verticalCenter: parent.verticalCenter
            icon: "󰑐"
            iconSize: 14
            iconColor: cSubText
            hoverIconColor: cText
            baseColor: "transparent"
            hoverColor: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
            pressedColor: Qt.rgba(cText.r, cText.g, cText.b, 0.12)
            implicitWidth: 20
            implicitHeight: 20
            visible: monitorsModel && monitorsModel.count > 0
            
            onClicked: {
                root.resetLayout()
            }
        }
    }
}
