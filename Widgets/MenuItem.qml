import QtQuick 6.10
import QtQuick.Layouts 6.10
import "../Commons" as Commons

Rectangle {
    id: root
    
    property string icon: ""
    property string text: ""
    property int iconSize: 14
    property int textSize: 12
    property color iconColor: Commons.Theme.secondary
    property color textColor: Commons.Theme.foreground
    property color iconBackgroundColor: Qt.rgba(iconColor.r, iconColor.g, iconColor.b, 0.15)
    property color baseColor: "transparent"
    property color hoverColor: Qt.rgba(Commons.Theme.foreground.r, Commons.Theme.foreground.g, Commons.Theme.foreground.b, 0.06)
    property color borderColor: Commons.Theme.border
    property int iconBoxSize: 28
    property int iconBoxRadius: 6
    property int animationDuration: 150
    property bool showBorder: true
    
    signal clicked()
    
    implicitWidth: 200
    implicitHeight: 48
    radius: Commons.Theme.radius
    color: mouseArea.containsMouse ? hoverColor : baseColor
    border.width: showBorder ? 1 : 0
    border.color: borderColor
    
    Behavior on color {
        ColorAnimation { duration: root.animationDuration; easing.type: Easing.OutCubic }
    }
    
    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 12
        
        Rectangle {
            width: root.iconBoxSize
            height: root.iconBoxSize
            radius: root.iconBoxRadius
            color: root.iconBackgroundColor
            
            Text {
                anchors.centerIn: parent
                text: root.icon
                font.family: Commons.Theme.fontIcon
                font.pixelSize: root.iconSize
                color: root.iconColor
            }
        }
        
        Text {
            text: root.text
            font.family: Commons.Theme.fontUI
            font.pixelSize: root.textSize
            font.weight: Font.Medium
            color: root.textColor
            Layout.fillWidth: true
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
