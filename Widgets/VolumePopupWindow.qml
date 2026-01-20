import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../Services" as Services

PanelWindow {
    id: popupWindow
    
    property bool shouldShow: false
    property bool isHovered: false
    readonly property var audio: Services.Audio
        
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: 4
        top: 4
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    color: "transparent"
    visible: shouldShow || container.opacity > 0
    
    WlrLayershell.keyboardFocus: shouldShow ? WlrKeyboardFocus.OnDemand : WlrKeyboardFocus.None
    
    FocusScope {
        id: container
        anchors.fill: parent
        scale: 0.85
        opacity: 0
        transformOrigin: Item.TopRight
        focus: true
        
        Keys.onEscapePressed: popupWindow.shouldShow = false
        
        states: State {
            name: "visible"
            when: popupWindow.shouldShow
            PropertyChanges { target: container; opacity: 1; scale: 1.0 }
        }
        
        transitions: [
            Transition {
                to: "visible"
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; duration: 180; easing.type: Easing.OutQuad }
                    NumberAnimation { property: "scale"; duration: 250; easing.type: Easing.OutBack; easing.overshoot: 1.3 }
                }
            },
            Transition {
                from: "visible"
                ParallelAnimation {
                    NumberAnimation { property: "opacity"; duration: 120; easing.type: Easing.InQuad }
                    NumberAnimation { property: "scale"; to: 0.85; duration: 120 }
                }
            }
        ]
        
        Rectangle {
            anchors.fill: backgroundRect
            anchors.margins: -6
            radius: backgroundRect.radius + 3
            color: "transparent"
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.35)
                shadowBlur: 0.8
                shadowVerticalOffset: 8
            }
        }
    
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: Services.Theme.surfaceBase
            radius: 16
            
            border.color: Services.Theme.surfaceBorder
            border.width: 1
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: popupWindow.isHovered = true
                onExited: popupWindow.isHovered = false
            }
        }
    }
    
    ColumnLayout {
        id: contentColumn
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        Text {
            text: "Volume"
            font.family: "Inter"
            font.pixelSize: 14
            font.weight: Font.DemiBold
            color: Services.Theme.foreground
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: audio.muted ? "󰖁" : "󰕾"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: Services.Theme.foreground
                }
                
                Text {
                    text: "Output"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Services.Theme.foreground
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Services.Theme.foreground
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Services.Theme.foreground
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.muted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: Services.Theme.background
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleMute()
                    }
                }
            }
            
            Slider {
                id: volumeSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                value: audio.percentage
                
                onMoved: {
                    audio.setVolume(value / 100)
                }
                
                background: Rectangle {
                    x: volumeSlider.leftPadding
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: volumeSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Services.Theme.foreground
                    
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: Services.Theme.primary
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: volumeSlider.leftPadding + volumeSlider.visualPosition * (volumeSlider.availableWidth - width)
                    y: volumeSlider.topPadding + volumeSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: Services.Theme.foreground
                    border.color: Services.Theme.primary
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
        
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 8
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 8
                
                Text {
                    text: audio.sourceMuted ? "󰍭" : "󰍬"
                    font.family: "Material Design Icons"
                    font.pixelSize: 20
                    color: Services.Theme.foreground
                }
                
                Text {
                    text: "Input"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Services.Theme.foreground
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.sourcePercentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Services.Theme.foreground
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Services.Theme.foreground
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.sourceMuted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: Services.Theme.background
                    }
                    
                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: audio.toggleSourceMute()
                    }
                }
            }
            
            Slider {
                id: inputSlider
                Layout.fillWidth: true
                from: 0
                to: 100
                value: audio.sourcePercentage
                
                onMoved: {
                    audio.setSourceVolume(value / 100)
                }
                
                background: Rectangle {
                    x: inputSlider.leftPadding
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                    implicitWidth: 200
                    implicitHeight: 6
                    width: inputSlider.availableWidth
                    height: implicitHeight
                    radius: 3
                    color: Services.Theme.primary
                    
                    Rectangle {
                        width: inputSlider.visualPosition * parent.width
                        height: parent.height
                        color: Services.Theme.primary
                        radius: 3
                        
                        Behavior on width {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                    }
                }
                
                handle: Rectangle {
                    x: inputSlider.leftPadding + inputSlider.visualPosition * (inputSlider.availableWidth - width)
                    y: inputSlider.topPadding + inputSlider.availableHeight / 2 - height / 2
                    implicitWidth: 18
                    implicitHeight: 18
                    radius: 9
                    color: Services.Theme.foreground
                    border.color: Services.Theme.primary
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}