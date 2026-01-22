import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Rectangle {
    id: root
    
    // Required properties from delegate
    required property string name
    required property bool enabled
    required property string currentMode
    required property string availableModesJson
    required property int index
    required property real monitorScale
    required property int monitorTransform
    required property string mirrorTarget
    required property int positionX
    required property int positionY
    required property int monitorWidth
    required property int monitorHeight
    
    // Pending changes for this monitor (null if no changes)
    property var pendingChanges: null
    
    // Theme colors (passed from parent)
    property color cSurface: Commons.Theme.background
    property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    property color cPrimary: Commons.Theme.secondary
    property color cText: Commons.Theme.foreground
    property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    // Effective values (pending if exists, otherwise current)
    readonly property string effectiveMode: pendingChanges && pendingChanges.mode ? pendingChanges.mode.formatted : currentMode
    readonly property real effectiveScale: pendingChanges && pendingChanges.scale !== undefined ? pendingChanges.scale : monitorScale
    readonly property int effectiveTransform: pendingChanges && pendingChanges.transform !== undefined ? pendingChanges.transform : monitorTransform
    readonly property string effectiveMirror: pendingChanges && pendingChanges.mirror !== undefined ? pendingChanges.mirror : mirrorTarget
    readonly property int effectivePositionX: pendingChanges && pendingChanges.positionX !== undefined ? pendingChanges.positionX : positionX
    readonly property int effectivePositionY: pendingChanges && pendingChanges.positionY !== undefined ? pendingChanges.positionY : positionY
    
    // Check if there are any pending changes for this monitor
    readonly property bool hasPendingChanges: pendingChanges !== null && Object.keys(pendingChanges).length > 0
    
    // Signals
    signal toggleDisplay(string monitorName, bool enabled)
    signal modeDropdownRequested(Item parentItem, var modes, string currentMode, string monitorName)
    signal scaleDropdownRequested(Item parentItem, string monitorName, real currentScale)
    signal rotateDropdownRequested(Item parentItem, string monitorName, int currentTransform)
    signal mirrorDropdownRequested(Item parentItem, string monitorName, string currentMirror)
    signal stopMirroringRequested(string monitorName)
    
    property var availableModes: {
        try {
            return JSON.parse(availableModesJson)
        } catch (e) {
            return []
        }
    }
    
    width: parent ? parent.width : 300
    height: enabled ? (mirrorTarget && mirrorTarget !== "" ? 260 : 300) : 60
    radius: 10
    color: cSurface
    border.color: cBorder
    border.width: 1
    
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
    
    ColumnLayout {
        id: monitorContentLayout
        anchors.fill: parent
        anchors.margins: 12
        spacing: 8
        
        // Header row with monitor name and toggle
        RowLayout {
            Layout.fillWidth: true
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 2
                
                Text {
                    text: root.name
                    font.family: Commons.Theme.fontUI
                    font.pixelSize: 14
                    font.weight: Font.Medium
                    color: cText
                }
                
                Text {
                    text: "Position: " + root.effectivePositionX + "x" + root.effectivePositionY + (root.hasPendingChanges ? " *" : "")
                    font.family: Commons.Theme.fontUI
                    font.pixelSize: 10
                    color: root.hasPendingChanges ? cPrimary : cSubText
                    visible: root.enabled
                }
            }
            
            Widgets.ToggleSwitch {
                checked: root.enabled
                onToggled: {
                    root.toggleDisplay(root.name, checked)
                }
            }
        }
        
        // Separator
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: cBorder
            visible: root.enabled
        }
        
        // Settings section (only visible when enabled)
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            visible: root.enabled
            
            Text {
                text: "Resolution & Refresh Rate"
                font.family: Commons.Theme.fontUI
                font.pixelSize: 11
                color: cSubText
            }
            
            // Mode dropdown button
            Rectangle {
                id: modeDropdownButton
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                radius: 8
                color: modeDropdownArea.containsMouse ? cHover : cSurfaceContainer
                border.color: modeDropdownArea.containsMouse ? cPrimary : cBorder
                border.width: 1
                
                Behavior on color {
                    ColorAnimation { duration: 100 }
                }
                Behavior on border.color {
                    ColorAnimation { duration: 100 }
                }
                
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 8
                    spacing: 8
                    
                    Text {
                        Layout.fillWidth: true
                        text: root.effectiveMode || "Select mode..."
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 12
                        color: (pendingChanges && pendingChanges.mode) ? cPrimary : (root.effectiveMode ? cText : cSubText)
                        elide: Text.ElideRight
                    }
                    
                    Text {
                        text: modeDropdownArea.containsMouse ? "󰅀" : "󰅂"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 12
                        color: cSubText
                        
                        Behavior on text {
                            PropertyAnimation { duration: 100 }
                        }
                    }
                }
                
                MouseArea {
                    id: modeDropdownArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        root.modeDropdownRequested(modeDropdownButton, root.availableModes, root.effectiveMode, root.name)
                    }
                }
            }
            
            // Grid of settings
            GridLayout {
                Layout.fillWidth: true
                columns: 2
                columnSpacing: 12
                rowSpacing: 8
                
                // Scaling
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Scale"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 11
                        color: cSubText
                    }
                    
                    Rectangle {
                        id: scaleDropdownButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 8
                        color: scaleDropdownArea.containsMouse ? cHover : cSurfaceContainer
                        border.color: scaleDropdownArea.containsMouse ? cPrimary : cBorder
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: root.effectiveScale.toFixed(1) + "x"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: (pendingChanges && pendingChanges.scale !== undefined) ? cPrimary : cText
                            }
                            
                            Text {
                                text: scaleDropdownArea.containsMouse ? "󰅀" : "󰅂"
                                font.family: Commons.Theme.fontIcon
                                font.pixelSize: 12
                                color: cSubText
                            }
                        }
                        
                        MouseArea {
                            id: scaleDropdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.scaleDropdownRequested(scaleDropdownButton, root.name, root.effectiveScale)
                            }
                        }
                    }
                }
                
                // Rotation
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    
                    Text {
                        text: "Rotation"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 11
                        color: cSubText
                    }
                    
                    Rectangle {
                        id: rotateDropdownButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 8
                        color: rotateDropdownArea.containsMouse ? cHover : cSurfaceContainer
                        border.color: rotateDropdownArea.containsMouse ? cPrimary : cBorder
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: getTransformLabel(root.effectiveTransform)
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: (pendingChanges && pendingChanges.transform !== undefined) ? cPrimary : cText
                            }
                            
                            Text {
                                text: rotateDropdownArea.containsMouse ? "󰅀" : "󰅂"
                                font.family: Commons.Theme.fontIcon
                                font.pixelSize: 12
                                color: cSubText
                            }
                        }
                        
                        MouseArea {
                            id: rotateDropdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.rotateDropdownRequested(rotateDropdownButton, root.name, root.effectiveTransform)
                            }
                        }
                    }
                }
                
                // Mirroring (only when not currently mirrored)
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 4
                    visible: !root.effectiveMirror || root.effectiveMirror === ""
                    
                    Text {
                        text: "Mirror"
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 11
                        color: cSubText
                    }
                    
                    Rectangle {
                        id: mirrorDropdownButton
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 8
                        color: mirrorDropdownArea.containsMouse ? cHover : cSurfaceContainer
                        border.color: mirrorDropdownArea.containsMouse ? cPrimary : cBorder
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: root.effectiveMirror && root.effectiveMirror !== "" ? root.effectiveMirror : "None"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cText
                            }
                            
                            Text {
                                text: mirrorDropdownArea.containsMouse ? "󰅀" : "󰅂"
                                font.family: Commons.Theme.fontIcon
                                font.pixelSize: 12
                                color: cSubText
                            }
                        }
                        
                        MouseArea {
                            id: mirrorDropdownArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.mirrorDropdownRequested(mirrorDropdownButton, root.name, root.effectiveMirror)
                            }
                        }
                    }
                }
                
                // Mirror target display (when mirrored)
                ColumnLayout {
                    Layout.fillWidth: true
                    Layout.columnSpan: 2
                    spacing: 4
                    visible: root.effectiveMirror && root.effectiveMirror !== ""
                    
                    Text {
                        text: "Mirroring: " + root.effectiveMirror
                        font.family: Commons.Theme.fontUI
                        font.pixelSize: 11
                        color: (pendingChanges && pendingChanges.mirror !== undefined) ? cPrimary : cSubText
                    }
                    
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 40
                        radius: 8
                        color: mirrorRemoveArea.containsMouse ? cHover : cSurfaceContainer
                        border.color: mirrorRemoveArea.containsMouse ? cPrimary : cBorder
                        border.width: 1
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 8
                            spacing: 8
                            
                            Text {
                                Layout.fillWidth: true
                                text: "Stop Mirroring"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cPrimary
                            }
                            
                            Text {
                                text: "󰅀"
                                font.family: Commons.Theme.fontIcon
                                font.pixelSize: 12
                                color: cSubText
                            }
                        }
                        
                        MouseArea {
                            id: mirrorRemoveArea
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                root.stopMirroringRequested(root.name)
                            }
                        }
                    }
                }
            }
        }
    }
}
