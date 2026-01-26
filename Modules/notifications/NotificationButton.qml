import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

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
           Commons.Theme.background :
           "transparent"
    
    Behavior on color {
        ColorAnimation { duration: 150 }
    }
    
    Widgets.Badge {
        visible: root.unreadCount > 0 && !root.hasDnd
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 2
        count: root.unreadCount
        badgeColor: Commons.Theme.secondary
        textColor: Commons.Theme.background
        borderColor: Commons.Theme.surfaceBase
    }
    
    Widgets.Badge {
        visible: root.hasDnd
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.rightMargin: 2
        anchors.topMargin: 2
        count: 1
        icon: "󰂛"
        badgeColor: Commons.Theme.error
        textColor: Commons.Theme.background
        borderColor: Commons.Theme.surfaceBase
        minWidth: 12
        badgeHeight: 12
    }
    
    Text {
        anchors.centerIn: parent
        text: root.hasDnd ? "󰂛" : (root.unreadCount > 0 ? "󰵅" : "󰂚")
        font.family: Commons.Theme.fontIcon
        font.pixelSize: 16
        color: mouseArea.containsMouse ? Commons.Theme.secondary : Commons.Theme.foreground
        
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


