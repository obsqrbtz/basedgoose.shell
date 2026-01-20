import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: root
    
    property var mediaPopup
    property var barWindow
    
    readonly property var player: Services.Players.active
    readonly property bool hasPlayer: player !== null
    readonly property bool isPlaying: player?.isPlaying ?? false
    
    height: 28
    width: hasPlayer ? (mediaPlayerContent.implicitWidth + 16) : 0
    visible: hasPlayer
    
    radius: 14
    color: Commons.Theme.foreground
    
    border.width: 1
    border.color: Commons.Theme.surfaceBorder
    
    clip: true
    
    Behavior on width {
        NumberAnimation { 
            duration: 400
            easing.bezierCurve: [0.34, 1.56, 0.64, 1]
        }
    }
    
    onIsPlayingChanged: {
        if (!isPlaying) {
            marqueeAnim.stop()
            titleText.x = titleText.needsScroll ? 0 : (titleContainer.width - titleText.implicitWidth) / 2
        }
    }
    
    // Top highlight
    Rectangle {
        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.margins: 1
        height: parent.height / 2
        radius: parent.radius - 1
        
        gradient: Gradient {
            GradientStop { position: 0.0; color: Qt.rgba(1, 1, 1, 0.04) }
            GradientStop { position: 1.0; color: "transparent" }
        }
    }
    
    Item {
        id: mediaPlayerContent
        anchors.centerIn: parent
        implicitWidth: hasPlayer ? contentRow.implicitWidth : noMediaRow.implicitWidth
        implicitHeight: 22
    
    RowLayout {
        id: noMediaRow
        anchors.centerIn: parent
        spacing: 6
        visible: !hasPlayer
        
        Text {
            text: "󰎇"
            font.family: "Material Design Icons"
            font.pixelSize: 14
            color: Commons.Theme.background
        }
        
        Text {
            text: "No media"
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.Medium
            color: Commons.Theme.background
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
            id: titleContainer
            Layout.preferredWidth: Math.max(80, Math.min(200, titleText.implicitWidth + 8))
            Layout.preferredHeight: parent.height
            clip: true
            
            Text {
                id: titleText
                anchors.verticalCenter: parent.verticalCenter
                text: {
                    var artist = root.player?.trackArtist ?? ""
                    var title = root.player?.trackTitle ?? "Unknown"
                    if (artist && artist.trim() !== "") {
                        return artist + " - " + title
                    }
                    return title
                }
                color: Commons.Theme.background
                font.pixelSize: 10
                font.weight: Font.Medium
                
                readonly property bool needsScroll: implicitWidth > titleContainer.width
                x: needsScroll ? 0 : (titleContainer.width - implicitWidth) / 2
                
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
                        value: titleContainer.width
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
                            root.mediaPopup.margins.left = Commons.Config.mediaPlayer.popupMargin
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
            color: Commons.Theme.background
        }
        
        RowLayout {
            spacing: 2
            
            Rectangle {
                Layout.preferredWidth: 20
                Layout.preferredHeight: 20
                radius: 10
                color: prevArea.containsMouse ? Commons.Theme.secondary : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: prevArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒮"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: Commons.Theme.background
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
                color: Commons.Theme.background
                
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
                color: nextArea.containsMouse ? Commons.Theme.secondary : "transparent"
                
                Behavior on color { ColorAnimation { duration: 100 } }
                Behavior on scale { NumberAnimation { duration: 80 } }
                scale: nextArea.pressed ? 0.9 : 1.0
                
                Text {
                    anchors.centerIn: parent
                    text: "󰒭"
                    font.family: "Material Design Icons"
                    font.pixelSize: 13
                    color: Commons.Theme.background
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
}

