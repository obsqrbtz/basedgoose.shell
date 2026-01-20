import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: popupWindow
    
    ipcTarget: "volume"
    initialScale: 0.85
    transformOriginX: 1.0
    transformOriginY: 0.0
    
    property bool isHovered: false
    readonly property var audio: Services.Audio
        
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: Commons.Config.popupMargin
        top: Commons.Config.popupMargin
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    
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
        color: Commons.Theme.surfaceBase
        radius: 16
        
        border.color: Commons.Theme.border
        border.width: 1
        
        MouseArea {
            anchors.fill: parent
            hoverEnabled: true
            onEntered: popupWindow.isHovered = true
            onExited: popupWindow.isHovered = false
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
            color: Commons.Theme.foreground
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
                    color: Commons.Theme.foreground
                }
                
                Text {
                    text: "Output"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Commons.Theme.foreground
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.percentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Commons.Theme.foreground
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Commons.Theme.foreground
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.muted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: Commons.Theme.background
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
                    color: Commons.Theme.foreground
                    
                    Rectangle {
                        width: volumeSlider.visualPosition * parent.width
                        height: parent.height
                        color: Commons.Theme.primary
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
                    color: Commons.Theme.foreground
                    border.color: Commons.Theme.primary
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
                    color: Commons.Theme.foreground
                }
                
                Text {
                    text: "Input"
                    font.family: "Inter"
                    font.pixelSize: 12
                    color: Commons.Theme.foreground
                }
                
                Item { Layout.fillWidth: true }
                
                Text {
                    text: audio.sourcePercentage + "%"
                    font.family: "Inter"
                    font.pixelSize: 12
                    font.weight: Font.Medium
                    color: Commons.Theme.foreground
                }
                
                Rectangle {
                    width: 28
                    height: 28
                    radius: 6
                    color: Commons.Theme.foreground
                    
                    Behavior on color {
                        ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: audio.sourceMuted ? "󰝟" : "󰝚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: Commons.Theme.background
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
                    color: Commons.Theme.foreground
                    
                    Rectangle {
                        width: inputSlider.visualPosition * parent.width
                        height: parent.height
                        color: Commons.Theme.primary
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
                    color: Commons.Theme.foreground
                    border.color: Commons.Theme.primary
                    border.width: 2
                    
                    Behavior on x {
                        NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                    }
                }
            }
        }
    }
}

