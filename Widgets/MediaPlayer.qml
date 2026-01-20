import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../Services" as Services

Item {
    id: root
    
    property var mediaPopup
    
    readonly property var player: Services.Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    
    readonly property real titleWidth: 80
    
    implicitWidth: hasPlayer ? contentRow.implicitWidth : noMediaRow.implicitWidth
    implicitHeight: 22
    
    onIsPlayingChanged: {
        if (!isPlaying) {
            marqueeAnim.stop()
            titleText.x = titleText.needsScroll ? 0 : (titleWidth - titleText.implicitWidth) / 2
        }
    }
    
    RowLayout {
        id: noMediaRow
        anchors.centerIn: parent
        spacing: 6
        visible: !hasPlayer
        
        Text {
            text: "󰎇"
            font.family: "Material Design Icons"
            font.pixelSize: 14
            color: Services.Theme.background
        }
        
        Text {
            text: "No media"
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Services.Theme.background
        }
    }
    
    MouseArea {
        anchors.fill: noMediaRow
        visible: !hasPlayer
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
    }
    
    RowLayout {
        id: contentRow
        anchors.centerIn: parent
        spacing: 6
        visible: hasPlayer
        
        Item {
            Layout.preferredWidth: root.titleWidth
            Layout.preferredHeight: parent.height
            clip: true
            
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                text: root.player?.trackTitle ?? "Unknown"
                color: Services.Theme.background
                font.pixelSize: 10
                font.weight: Font.Medium
                
                readonly property bool needsScroll: implicitWidth > root.titleWidth
                x: needsScroll ? 0 : (root.titleWidth - implicitWidth) / 2
                
                SequentialAnimation {
                    id: marqueeAnim
                    running: titleText.needsScroll && root.isPlaying
                    loops: Animation.Infinite
                    
                    PauseAnimation { duration: 2000 }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: -(titleText.implicitWidth + 20)
                        duration: titleText.implicitWidth * 30
                        easing.type: Easing.Linear
                    }
                    PropertyAction { 
                        target: titleText
                        property: "x"
                        value: root.titleWidth
                    }
                    NumberAnimation {
                        target: titleText
                        property: "x"
                        to: 0
                        duration: 300
                        easing.type: Easing.OutCubic
                    }
                }
            }
            
            MouseArea {
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: {
                    if (root.mediaPopup && root.player) {
                        if (!root.mediaPopup.shouldShow) {
                            root.mediaPopup.margins.left = Services.Config.mediaPlayer.popupMargin
                        }
                        root.mediaPopup.shouldShow = !root.mediaPopup.shouldShow
                    }
                }
            }
        }
        
        Rectangle {
            Layout.preferredWidth: 1
            Layout.preferredHeight: 12
            radius: 0.5
            color: Services.Theme.background
        }
        
        RowLayout {
            spacing: 2
            
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: prevArea.containsMouse ? Services.Theme.secondary : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: prevArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: Services.Theme.background
                }
                
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canGoPrevious) {
                            root.player.previous()
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 24
                Layout.preferredHeight: 24
                radius: 12
                color: Services.Theme.background
                
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: playArea.pressed ? 0.85 : (playArea.containsMouse ? 1.05 : 1.0)
                
                Text {
                    anchors.centerIn: parent
                    anchors.horizontalCenterOffset: root.isPlaying ? 0 : 1
                    text: root.isPlaying ? "󰏤" : "󰐊"
                    font.family: "Material Design Icons"
                    font.pixelSize: 14
                    color: "#ffffff"
                }
                
                MouseArea {
                    id: playArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canTogglePlaying) {
                            root.player.togglePlaying()
                        }
                    }
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: nextArea.containsMouse ? Services.Theme.secondary : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: nextArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: Services.Theme.background
                }
                
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    
                    onClicked: {
                        if (root.player && root.player.canGoNext) {
                            root.player.next()
                        }
                    }
                }
            }
        }
    }
}