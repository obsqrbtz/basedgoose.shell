import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "network"

    onClicked: popupWindow.toggle()

    Icon {
        text: Network.ethernetConnected ? Icons.ethernet : Network.wifiEnabled ? Icons.wifiLevel(Network.signalStrength) : Icons.wifiOff
        color: root.hovered ? Theme.primary : Network.connected ? Theme.text : Theme.textMuted
    }

    NetworkPopup {
        id: popupWindow
        anchorItem: root
    }
}
