import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: popupWindow
    
    property bool isHovered: false
    
    readonly property var player: Services.Players.active
    readonly property real playerPosition: Services.Players.currentPosition
    readonly property real playerLength: Services.Players.trackLength
    readonly property bool playerIsPlaying: Services.Players.isPlaying
    
    initialScale: 0.94
    transformOriginX: 0.0
    transformOriginY: 0.0
    
    anchors {
        top: true
        left: true
    }
    
    margins {
        top: Commons.Config.popupMargin
        left: Commons.Config.popupMargin
    }
    
    implicitWidth: 360
    implicitHeight: player ? contentColumn.implicitHeight + 40 : 0
    
    visible: shouldShow && player !== null
    
    readonly property color surfaceBase: Commons.Theme.surfaceBase
    readonly property color surfaceContainer: Commons.Theme.surfaceContainer
    readonly property color surfaceText: Commons.Theme.surfaceText
    readonly property color surfaceTextVariant: Commons.Theme.surfaceTextVariant
    readonly property color surfaceBorder: Commons.Theme.surfaceBorder
    
    Item {
        id: contentItem
        anchors.fill: parent
        
        property real progress: 0
        
        Rectangle {
            id: backgroundRect
            anchors.fill: parent
            color: surfaceBase
            radius: 16
            border.color: Commons.Theme.border
            border.width: 1
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                onEntered: popupWindow.isHovered = true
                onExited: popupWindow.isHovered = false
            }
            
            layer.enabled: true
            layer.effect: MultiEffect {
                shadowEnabled: true
                shadowColor: Qt.rgba(0, 0, 0, 0.25)
                shadowBlur: 0.8
                shadowVerticalOffset: 8
                shadowHorizontalOffset: 0
            }
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 20
            spacing: 16
            visible: player !== null
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Text {
                    text: "Media Player"
                    font.family: Commons.Theme.fontUI
                    font.pixelSize: 20
                    font.weight: Font.Bold
                    color: surfaceText
                    Layout.fillWidth: true
                }
                
                Widgets.IconButton {
                    icon: "󰅖"
                    iconSize: 18
                    iconColor: surfaceTextVariant
                    onClicked: popupWindow.shouldShow = false
                }
            }
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 1
                color: surfaceBorder
            }
            
            Rectangle {
                Layout.alignment: Qt.AlignHCenter
                Layout.preferredWidth: Commons.Config.mediaPlayer.albumArtSize
                Layout.preferredHeight: Commons.Config.mediaPlayer.albumArtSize
                radius: 14
                color: surfaceContainer
                clip: true
                
                border.width: 1
                border.color: surfaceBorder
                
                Image {
                    anchors.fill: parent
                    anchors.margins: 1
                    source: player?.trackArtUrl ?? ""
                    sourceSize: Qt.size(Commons.Config.mediaPlayer.albumArtSize * 2, Commons.Config.mediaPlayer.albumArtSize * 2)
                    fillMode: Image.PreserveAspectCrop
                    asynchronous: true
                    smooth: true
                    visible: player?.trackArtUrl ?? false
                    
                    layer.enabled: true
                    layer.effect: MultiEffect {
                        maskEnabled: true
                        maskThresholdMin: 0.5
                        maskSpreadAtMin: 1.0
                        maskSource: ShaderEffectSource {
                            sourceItem: Rectangle {
                                width: 1
                                height: 1
                                radius: 0.5
                            }
                        }
                    }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "󰎈"
                    font.family: Commons.Theme.fontIcon
                    font.pixelSize: 80
                    color: surfaceTextVariant
                    visible: !(player?.trackArtUrl ?? false)
                    opacity: 0.3
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 4
                
                Text {
                    Layout.fillWidth: true
                    text: player?.trackTitle ?? "Unknown"
                    color: surfaceText
                    font.pixelSize: 15
                    font.weight: Font.DemiBold
                    font.family: Commons.Theme.fontUI
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                    maximumLineCount: 2
                    wrapMode: Text.Wrap
                }
                
                Text {
                    Layout.fillWidth: true
                    text: player?.trackArtist ?? ""
                    color: surfaceTextVariant
                    font.pixelSize: 12
                    font.family: Commons.Theme.fontUI
                    font.weight: Font.Medium
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
                
                Text {
                    Layout.fillWidth: true
                    text: player?.trackAlbum ?? ""
                    color: surfaceTextVariant
                    font.pixelSize: 11
                    font.family: Commons.Theme.fontUI
                    opacity: 0.8
                    elide: Text.ElideRight
                    horizontalAlignment: Text.AlignHCenter
                }
            }
            
            ColumnLayout {
                Layout.fillWidth: true
                spacing: 6
                
                Slider {
                    id: progressSlider
                    Layout.fillWidth: true
                    from: 0
                    to: popupWindow.playerLength > 0 ? popupWindow.playerLength : 1
                    enabled: player && player.canSeek && player.positionSupported
                    
                    property bool userInteracting: false
                    
                    Binding {
                        target: progressSlider
                        property: "value"
                        value: popupWindow.playerPosition ?? 0
                        when: !progressSlider.userInteracting
                    }
                    
                    onPressedChanged: {
                        userInteracting = pressed
                        if (pressed && player && player.positionSupported) {
                            player.positionChanged()
                        }
                    }
                    
                    onMoved: {
                        if (player && player.canSeek && player.positionSupported) {
                            var newPosition = value
                            var currentPosition = player.position || 0
                            var offset = newPosition - currentPosition
                            if (Math.abs(offset) > 0.05) {
                                player.seek(offset)
                            }
                        }
                    }
                    
                    background: Rectangle {
                        x: progressSlider.leftPadding
                        y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                        implicitWidth: 200
                        implicitHeight: 6
                        width: progressSlider.availableWidth
                        height: implicitHeight
                        radius: 3
                        color: surfaceText
                        opacity: 0.15
                        
                        Rectangle {
                            width: progressSlider.visualPosition * parent.width
                            height: parent.height
                            color: Commons.Theme.primary
                            radius: 3
                            
                            Behavior on width {
                                NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                            }
                        }
                    }
                    
                    handle: Rectangle {
                        x: progressSlider.leftPadding + progressSlider.visualPosition * (progressSlider.availableWidth - width)
                        y: progressSlider.topPadding + progressSlider.availableHeight / 2 - height / 2
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: surfaceText
                        border.color: Commons.Theme.primary
                        border.width: 2
                        visible: progressSlider.hovered || progressSlider.pressed
                        opacity: visible ? 1.0 : 0.0
                        
                        Behavior on x {
                            NumberAnimation { duration: 100; easing.type: Easing.OutCubic }
                        }
                        Behavior on opacity {
                            NumberAnimation { duration: 150 }
                        }
                    }
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: popupWindow.formatTime(popupWindow.playerPosition ?? 0)
                        color: surfaceTextVariant
                        font.pixelSize: 10
                        font.family: Commons.Theme.font
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: popupWindow.formatTime(popupWindow.playerLength ?? 0)
                        color: surfaceTextVariant
                        font.pixelSize: 10
                        font.family: Commons.Theme.font
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Rectangle {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                    radius: 8
                    color: prevArea.containsMouse ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.15) : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 80 }
                    }
                    scale: prevArea.pressed ? 0.85 : (prevArea.containsMouse ? 1.05 : 1.0)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒮"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 18
                        color: surfaceText
                    }
                    
                    MouseArea {
                        id: prevArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) player.previous()
                        }
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.playButtonSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.playButtonSize
                    radius: Commons.Config.mediaPlayer.playButtonSize / 2
                    color: playHover.containsMouse ? Commons.Theme.secondary : Commons.Theme.primary
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 80 }
                    }
                    scale: playHover.pressed ? 0.85 : (playHover.containsMouse ? 1.05 : 1.0)
                    
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: (player?.isPlaying ?? false) ? 0 : 1
                        text: (player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 24
                        color: Commons.Theme.background
                    }
                    
                    MouseArea {
                        id: playHover
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) player.togglePlaying()
                        }
                    }
                }
                
                Rectangle {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                    radius: 8
                    color: nextArea.containsMouse ? Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.15) : "transparent"
                    
                    Behavior on color {
                        ColorAnimation { duration: 100 }
                    }
                    Behavior on scale {
                        NumberAnimation { duration: 80 }
                    }
                    scale: nextArea.pressed ? 0.85 : (nextArea.containsMouse ? 1.05 : 1.0)
                    
                    Text {
                        anchors.centerIn: parent
                        text: "󰒭"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 18
                        color: surfaceText
                    }
                    
                    MouseArea {
                        id: nextArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (player) player.next()
                        }
                    }
                }
                
                Item { Layout.fillWidth: true }
            }
        }
        
        Timer {
            id: progressTimer
            interval: 250
            repeat: true
            running: true
            onTriggered: {
                if (!popupWindow.player || !popupWindow.playerLength || popupWindow.playerLength <= 0) {
                    contentItem.progress = 0
                } else {
                    var p = popupWindow.playerPosition / popupWindow.playerLength
                    if (!isFinite(p) || p < 0) p = 0
                    contentItem.progress = Math.max(0, Math.min(1, p))
                }
                
                if (popupWindow.player && popupWindow.player.positionSupported && popupWindow.player.isPlaying) {
                    popupWindow.player.positionChanged()
                }
            }
        }
    }
    
    readonly property real progress: contentItem.progress
    function formatTime(seconds) {
        if (!seconds || seconds <= 0) return "0:00"
        const mins = Math.floor(seconds / 60)
        const secs = Math.floor(seconds % 60)
        return mins + ":" + (secs < 10 ? "0" : "") + secs
    }
}

