import QtQuick
import qs.Config

Rectangle {
    id: root

    property bool interactive: true
    property bool enabled: true
    property bool scrollable: false

    property color accent: Theme.text
    property color baseColor: "transparent"

    readonly property bool hovered: interactive && enabled && mouse.containsMouse
    readonly property bool pressed: interactive && enabled && mouse.pressed

    property alias cursorShape: mouse.cursorShape
    property alias acceptedButtons: mouse.acceptedButtons

    signal clicked(var event)
    signal rightClicked(var event)
    signal scrolled(real steps)

    implicitHeight: Theme.spacingXl
    radius: Theme.radius
    color: baseColor
    opacity: enabled ? 1 : 0.4

    Behavior on color {
        ColorAnimation { duration: Theme.animNormal }
    }

    Rectangle {
        anchors.fill: parent
        radius: parent.radius
        color: root.accent
        opacity: root.pressed ? Theme.pressedAlpha : root.hovered ? Theme.hoverAlpha : 0

        Behavior on opacity {
            NumberAnimation { duration: Theme.animFast }
        }
    }

    MouseArea {
        id: mouse
        anchors.fill: parent
        enabled: root.interactive && root.enabled
        visible: enabled
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor
        acceptedButtons: Qt.LeftButton

        onClicked: event => {
            if (event.button === Qt.RightButton)
                root.rightClicked(event);
            else
                root.clicked(event);
        }

        onWheel: event => {
            event.accepted = root.scrollable;
            if (root.scrollable)
                root.scrolled(event.angleDelta.y / 120);
        }
    }
}
