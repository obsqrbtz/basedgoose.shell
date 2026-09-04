import QtQuick
import qs.Config

Grid {
    id: root

    property var modules: []

    rows: Settings.barVertical ? -1 : 1
    columns: Settings.barVertical ? 1 : -1
    flow: Settings.barVertical ? Grid.TopToBottom : Grid.LeftToRight
    spacing: Theme.spacingXs
    horizontalItemAlignment: Grid.AlignHCenter
    verticalItemAlignment: Grid.AlignVCenter

    Repeater {
        model: root.modules

        Loader {
            required property string modelData

            source: `Items/${modelData.charAt(0).toUpperCase()}${modelData.slice(1)}Item.qml`
            onStatusChanged: {
                if (status === Loader.Error)
                    console.warn(`Bar: no module named "${modelData}"`);
            }
        }
    }
}
