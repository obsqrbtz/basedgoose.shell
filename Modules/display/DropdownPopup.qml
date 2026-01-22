import QtQuick 6.10
import QtQuick.Effects
import "../../Commons" as Commons

Rectangle {
    id: root
    
    // Configuration
    property string parentMonitor: ""
    property int popupWidth: 200
    property int popupHeight: 200
    
    // Theme colors
    property color cSurface: Commons.Theme.background
    property color cText: Commons.Theme.foreground
    property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    // Content
    default property alias content: contentContainer.data
    
    visible: false
    width: popupWidth
    height: popupHeight
    radius: 10
    color: cSurface
    border.color: cBorder
    border.width: 1
    z: 1000
    clip: true
    
    layer.enabled: true
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowColor: Qt.rgba(0, 0, 0, 0.35)
        shadowBlur: 1.0
        shadowVerticalOffset: 4
    }
    
    Flickable {
        anchors.fill: parent
        anchors.margins: 8
        contentWidth: contentContainer.width
        contentHeight: contentContainer.height
        boundsBehavior: Flickable.StopAtBounds
        clip: true
        
        Column {
            id: contentContainer
            width: root.width - 16
            spacing: 4
        }
    }
    
    // Helper function to position the popup relative to a button
    function positionBelow(parentItem, containerRect) {
        var buttonPos = parentItem.mapToItem(containerRect, 0, 0)
        var buttonBottom = buttonPos.y + parentItem.height
        root.x = Math.max(8, Math.min(buttonPos.x, containerRect.width - root.width - 8))
        root.y = Math.min(buttonBottom + 4, containerRect.height - root.height - 8)
    }
    
    function show() {
        root.visible = true
    }
    
    function hide() {
        root.visible = false
    }
}
