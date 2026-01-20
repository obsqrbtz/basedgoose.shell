import Quickshell
import Quickshell.Wayland
import QtQuick 6.10
import QtQuick.Layouts 6.10
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
        top: 4
        left: Commons.Config.mediaPlayer.popupMargin
    }
    
    implicitWidth: 360
    implicitHeight: player ? contentColumn.implicitHeight + 32 : 0
    
    visible: shouldShow && player !== null
    
    Item {
        id: contentItem
        anchors.fill: parent
        
        property real progress: 0
        
        Rectangle {
            anchors.fill: parent
            radius: Commons.Config.notifications.centerRadius
            color: Commons.Theme.surfaceBase

            border.width: 1
            border.color: Commons.Theme.border
            
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
        anchors.margins: 16
        spacing: 16
        visible: player !== null
        
        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: Commons.Config.mediaPlayer.albumArtSize
            Layout.preferredHeight: Commons.Config.mediaPlayer.albumArtSize
            radius: 14
            color: Commons.Theme.surfaceContainer
            clip: true
            
            border.width: 1
            border.color: Commons.Theme.surfaceBorder
            
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
                font.family: "Material Design Icons"
                font.pixelSize: 80
                color: Commons.Theme.surfaceTextVariant
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
                color: Commons.Theme.surfaceText
                font.pixelSize: 16
                font.weight: Font.Bold
                font.family: "Inter"
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
                maximumLineCount: 2
                wrapMode: Text.Wrap
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackArtist ?? ""
                color: Commons.Theme.surfaceTextVariant
                font.pixelSize: 13
                font.family: "Inter"
                font.weight: Font.Medium
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
            
            Text {
                Layout.fillWidth: true
                text: player?.trackAlbum ?? ""
                color: Commons.Theme.surfaceTextVariant
                font.pixelSize: 11
                font.family: "Inter"
                opacity: 0.7
                elide: Text.ElideRight
                horizontalAlignment: Text.AlignHCenter
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 6
            Layout.topMargin: 8
            
            color: Commons.Theme.surfaceContainer
            radius: 3
            
            Rectangle {
                height: parent.height
                color: Commons.Theme.secondary
                radius: 3
                
                width: parent.width * (contentItem.progress)

                Behavior on width {
                    NumberAnimation { duration: 80 }
                }
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            
            Text {
                text: popupWindow.formatTime(popupWindow.playerPosition ?? 0)
                color: Commons.Theme.surfaceTextVariant
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
            
            Item { Layout.fillWidth: true }
            
            Text {
                text: popupWindow.formatTime(popupWindow.playerLength ?? 0)
                color: Commons.Theme.surfaceTextVariant
                font.pixelSize: 10
                font.family: "JetBrainsMono Nerd Font"
            }
        }
        
        RowLayout {
            Layout.fillWidth: true
            Layout.topMargin: 8
            spacing: 16
            
            Item { Layout.fillWidth: true }
            
            Widgets.IconButton {
                Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                icon: "󰒮"
                iconSize: 20
                iconColor: Commons.Theme.surfaceText
                animationDuration: 120
                onClicked: {
                    if (player) player.previous()
                }
            }
            
            Rectangle {
                Layout.preferredWidth: Commons.Config.mediaPlayer.playButtonSize
                Layout.preferredHeight: Commons.Config.mediaPlayer.playButtonSize
                property color baseColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.9)
                property color hoverColor: Commons.Theme.secondary
                property color pressedColor: Qt.darker(Commons.Theme.secondary, 1.1)
                color: playHover.pressed ? pressedColor : (playHover.containsMouse ? hoverColor : baseColor)
                radius: Commons.Config.mediaPlayer.playButtonSize / 2

                Behavior on color { ColorAnimation { duration: 120 } }
                
                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: (player?.isPlaying ?? false) ? 0 : 1
                    text: (player?.isPlaying ?? false) ? "󰏤" : "󰐊"
                    font.family: "Material Design Icons"
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
            
            Widgets.IconButton {
                Layout.preferredWidth: Commons.Config.mediaPlayer.controlSize
                Layout.preferredHeight: Commons.Config.mediaPlayer.controlSize
                icon: "󰒭"
                iconSize: 20
                iconColor: Commons.Theme.surfaceText
                animationDuration: 120
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

