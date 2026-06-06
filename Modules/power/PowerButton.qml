import QtQuick
import "../../Commons" as Commons

Item {
    id: root
    
    signal clicked()
    
    property var barWindow
    property var powerMenuPopup
    property bool isVertical: false
    
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: isVertical ? 28 : Commons.Theme.iconSize + Commons.Config.componentPadding * 2
    implicitHeight: Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: Commons.Theme.radiusLg
        color: Commons.Theme.primary
        opacity: isHovered ? Commons.Theme.stateLayerHover : 0.0
        Behavior on opacity { NumberAnimation { duration: Commons.Theme.animNormal } }
    }

    Text {
        id: powerIcon
        anchors.centerIn: parent
        text: "\udb81\udc25"
        font.family: Commons.Theme.fontIcon
        font.pixelSize: Commons.Theme.iconSize
        color: root.isHovered ? Commons.Theme.secondary : Commons.Theme.foreground

        Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        
        onClicked: {
            if (root.powerMenuPopup && root.barWindow) {
                if (!root.powerMenuPopup.shouldShow) {
                    root.powerMenuPopup.positionNear(root, root.barWindow)
                }
                root.powerMenuPopup.shouldShow = !root.powerMenuPopup.shouldShow
            }
            root.clicked()
        }
    }
}
