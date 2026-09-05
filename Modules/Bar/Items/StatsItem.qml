import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "stats"

    spacing: Theme.spacingSm
    onClicked: popupWindow.toggle()

    Reading {
        icon: Icons.cpu
        value: SystemUsage.cpuUsage
        text: Format.percent(SystemUsage.cpuUsage)
    }

    Reading {
        icon: Icons.memory
        value: SystemUsage.memUsage
        text: `${SystemUsage.memUsed.toFixed(1)}G`
    }

    StatsPopup {
        id: popupWindow
        anchorItem: root
    }

    component Reading: Row {
        id: reading

        property string icon: ""
        property real value: 0
        property alias text: label.text

        spacing: Theme.spacingXs

        Icon {
            anchors.verticalCenter: parent.verticalCenter
            text: reading.icon
            font.pixelSize: Theme.iconSmall
            color: reading.value >= 90 ? Theme.error : reading.value >= 75 ? Theme.warning : Theme.textMuted
        }

        StyledText {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            font.pixelSize: Theme.fontSmall
            color: root.hovered ? Theme.primary : Theme.text
        }
    }
}
