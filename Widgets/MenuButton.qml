import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../Commons" as Commons

Rectangle {
    id: root
    
    property string icon: ""
    property string text: ""
    property int iconSize: 20
    property int textSize: 13
    property color iconColor: Commons.Theme.secondary
    property color textColor: Commons.Theme.foreground
    property color baseColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.1)
    property color hoverColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.18)
    property color pressedColor: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.25)
    property int animationDuration: 150
    
    signal clicked()
    
    implicitWidth: 200
    implicitHeight: 52
    radius: 10
    color: mouseArea.pressed ? pressedColor : (mouseArea.containsMouse ? hoverColor : baseColor)
    
    Behavior on color {
        ColorAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
    }
    
    RowLayout {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.verticalCenter: parent.verticalCenter
        anchors.leftMargin: 16
        anchors.rightMargin: 16
        spacing: 12
        
        Text {
            text: root.icon
            font.family: Commons.Theme.fontMono
            font.pixelSize: root.iconSize
            color: root.iconColor
        }
        
        Text {
            text: root.text
            Layout.fillWidth: true
            font.family: Commons.Theme.fontUI
            font.pixelSize: root.textSize
            font.weight: Font.Medium
            color: root.textColor
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        onClicked: root.clicked()
    }
}
