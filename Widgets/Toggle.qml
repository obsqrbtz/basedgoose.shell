import QtQuick
import qs.Config

Surface {
    id: root

    property bool checked: false

    signal toggled(bool checked)

    implicitWidth: 34
    implicitHeight: 18
    radius: height / 2
    baseColor: checked ? Theme.primary : Theme.alpha(Theme.text, 0.18)
    accent: Theme.text

    onClicked: {
        checked = !checked;
        toggled(checked);
    }

    Rectangle {
        width: parent.height - 4
        height: width
        radius: width / 2
        y: 2
        x: root.checked ? parent.width - width - 2 : 2
        color: root.checked ? Theme.background : Theme.text

        Behavior on x {
            NumberAnimation { duration: Theme.animNormal; easing.type: Easing.OutCubic }
        }
    }
}
