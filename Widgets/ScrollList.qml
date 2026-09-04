import QtQuick
import QtQuick.Controls
import qs.Config

ListView {
    id: root

    clip: true
    spacing: Theme.spacingXs
    boundsBehavior: Flickable.StopAtBounds
    reuseItems: true

    ScrollBar.vertical: ScrollBar {
        policy: root.contentHeight > root.height ? ScrollBar.AsNeeded : ScrollBar.AlwaysOff

        contentItem: Rectangle {
            implicitWidth: 3
            radius: width / 2
            color: Theme.alpha(Theme.text, parent.pressed ? 0.4 : 0.2)
        }
    }
}
