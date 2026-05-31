import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons

Item {
    id: root
    
    property var barWindow
    property var volumePopup
    property bool isVertical: false
    
    readonly property var audio: Services.Audio
    readonly property var volumeMonitor: Services.VolumeMonitor
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isMuted: volumeMonitor.muted
    readonly property int percentage: volumeMonitor.percentage
    
    implicitWidth: isVertical ? 28 : volumeRow.implicitWidth
    implicitHeight: isVertical ? volumeCol.implicitHeight : Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: Commons.Theme.radiusLg
        color: Commons.Theme.primary
        opacity: isHovered ? Commons.Theme.stateLayerHover : 0.0
        Behavior on opacity { NumberAnimation { duration: Commons.Theme.animNormal } }
    }

    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: Commons.Theme.spacingXs
        visible: !isVertical

        Text {
            id: volumeIcon
            text: {
                if (isMuted) return "󰖁"
                if (percentage >= 70) return "󰕾"
                if (percentage >= 30) return "󰖀"
                return "󰕿"
            }
            font.family: Commons.Theme.fontIcon
            font.pixelSize: Commons.Theme.iconSize
            color: isMuted ? Commons.Theme.foregroundMuted : (isHovered ? Commons.Theme.secondary : Commons.Theme.foreground)

            Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
        }

        Text {
            id: volumeText
            text: percentage + "%"
            font.family: Commons.Theme.fontMono
            font.pixelSize: Commons.Theme.fontSizeCaption
            font.weight: Font.Medium
            color: isMuted ? Commons.Theme.foregroundMuted : Commons.Theme.foreground

            Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
        }
    }

    Column {
        id: volumeCol
        anchors.centerIn: parent
        spacing: 2
        visible: isVertical

        Text {
            id: volumeIconV
            anchors.horizontalCenter: parent.horizontalCenter
            text: {
                if (isMuted) return "󰖁"
                if (percentage >= 70) return "󰕾"
                if (percentage >= 30) return "󰖀"
                return "󰕿"
            }
            font.family: Commons.Theme.fontIcon
            font.pixelSize: Commons.Theme.iconSize
            color: isMuted ? Commons.Theme.foregroundMuted : (isHovered ? Commons.Theme.secondary : Commons.Theme.foreground)

            Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
        }

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            text: percentage + "%"
            font.family: Commons.Theme.fontMono
            font.pixelSize: Commons.Theme.fontSizeTiny
            font.weight: Font.Medium
            color: isMuted ? Commons.Theme.foregroundMuted : Commons.Theme.foreground
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onWheel: wheel => {
            if (wheel.angleDelta.y > 0) {
                audio.increaseVolume()
            } else {
                audio.decreaseVolume()
            }
        }
        
        onClicked: {
            if (volumePopup && barWindow) {
                if (!volumePopup.shouldShow) {
                    volumePopup.positionNear(root, barWindow)
                }
                volumePopup.shouldShow = !volumePopup.shouldShow
            }
        }
    }
    
    Connections {
        target: volumeMonitor
        function onPercentageChanged() {
            pulseAnim.restart()
        }
    }
    
    SequentialAnimation {
        id: pulseAnim

        NumberAnimation {
            target: isVertical ? volumeIconV : volumeIcon
            property: "scale"
            to: 1.2
            duration: 80
        }
        NumberAnimation {
            target: isVertical ? volumeIconV : volumeIcon
            property: "scale"
            to: 1.0
            duration: 120
        }
    }
}
