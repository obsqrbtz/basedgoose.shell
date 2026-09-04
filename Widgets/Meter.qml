import QtQuick
import qs.Config

Rectangle {
    id: root

    property real value: 0
    property color accent: Theme.primary
    property bool warnWhenFull: true

    readonly property color activeColor: !warnWhenFull ? accent : value >= 90 ? Theme.error : value >= 75 ? Theme.warning : accent

    implicitHeight: 4
    radius: Theme.radius
    color: Theme.alpha(Theme.text, 0.1)

    Rectangle {
        width: parent.width * Math.max(0, Math.min(100, root.value)) / 100
        height: parent.height
        radius: parent.radius
        color: root.activeColor

        Behavior on width {
            NumberAnimation { duration: Theme.animSlow; easing.type: Easing.OutCubic }
        }
        Behavior on color {
            ColorAnimation { duration: Theme.animNormal }
        }
    }
}
