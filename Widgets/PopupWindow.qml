import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import Quickshell.Io

PanelWindow {
    id: root
    
    property bool shouldShow: false
    property string ipcTarget: ""
    property bool closeOnClickOutside: true
    property real initialScale: 0.94
    property real transformOriginX: 0.5
    property real transformOriginY: 0.0
    property int closeDelay: 400
    
    property int openDuration: 180
    property int closeDuration: 120
    property real scaleOvershoot: 1.3
    
    default property alias content: contentContainer.children
    
    screen: Quickshell.screens[0]
    visible: shouldShow || container.opacity > 0
    color: "transparent"
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    IpcHandler {
        id: ipcHandler
        target: root.ipcTarget
        
        function toggle(): void {
            root.shouldShow = !root.shouldShow
        }
        
        function open(): void {
            root.shouldShow = true
        }
        
        function close(): void {
            root.shouldShow = false
        }
    }
    
    // TODO: check at home and fix is not working
    MouseArea {
        anchors.fill: parent
        z: 0
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        propagateComposedEvents: true
        onClicked: mouse => {
            if (root.closeOnClickOutside && root.shouldShow) {
                var containerPos = container.mapFromItem(root, mouse.x, mouse.y)
                var containerRect = Qt.rect(0, 0, container.width, container.height)
                if (!containerRect.contains(containerPos.x, containerPos.y)) {
                    root.shouldShow = false
                    mouse.accepted = true
                } else {
                    mouse.accepted = false
                }
            }
        }
    }
    
    FocusScope {
        id: container
        anchors.fill: parent
        scale: root.initialScale
        opacity: 0
        focus: true
        
        property int transformOriginValue: {
            var xPercent = root.transformOriginX
            var yPercent = root.transformOriginY
            if (xPercent === 0.0) {
                if (yPercent === 0.0) return Item.TopLeft
                else if (yPercent === 0.5) return Item.Left
                else return Item.BottomLeft
            } else if (xPercent === 0.5) {
                if (yPercent === 0.0) return Item.Top
                else if (yPercent === 0.5) return Item.Center
                else return Item.Bottom
            } else {
                if (yPercent === 0.0) return Item.TopRight
                else if (yPercent === 0.5) return Item.Right
                else return Item.BottomRight
            }
        }
        
        transformOrigin: transformOriginValue
        
        Keys.onEscapePressed: root.shouldShow = false
        
        property bool mouseHasEntered: false
        property bool mouseInside: hoverHandler.hovered
        
        Connections {
            target: root
            function onShouldShowChanged() {
                if (root.shouldShow) {
                    container.mouseHasEntered = false
                    closeTimer.stop()
                }
            }
        }
        
        Timer {
            id: closeTimer
            interval: root.closeDelay
            onTriggered: {
                if (!container.mouseInside && container.mouseHasEntered && root.shouldShow && root.closeOnClickOutside) {
                    root.shouldShow = false
                }
            }
        }
        
        HoverHandler {
            id: hoverHandler
            onHoveredChanged: {
                if (hovered) {
                    container.mouseHasEntered = true
                    closeTimer.stop()
                } else if (container.mouseHasEntered && root.shouldShow) {
                    if (root.closeOnClickOutside) {
                        closeTimer.restart()
                    }
                }
            }
        }
        
        states: State {
            name: "visible"
            when: root.shouldShow
            PropertyChanges { target: container; opacity: 1; scale: 1.0 }
        }
        
        transitions: [
            Transition {
                to: "visible"
                ParallelAnimation {
                    NumberAnimation { 
                        property: "opacity"
                        duration: root.openDuration
                        easing.type: Easing.OutQuad
                    }
                    NumberAnimation { 
                        property: "scale"
                        duration: root.openDuration * 1.4
                        easing.type: Easing.OutBack
                        easing.overshoot: root.scaleOvershoot
                    }
                }
            },
            Transition {
                from: "visible"
                ParallelAnimation {
                    NumberAnimation { 
                        property: "opacity"
                        duration: root.closeDuration
                        easing.type: Easing.InQuad
                    }
                    NumberAnimation { 
                        property: "scale"
                        to: root.initialScale
                        duration: root.closeDuration
                    }
                }
            }
        ]
        
        Item {
            id: contentContainer
            anchors.fill: parent
            z: 1
        }
    }
    
    function toggle() {
        shouldShow = !shouldShow
    }
    
    function open() {
        shouldShow = true
    }
    
    function close() {
        shouldShow = false
    }
}

