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
    
    readonly property color surfaceBase: Commons.Theme.background
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
            radius: Commons.Theme.radius * 2
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
                
                Widgets.HeaderWithIcon {
                    icon: "󰎈"
                    title: "Media Player"
                    iconColor: surfaceText
                    titleColor: surfaceText
                }
                
                Item { Layout.fillWidth: true }
                
                Widgets.IconButton {
                    Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
                    icon: "󰅖"
                    iconSize: 18
                    iconColor: surfaceTextVariant
                    onClicked: popupWindow.shouldShow = false
                }
            }
            
            Widgets.Divider {
                Layout.fillWidth: true
                dividerColor: surfaceBorder
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
                
                Widgets.CustomSlider {
                    id: progressSlider
                    Layout.fillWidth: true
                    from: 0
                    to: popupWindow.playerLength > 0 ? popupWindow.playerLength : 1
                    enabled: player && player.canSeek && player.positionSupported
                    trackColor: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.15)
                    progressColor: Commons.Theme.primary
                    handleColor: surfaceText
                    handleBorderColor: Commons.Theme.primary
                    
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
                }
                
                RowLayout {
                    Layout.fillWidth: true
                    
                    Text {
                        text: popupWindow.formatTime(popupWindow.playerPosition ?? 0)
                        color: surfaceTextVariant
                        font.pixelSize: 10
                        font.family: Commons.Theme.fontMono
                    }
                    
                    Item { Layout.fillWidth: true }
                    
                    Text {
                        text: popupWindow.formatTime(popupWindow.playerLength ?? 0)
                        color: surfaceTextVariant
                        font.pixelSize: 10
                        font.family: Commons.Theme.fontMono
                    }
                }
            }
            
            RowLayout {
                Layout.fillWidth: true
                spacing: 12
                
                Item { Layout.fillWidth: true }
                
                Widgets.MediaControlButton {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                    icon: "󰒮"
                    iconColor: surfaceText
                    onClicked: {
                        if (player) player.previous()
                    }
                }
                
                Widgets.MediaControlButton {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.playButtonSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.playButtonSize
                    radius: Commons.Config.mediaPlayer.playButtonSize / 2
                    icon: (player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                    iconSize: 24
                    iconColor: Commons.Theme.background
                    baseColor: Commons.Theme.primary
                    hoverColor: Commons.Theme.secondary
                    onClicked: {
                        if (player) player.togglePlaying()
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: (player?.isPlaying ?? false) ? 0 : 1
                        text: (player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 24
                        color: Commons.Theme.background
                    }
                }
                
                Widgets.MediaControlButton {
                    Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                    Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                    icon: "󰒭"
                    iconColor: surfaceText
                    onClicked: {
                        if (player) player.next()
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

