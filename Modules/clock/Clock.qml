import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Item {
    id: root
    
    property var barWindow
    property var calendarPopup
    property bool isVertical: false
    
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: isVertical ? Commons.Config.barWidth - Commons.Config.barPadding * 2 - 4 : clockText.implicitWidth
    implicitHeight: isVertical ? clockColV.implicitHeight : 20
    
    // Horizontal layout 
    Text {
        id: clockText
        anchors.centerIn: parent
        visible: !isVertical
        
        color: Commons.Theme.foreground
        font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
        text: Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
        
        scale: isHovered ? 1.05 : 1.0
        Behavior on scale { NumberAnimation { duration: 100 } }
        Behavior on color { ColorAnimation { duration: 150 } }
    }
    
    // Vertical layout
    Column {
        id: clockColV
        anchors.centerIn: parent
        spacing: 2
        visible: isVertical
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Commons.Theme.foreground
            font { family: Commons.Theme.fontMono; pixelSize: 11; weight: Font.DemiBold }
            text: Qt.formatDateTime(new Date(), "HH:mm")
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
        
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Commons.Theme.foregroundMuted
            font { family: Commons.Theme.fontMono; pixelSize: 8; weight: Font.Medium }
            text: Qt.formatDateTime(new Date(), "ddd")
            
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
    }
    
    Timer {
        interval: Commons.Config.clockUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            clockText.text = Qt.formatDateTime(new Date(), Commons.Config.clockFormat)
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: -4
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (calendarPopup && barWindow) {
                if (!calendarPopup.shouldShow) {
                    calendarPopup.positionNear(root, barWindow)
                }
                calendarPopup.shouldShow = !calendarPopup.shouldShow
            }
        }
    }
}
