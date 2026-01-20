import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../Services" as Services

Item {
    id: root
    
    property var barWindow
    property var volumePopup
    
    readonly property var audio: Services.Audio
    readonly property var volumeMonitor: Services.VolumeMonitor
    readonly property bool isHovered: mouseArea.containsMouse
    readonly property bool isMuted: volumeMonitor.muted
    readonly property int percentage: volumeMonitor.percentage
    
    implicitWidth: volumeRow.implicitWidth
    implicitHeight: 20
    
    RowLayout {
        id: volumeRow
        anchors.centerIn: parent
        spacing: 3
        
        Text {
            id: volumeIcon
            
            text: {
                if (isMuted) return "󰖁"
                if (percentage >= 70) return "󰕾"
                if (percentage >= 30) return "󰖀"
                return "󰕿"
            }
            
            font.family: "Material Design Icons"
            font.pixelSize: 14
            
            color: {
                if (isMuted) return Services.Theme.foreground
                if (isHovered) return Services.Theme.secondary
                return Services.Theme.foreground
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale {
                NumberAnimation { duration: 100 }
            }
        }
        
        Text {
            id: volumeText
            
            text: percentage
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: Font.Medium
            
            color: {
                if (isMuted) return Services.Theme.foregroundMuted
                return Services.Theme.foreground
            }
            
            Behavior on color {
                ColorAnimation { duration: 150 }
            }
            
            Behavior on text {
                SequentialAnimation {
                    NumberAnimation {
                        target: volumeText
                        property: "scale"
                        to: 1.15
                        duration: 80
                    }
                    NumberAnimation {
                        target: volumeText
                        property: "scale"
                        to: 1.0
                        duration: 100
                    }
                }
            }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
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
            if (!volumePopup) return
            
            volumePopup.shouldShow = !volumePopup.shouldShow
            if (!volumePopup.shouldShow) return
            if (!barWindow || !barWindow.screen) return
            
            const pos = root.mapToItem(barWindow.contentItem, 0, 0)
            const rightEdge = pos.x + root.width
            const screenWidth = barWindow.screen.width
            const barHeight = barWindow.implicitHeight || 36
            
            volumePopup.margins.right = Math.round(screenWidth - rightEdge)
            volumePopup.margins.top = 0
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
            target: volumeIcon
            property: "scale"
            to: 1.2
            duration: 80
        }
        NumberAnimation {
            target: volumeIcon
            property: "scale"
            to: isHovered ? 1.05 : 1.0
            duration: 120
        }
    }
}