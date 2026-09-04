import QtQuick
import qs.Config

Item {
    id: root

    property real value: 0
    property color accent: Theme.primary
    property int barHeight: 6
    property int handleSize: 10

    signal moved(real value)

    implicitWidth: 120
    implicitHeight: Math.max(barHeight, handleSize) + 2

    Rectangle {
        anchors.verticalCenter: parent.verticalCenter
        width: parent.width
        height: root.barHeight
        radius: height / 2
        color: Theme.alpha(Theme.text, 0.15)

        Rectangle {
            width: parent.width * Math.max(0, Math.min(1, root.value))
            height: parent.height
            radius: parent.radius
            color: root.accent
        }
    }

    Rectangle {
        id: handle
        x: (parent.width - width) * Math.max(0, Math.min(1, root.value))
        anchors.verticalCenter: parent.verticalCenter
        width: root.handleSize
        height: root.handleSize
        radius: width / 2
        color: root.accent
        scale: mouse.containsMouse || mouse.pressed ? 1.3 : 1

        Behavior on scale {
            NumberAnimation { duration: Theme.animFast }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        function set(x: real): void {
            root.moved(Math.max(0, Math.min(1, x / root.width)));
        }

        onPressed: event => set(event.x)
        onPositionChanged: event => {
            if (pressed)
                set(event.x);
        }
    }
}
