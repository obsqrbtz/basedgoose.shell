import QtQuick
import QtQuick.Layouts
import qs.Config

Item {
    id: root

    property var model: []
    property int currentIndex: 0

    implicitHeight: Theme.controlHeight
    implicitWidth: row.implicitWidth

    RowLayout {
        id: row
        anchors.fill: parent
        spacing: Theme.spacingXs

        Repeater {
            model: root.model

            Button {
                required property int index
                required property var modelData

                Layout.fillHeight: true
                label: modelData.label ?? modelData
                icon: modelData.icon ?? ""
                active: root.currentIndex === index
                fontSize: Theme.fontSmall
                onClicked: root.currentIndex = index
            }
        }
    }
}
