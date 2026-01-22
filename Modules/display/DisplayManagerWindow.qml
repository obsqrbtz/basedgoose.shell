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
    
    ipcTarget: "display"
    initialScale: 0.94
    transformOriginX: 0.5
    transformOriginY: 0.5
    closeOnClickOutside: false
    
    readonly property color cSurface: Commons.Theme.background
    readonly property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: Quickshell.screens[0] ? (Quickshell.screens[0].height - implicitHeight) / 2 : 100
        left: Quickshell.screens[0] ? (Quickshell.screens[0].width - implicitWidth) / 2 : 100
    }
    
    implicitWidth: 600
    implicitHeight: 720
    
    // Service instance
    Services.DisplayManagerService {
        id: displayService
    }
    
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
            spacing: 16
            
            // Header
            DisplayHeader {
                Layout.fillWidth: true
                monitorCount: displayService.monitorsList.count
                isLoading: displayService.isLoading
                cPrimary: popupWindow.cPrimary
                cText: popupWindow.cText
                cSubText: popupWindow.cSubText
                onRefreshClicked: {
                    displayService.refreshMonitors()
                }
            }
            
            // Monitor Layout Preview
            MonitorLayoutPreview {
                Layout.fillWidth: true
                Layout.preferredHeight: 160
                monitorsModel: displayService.monitorsList
                pendingChanges: displayService.pendingChanges
                cSurface: popupWindow.cSurface
                cSurfaceContainer: popupWindow.cSurfaceContainer
                cPrimary: popupWindow.cPrimary
                cText: popupWindow.cText
                cSubText: popupWindow.cSubText
                cBorder: popupWindow.cBorder
                visible: displayService.monitorsList.count > 0
                
                onPositionsChanged: function(positions) {
                    displayService.stageAllPositions(positions)
                }
            }
            
            // Monitors list container
            Rectangle {
                id: monitorsContainer
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: cSurfaceContainer
                clip: true
                
                Flickable {
                    id: monitorsFlickable
                    anchors.fill: parent
                    anchors.margins: 8
                    contentWidth: width
                    contentHeight: monitorColumn.height
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true
                    
                    Column {
                        id: monitorColumn
                        width: monitorsFlickable.width
                        spacing: 12
                        
                        Repeater {
                            model: displayService.monitorsList
                            
                            delegate: MonitorCard {
                                width: monitorsContainer.width - 16
                                
                                // Pass theme colors
                                cSurface: popupWindow.cSurface
                                cSurfaceContainer: popupWindow.cSurfaceContainer
                                cPrimary: popupWindow.cPrimary
                                cText: popupWindow.cText
                                cSubText: popupWindow.cSubText
                                cBorder: popupWindow.cBorder
                                cHover: popupWindow.cHover
                                
                                // Pass pending changes for this monitor
                                pendingChanges: displayService.pendingChanges[name] || null
                                
                                // Handle signals
                                onToggleDisplay: function(monitorName, enabled) {
                                    displayService.toggleDisplay(monitorName, enabled)
                                }
                                
                                onModeDropdownRequested: function(parentItem, modes, currentMode, monitorName) {
                                    showModePopup(parentItem, modes, currentMode, monitorName)
                                }
                                
                                onScaleDropdownRequested: function(parentItem, monitorName, currentScale) {
                                    showScalePopup(parentItem, monitorName, currentScale)
                                }
                                
                                onRotateDropdownRequested: function(parentItem, monitorName, currentTransform) {
                                    showRotatePopup(parentItem, monitorName, currentTransform)
                                }
                                
                                onMirrorDropdownRequested: function(parentItem, monitorName, currentMirror) {
                                    showMirrorPopup(parentItem, monitorName, currentMirror)
                                }
                                
                                onStopMirroringRequested: function(monitorName) {
                                    displayService.stageSetting(monitorName, "mirror", "")
                                }
                            }
                        }
                        
                        Widgets.EmptyState {
                            width: monitorsFlickable.width
                            height: 200
                            visible: displayService.monitorsList.count === 0 && !displayService.isLoading
                            icon: "󰍹"
                            iconSize: 32
                            iconOpacity: 0.2
                            title: "No displays found"
                            subtitle: "Click refresh to reload"
                            textOpacity: 1.0
                        }
                    }
                }
            }
            
            // Config file path editor
            ConfigPathEditor {
                Layout.fillWidth: true
                configPath: Services.ConfigService.hyprlandMonitorsConfigPath
                cSurface: popupWindow.cSurface
                cSurfaceContainer: popupWindow.cSurfaceContainer
                cPrimary: popupWindow.cPrimary
                cText: popupWindow.cText
                cSubText: popupWindow.cSubText
                cBorder: popupWindow.cBorder
                helpText: "Settings are saved to this file when applied. Include this file in your hyprland.conf using: source = " + Services.ConfigService.hyprlandMonitorsConfigPath.replace(/^~/, "~")
                onPathChanged: function(newPath) {
                    Services.ConfigService.setHyprlandMonitorsConfigPath(newPath)
                }
            }
            
            // Apply/Discard buttons
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                visible: displayService.hasUnsavedChanges
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 10
                    color: discardArea.containsMouse ? Qt.rgba(cText.r, cText.g, cText.b, 0.1) : cSurfaceContainer
                    border.color: cBorder
                    border.width: 1
                    
                    Text {
                        anchors.centerIn: parent
                        text: "Discard"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 13
                        font.weight: Font.Medium
                        color: cText
                    }
                    
                    MouseArea {
                        id: discardArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            displayService.discardChanges()
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 44
                    radius: 10
                    color: applyArea.containsMouse ? Qt.lighter(cPrimary, 1.1) : cPrimary
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: "󰄬"
                            font.family: Commons.Theme.fontIcon
                            font.pixelSize: 16
                            color: Commons.Theme.background
                        }
                        
                        Text {
                            text: "Apply Changes"
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 13
                            font.weight: Font.Medium
                            color: Commons.Theme.background
                        }
                    }
                    
                    MouseArea {
                        id: applyArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            // Apply changes immediately
                            displayService.applyAllPendingChanges()
                        }
                    }
                }
            }
        }
        
        // Confirmation dialog - shown after applying changes
        ConfirmationDialog {
            id: confirmationDialog
            visible: false
            anchors.centerIn: backgroundRect
            z: 2000
            isPreConfirmation: false
            
            // Determine if this is primarily a position change (only positions, no modes/scales/transforms)
            isPositionChange: confirmationDialog._hasOnlyPositionChanges
            
            // Find the first applied mode change (for display in dialog)
            pendingModeData: confirmationDialog._appliedModeData
            
            // Collect applied settings (shows first monitor's settings for simplicity)
            pendingSettings: confirmationDialog._appliedSettings
            
            // Properties to store what was applied (set when dialog is shown)
            property bool _hasOnlyPositionChanges: false
            property var _appliedModeData: null
            property var _appliedSettings: null
            
            // Countdown timer
            Timer {
                id: countdownTimer
                interval: 1000
                repeat: true
                running: confirmationDialog.visible
                onTriggered: {
                    if (confirmationDialog.countdownSeconds > 0) {
                        confirmationDialog.countdownSeconds--
                    } else {
                        // Timeout - revert changes
                        countdownTimer.stop()
                        confirmationDialog.visible = false
                        displayService.revertToPreviousState()
                    }
                }
            }
            
            onConfirmClicked: {
                countdownTimer.stop()
                confirmationDialog.visible = false
                // Keep the changes - do nothing
            }
            
            onRevertClicked: {
                countdownTimer.stop()
                confirmationDialog.visible = false
                displayService.revertToPreviousState()
            }
        }
        
        // Connection to show confirmation dialog after changes are applied
        Connections {
            target: displayService
            function onChangesApplied(prevState) {
                // Extract information from previous state to determine what changed
                var hasPositionChange = false
                var hasNonPositionChange = false
                var appliedModeData = null
                var appliedSettings = {}
                
                // Compare previous state with current monitor state to determine what changed
                for (var monitorName in prevState) {
                    var prev = prevState[monitorName]
                    
                    // Find current monitor state
                    for (var i = 0; i < displayService.monitorsList.count; i++) {
                        var monitor = displayService.monitorsList.get(i)
                        if (monitor.name === monitorName) {
                            // Check what changed
                            if (prev.positionX !== monitor.positionX || prev.positionY !== monitor.positionY) {
                                hasPositionChange = true
                            }
                            
                            if (prev.mode !== monitor.currentMode) {
                                // Parse mode to get modeData-like object
                                var match = monitor.currentMode.match(/(\d+)x(\d+)@([\d.]+)Hz/)
                                if (match && !appliedModeData) {
                                    appliedModeData = {
                                        formatted: monitor.currentMode,
                                        width: parseInt(match[1]),
                                        height: parseInt(match[2]),
                                        refresh: parseFloat(match[3])
                                    }
                                }
                                hasNonPositionChange = true
                            }
                            
                            if (prev.scale !== monitor.monitorScale) {
                                appliedSettings.scale = monitor.monitorScale
                                hasNonPositionChange = true
                            }
                            if (prev.transform !== monitor.monitorTransform) {
                                appliedSettings.transform = monitor.monitorTransform
                                hasNonPositionChange = true
                            }
                            if (prev.mirror !== monitor.mirrorTarget) {
                                if (monitor.mirrorTarget && monitor.mirrorTarget !== "") {
                                    appliedSettings.mirror = monitor.mirrorTarget
                                    hasNonPositionChange = true
                                }
                            }
                            break
                        }
                    }
                }
                
                // Set dialog properties
                confirmationDialog._hasOnlyPositionChanges = hasPositionChange && !hasNonPositionChange
                confirmationDialog._appliedModeData = appliedModeData
                confirmationDialog._appliedSettings = Object.keys(appliedSettings).length > 0 ? appliedSettings : null
                
                // Reset and start countdown
                confirmationDialog.countdownSeconds = 10
                
                // Show dialog
                confirmationDialog.visible = true
            }
        }
        
        // Click-catcher overlay for closing dropdowns
        MouseArea {
            id: dropdownOverlay
            anchors.fill: parent
            z: 999
            visible: (modePopup.visible || scalePopup.visible || rotatePopup.visible || mirrorPopup.visible) && !confirmationDialog.visible
            hoverEnabled: true
            onPressed: function(mouse) {
                mouse.accepted = true
                backgroundRect.closeAllDropdowns()
            }
        }
        
        function closeAllDropdowns() {
            modePopup.visible = false
            scalePopup.visible = false
            rotatePopup.visible = false
            mirrorPopup.visible = false
        }
        
        // Mode selection popup
        Rectangle {
            id: modePopup
            visible: false
            width: 300
            height: 200
            radius: 10
            color: cSurface
            border.color: cBorder
            border.width: 1
            z: 1000
            clip: true
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 1.0
                shadowVerticalOffset: 4
            }
            
            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: modeList.width
                contentHeight: modeList.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                
                ListView {
                    id: modeList
                    width: modePopup.width - 16
                    height: modePopup.height - 16
                    model: modePopupModel
                    
                    delegate: Rectangle {
                        required property string modeText
                        required property var modeData
                        required property string monitorName
                        required property int index
                        
                        width: modeList.width
                        height: 40
                        color: modeItemArea.containsMouse ? cHover : "transparent"
                        radius: 6
                        
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: modeText
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 12
                            color: cText
                        }
                        
                        MouseArea {
                            id: modeItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            z: 1
                            onClicked: function(mouse) {
                                mouse.accepted = true
                                displayService.stageMode(monitorName, modeData)
                                Qt.callLater(function() {
                                    modePopup.visible = false
                                })
                            }
                        }
                    }
                }
            }
            
            ListModel {
                id: modePopupModel
            }
        }
        
        // Scale selection popup
        Rectangle {
            id: scalePopup
            visible: false
            width: 200
            height: 200
            radius: 10
            color: cSurface
            border.color: cBorder
            border.width: 1
            z: 1000
            clip: true
            property string parentMonitor: ""
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 1.0
                shadowVerticalOffset: 4
            }
            
            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: scaleList.width
                contentHeight: scaleList.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                
                Column {
                    id: scaleList
                    width: scalePopup.width - 16
                    spacing: 4
                    
                    Repeater {
                        model: [0.5, 0.75, 1.0, 1.25, 1.5, 1.75, 2.0, 2.5, 3.0]
                        
                        delegate: Rectangle {
                            width: scaleList.width
                            height: 36
                            color: scaleItemArea.containsMouse ? cHover : "transparent"
                            radius: 6
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.toFixed(2) + "x"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cText
                            }
                            
                        MouseArea {
                            id: scaleItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                displayService.stageSetting(scalePopup.parentMonitor, "scale", modelData)
                                scalePopup.visible = false
                            }
                        }
                        }
                    }
                }
            }
        }
        
        // Rotation selection popup
        Rectangle {
            id: rotatePopup
            visible: false
            width: 200
            height: 200
            radius: 10
            color: cSurface
            border.color: cBorder
            border.width: 1
            z: 1000
            clip: true
            property string parentMonitor: ""
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 1.0
                shadowVerticalOffset: 4
            }
            
            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: rotateList.width
                contentHeight: rotateList.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                
                Column {
                    id: rotateList
                    width: rotatePopup.width - 16
                    spacing: 4
                    
                    Repeater {
                        model: [
                            { value: 0, label: "Normal" },
                            { value: 1, label: "90°" },
                            { value: 2, label: "180°" },
                            { value: 3, label: "270°" },
                            { value: 4, label: "Flipped" },
                            { value: 5, label: "Flipped 90°" },
                            { value: 6, label: "Flipped 180°" },
                            { value: 7, label: "Flipped 270°" }
                        ]
                        
                        delegate: Rectangle {
                            width: rotateList.width
                            height: 36
                            color: rotateItemArea.containsMouse ? cHover : "transparent"
                            radius: 6
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: modelData.label
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cText
                            }
                            
                        MouseArea {
                            id: rotateItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                displayService.stageSetting(rotatePopup.parentMonitor, "transform", modelData.value)
                                rotatePopup.visible = false
                            }
                        }
                        }
                    }
                }
            }
        }
        
        // Mirror selection popup
        Rectangle {
            id: mirrorPopup
            visible: false
            width: 250
            height: 200
            radius: 10
            color: cSurface
            border.color: cBorder
            border.width: 1
            z: 1000
            clip: true
            property string parentMonitor: ""
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 1.0
                shadowVerticalOffset: 4
            }
            
            Flickable {
                anchors.fill: parent
                anchors.margins: 8
                contentWidth: mirrorList.width
                contentHeight: mirrorList.height
                boundsBehavior: Flickable.StopAtBounds
                clip: true
                
                Column {
                    id: mirrorList
                    width: mirrorPopup.width - 16
                    spacing: 4
                    
                    // None option
                    Rectangle {
                        width: mirrorList.width
                        height: 36
                        color: mirrorNoneArea.containsMouse ? cHover : "transparent"
                        radius: 6
                        
                        Text {
                            anchors.left: parent.left
                            anchors.leftMargin: 12
                            anchors.verticalCenter: parent.verticalCenter
                            text: "None"
                            font.family: Commons.Theme.fontUI
                            font.pixelSize: 12
                            color: cText
                        }
                        
                        MouseArea {
                            id: mirrorNoneArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                displayService.stageSetting(mirrorPopup.parentMonitor, "mirror", "")
                                mirrorPopup.visible = false
                            }
                        }
                    }
                    
                    // Other monitors
                    Repeater {
                        model: displayService.monitorsList
                        
                        delegate: Rectangle {
                            required property string name
                            required property int index
                            
                            width: mirrorList.width
                            height: 36
                            visible: name !== mirrorPopup.parentMonitor
                            color: mirrorItemArea.containsMouse ? cHover : "transparent"
                            radius: 6
                            
                            Text {
                                anchors.left: parent.left
                                anchors.leftMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                text: name
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cText
                            }
                            
                        MouseArea {
                            id: mirrorItemArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                displayService.stageSetting(mirrorPopup.parentMonitor, "mirror", name)
                                mirrorPopup.visible = false
                            }
                        }
                        }
                    }
                }
            }
        }
        
        Connections {
            target: popupWindow
            function onShouldShowChanged() {
                if (popupWindow.shouldShow) {
                    displayService.discardChanges()
                    displayService.refreshMonitors()
                } else {
                    // Discard any pending changes when closing
                    displayService.discardChanges()
                }
            }
        }
    }
    
    function showModePopup(parentItem, modes, currentMode, monitorName) {
        backgroundRect.closeAllDropdowns()
        modePopupModel.clear()
        
        for (var i = 0; i < modes.length; i++) {
            modePopupModel.append({
                modeText: modes[i].formatted,
                modeData: modes[i],
                monitorName: monitorName
            })
        }
        
        var maxHeight = 400
        var itemHeight = 40
        var padding = 16
        var calculatedHeight = Math.min(maxHeight, modePopupModel.count * itemHeight + padding)
        
        var buttonPos = parentItem.mapToItem(backgroundRect, 0, 0)
        var buttonBottom = buttonPos.y + parentItem.height
        var availableSpaceBelow = backgroundRect.height - buttonBottom - 8
        var availableSpaceAbove = buttonPos.y - 8
        
        var showAbove = availableSpaceBelow < calculatedHeight && availableSpaceAbove > availableSpaceBelow
        var maxAvailableSpace = showAbove ? availableSpaceAbove : availableSpaceBelow
        var finalHeight = Math.min(calculatedHeight, maxAvailableSpace)
        
        modePopup.height = finalHeight
        modePopup.x = Math.max(8, Math.min(buttonPos.x, backgroundRect.width - modePopup.width - 8))
        
        if (showAbove) {
            modePopup.y = Math.max(8, buttonPos.y - finalHeight - 4)
        } else {
            modePopup.y = Math.min(buttonBottom + 4, backgroundRect.height - finalHeight - 8)
        }
        
        modePopup.visible = true
    }
    
    function showScalePopup(parentItem, monitorName, currentScale) {
        backgroundRect.closeAllDropdowns()
        scalePopup.parentMonitor = monitorName
        
        var buttonPos = parentItem.mapToItem(backgroundRect, 0, 0)
        var buttonBottom = buttonPos.y + parentItem.height
        scalePopup.x = Math.max(8, Math.min(buttonPos.x, backgroundRect.width - scalePopup.width - 8))
        scalePopup.y = Math.min(buttonBottom + 4, backgroundRect.height - scalePopup.height - 8)
        
        scalePopup.visible = true
    }
    
    function showRotatePopup(parentItem, monitorName, currentTransform) {
        backgroundRect.closeAllDropdowns()
        rotatePopup.parentMonitor = monitorName
        
        var buttonPos = parentItem.mapToItem(backgroundRect, 0, 0)
        var buttonBottom = buttonPos.y + parentItem.height
        rotatePopup.x = Math.max(8, Math.min(buttonPos.x, backgroundRect.width - rotatePopup.width - 8))
        rotatePopup.y = Math.min(buttonBottom + 4, backgroundRect.height - rotatePopup.height - 8)
        
        rotatePopup.visible = true
    }
    
    function showMirrorPopup(parentItem, monitorName, currentMirror) {
        backgroundRect.closeAllDropdowns()
        mirrorPopup.parentMonitor = monitorName
        
        var buttonPos = parentItem.mapToItem(backgroundRect, 0, 0)
        var buttonBottom = buttonPos.y + parentItem.height
        mirrorPopup.x = Math.max(8, Math.min(buttonPos.x, backgroundRect.width - mirrorPopup.width - 8))
        mirrorPopup.y = Math.min(buttonBottom + 4, backgroundRect.height - mirrorPopup.height - 8)
        
        mirrorPopup.visible = true
    }
    
    function getTransformLabel(transform) {
        var labels = {
            0: "Normal",
            1: "90°",
            2: "180°",
            3: "270°",
            4: "Flipped",
            5: "Flipped 90°",
            6: "Flipped 180°",
            7: "Flipped 270°"
        }
        return labels[transform] || "Unknown"
    }
}
