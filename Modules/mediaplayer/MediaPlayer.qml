import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: root
    
    property var mediaPopup
    property var barWindow
    property bool isVertical: false
    
    readonly property var player: Services.Players.active
    readonly property bool hasPlayer: !!player
    readonly property bool isPlaying: player?.isPlaying ?? false
    
    implicitWidth: isVertical ? Commons.Config.barWidth - Commons.Config.barPadding * 2 - 4 : (hasPlayer ? Math.max(0, mediaPlayerContent.implicitWidth) + Commons.Config.componentPadding * 2 : 0)
    implicitHeight: isVertical ? verticalContent.implicitHeight + 12 : Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight
    visible: hasPlayer
    
    Component.onCompleted: {
        if (Services.Players) {
            Services.Players.updateActivePlayer()
        }
    }
    
    radius: 0
    color: "transparent"
    border.width: 0
    clip: true
    
    Behavior on implicitWidth {
        NumberAnimation { 
            duration: 400
            easing.bezierCurve: [0.34, 1.56, 0.64, 1]
        }
    }
    
    onIsPlayingChanged: {
        if (!isPlaying && !isVertical) {
            marqueeAnim.stop()
            titleRow.x = titleRow.needsScroll ? 0 : (titleContainer.width - titleRow.implicitWidth) / 2
        }
    }
    
    // Horizontal layout
    Item {
        id: mediaPlayerContent
        anchors.centerIn: parent
        implicitWidth: hasPlayer ? contentRow.implicitWidth + 8 : 0
        implicitHeight: 22
        visible: !isVertical

        function formatTime(microseconds) {
            if (!microseconds || microseconds <= 0) return "--:--"
            var s = Math.floor(microseconds / 1000000)
            var m = Math.floor(s / 60)
            s = s % 60
            return m + ":" + (s < 10 ? "0" : "") + s
        }

        RowLayout {
            id: contentRow
            anchors.centerIn: parent
            spacing: 3
            visible: hasPlayer

            Text {
                text: "[<]"
                color: prevArea.containsMouse ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                font { family: Commons.Theme.fontMono; pixelSize: 10; weight: Font.Normal }
                Behavior on color { ColorAnimation { duration: 80 } }
                MouseArea {
                    id: prevArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player?.canGoPrevious) root.player.previous() }
                }
            }

            Text {
                text: root.isPlaying ? " ▶" : " ‖"
                color: Commons.Theme.primary
                font { family: Commons.Theme.fontMono; pixelSize: 10; weight: Font.Medium }
            }

            Item {
                id: titleContainer
                Layout.preferredWidth: Math.max(80, Math.min(180, titleRow.implicitWidth))
                Layout.preferredHeight: contentRow.height
                clip: true

                Row {
                    id: titleRow
                    anchors.verticalCenter: parent.verticalCenter
                    spacing: 0
                    readonly property bool needsScroll: implicitWidth > titleContainer.width
                    x: needsScroll ? 0 : (titleContainer.width - implicitWidth) / 2

                    Text {
                        text: {
                            var artist = root.player?.trackArtist ?? ""
                            return artist && artist.trim() !== "" ? " " + artist + " - " : " "
                        }
                        color: Commons.Theme.foregroundMuted
                        font { family: Commons.Theme.fontMono; pixelSize: 10; weight: Font.Normal }
                        visible: text.trim() !== ""
                    }
                    Text {
                        text: root.player?.trackTitle ?? "Unknown"
                        color: Commons.Theme.foreground
                        font { family: Commons.Theme.fontMono; pixelSize: 10; weight: Font.Normal }
                    }

                    SequentialAnimation {
                        id: marqueeAnim
                        running: titleRow.needsScroll && root.isPlaying && !root.isVertical
                        loops: Animation.Infinite
                        PauseAnimation { duration: 2000 }
                        NumberAnimation {
                            target: titleRow; property: "x"
                            to: titleContainer.width - titleRow.implicitWidth
                            duration: Math.abs(titleContainer.width - titleRow.implicitWidth) * 20
                            easing.type: Easing.Linear
                        }
                        PauseAnimation { duration: 2000 }
                        NumberAnimation {
                            target: titleRow; property: "x"; to: 0
                            duration: 300; easing.type: Easing.OutCubic
                        }
                    }
                }

                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: {
                        if (root.mediaPopup && root.barWindow) {
                            if (!root.mediaPopup.shouldShow)
                                root.mediaPopup.positionNear(root, root.barWindow)
                            root.mediaPopup.shouldShow = !root.mediaPopup.shouldShow
                        }
                    }
                }
            }

            Text {
                text: " " + mediaPlayerContent.formatTime(Services.Players.currentPosition)
                color: Commons.Theme.foregroundMuted
                font { family: Commons.Theme.fontMono; pixelSize: 9; weight: Font.Normal }
                visible: Services.Players.trackLength > 0
            }

            Text {
                text: "[>]"
                color: nextArea.containsMouse ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                font { family: Commons.Theme.fontMono; pixelSize: 10; weight: Font.Normal }
                Behavior on color { ColorAnimation { duration: 80 } }
                MouseArea {
                    id: nextArea
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player?.canGoNext) root.player.next() }
                }
            }
        }
    }
    
    // Vertical layout
    Column {
        id: verticalContent
        anchors.centerIn: parent
        spacing: 4
        visible: isVertical

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: root.isPlaying ? "▶" : "‖"
            color: Commons.Theme.primary
            font { family: Commons.Theme.fontMono; pixelSize: 14; weight: Font.Medium }
            MouseArea {
                id: playAreaV
                anchors.fill: parent
                hoverEnabled: true
                cursorShape: Qt.PointingHandCursor
                onClicked: { if (root.player?.canTogglePlaying) root.player.togglePlaying() }
            }
        }

        Row {
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: 4

            Text {
                text: "[<]"
                color: prevAreaV.containsMouse ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                font { family: Commons.Theme.fontMono; pixelSize: 9; weight: Font.Normal }
                Behavior on color { ColorAnimation { duration: 80 } }
                MouseArea {
                    id: prevAreaV
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player?.canGoPrevious) root.player.previous() }
                }
            }

            Text {
                text: "[>]"
                color: nextAreaV.containsMouse ? Commons.Theme.primary : Commons.Theme.foregroundMuted
                font { family: Commons.Theme.fontMono; pixelSize: 9; weight: Font.Normal }
                Behavior on color { ColorAnimation { duration: 80 } }
                MouseArea {
                    id: nextAreaV
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: { if (root.player?.canGoNext) root.player.next() }
                }
            }
        }
    }
    
    MouseArea {
        anchors.fill: parent
        visible: isVertical
        acceptedButtons: Qt.LeftButton
        z: -1
        onClicked: {
            if (root.mediaPopup && root.barWindow) {
                if (!root.mediaPopup.shouldShow) {
                    root.mediaPopup.positionNear(root, root.barWindow)
                }
                root.mediaPopup.shouldShow = !root.mediaPopup.shouldShow
            }
        }
    }
}
