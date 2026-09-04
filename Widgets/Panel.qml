import QtQuick
import QtQuick.Effects
import qs.Config

Rectangle {
    id: root

    property int padding: Theme.spacingMd
    property bool shadow: true
    default property alias content: container.data

    color: Theme.background
    radius: Theme.radiusPanel
    border.width: 1
    border.color: Theme.border

    layer.enabled: shadow
    layer.effect: MultiEffect {
        shadowEnabled: true
        shadowVerticalOffset: 4
        shadowBlur: 0.6
        shadowOpacity: 0.35
    }

    Item {
        id: container
        anchors.fill: parent
        anchors.margins: root.padding
    }
}
