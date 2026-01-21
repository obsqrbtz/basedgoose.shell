import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Item {
    id: root
    
    property var barWindow
    property var calendarPopup
    
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: clockText.implicitWidth
    implicitHeight: 20
    
    Text {
        id: clockText
        anchors.centerIn: parent
        
        color: Commons.Theme.foreground
        font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
        text: Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
        
        scale: isHovered ? 1.05 : 1.0
        Behavior on scale {
            NumberAnimation { duration: 100 }
        }
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
        
        Timer {
            interval: Commons.Config.clockUpdateInterval
            running: true
            repeat: true
            onTriggered: clockText.text = Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (!calendarPopup) return
            
            calendarPopup.shouldShow = !calendarPopup.shouldShow
            if (!calendarPopup.shouldShow) return
            if (!barWindow || !barWindow.screen) return
            
            const pos = root.mapToItem(barWindow.contentItem, 0, 0)
            const clockCenterX = pos.x + root.width / 2
            const screenWidth = barWindow.screen.width
            const popupWidth = calendarPopup.implicitWidth || 320
            
            calendarPopup.margins.left = Math.max(Commons.Config.popupMargin, Math.round(clockCenterX - popupWidth / 2))
            calendarPopup.margins.top = Commons.Config.popupMargin
        }
    }
}
