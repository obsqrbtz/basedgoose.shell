import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../Services" as Services

Rectangle {
    id: root
    
    property var notificationCenter
    
    readonly property var notifs: Services.Notifs
    readonly property int unreadCount: notifs.activeNotifications.length
    readonly property bool hasDnd: notifs.dnd
    
    implicitWidth: 32
    implicitHeight: 28
    radius: 14
    
    color: mouseArea.containsMouse ? 
           Qt.rgba(Services.Theme.secondary.r, Services.Theme.secondary.g, Services.Theme.secondary.b, 0.15) :
           "transparent"
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Rectangle {
        visible: root.unreadCount > 0 && !root.hasDnd
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 2
        
        width: Math.max(16, badgeText.implicitWidth + 6)
        height: 16
        radius: 8
        
        color: Services.Theme.secondary
        border.width: 2
        border.color: Services.Theme.background
        
        Text {
            id: badgeText
            anchors.centerIn: parent
            text: root.unreadCount > 99 ? "99+" : root.unreadCount
            font.pixelSize: 8
            font.weight: Font.Bold
            font.family: "Inter"
            color: Services.Theme.background
        }
    }
    
    Rectangle {
        visible: root.hasDnd
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 2
        
        width: 12
        height: 12
        radius: 6
        
        color: Services.Theme.error
        border.width: 2
        border.color: Services.Theme.background
        
        Text {
            anchors.centerIn: parent
            text: "󰂛"
            font.family: "Material Design Icons"
            font.pixelSize: 7
            color: Services.Theme.background
        }
    }
    
    Text {
        anchors.centerIn: parent
        text: root.hasDnd ? "󰂛" : (root.unreadCount > 0 ? "󰵅" : "󰂚")
        font.family: "Material Design Icons"
        font.pixelSize: 16
        color: mouseArea.containsMouse ? Services.Theme.secondary : Services.Theme.foreground
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (root.notificationCenter) {
                root.notificationCenter.shouldShow = !root.notificationCenter.shouldShow
            }
        }
    }
    
    SequentialAnimation on scale {
        running: root.unreadCount > 0 && !root.hasDnd
        loops: 1
        
        NumberAnimation {
            from: 1.0
            to: 1.15
            duration: 150
            easing.type: Easing.OutQuad
        }
        NumberAnimation {
            from: 1.15
            to: 1.0
            duration: 150
            easing.type: Easing.InQuad
        }
    }
}


