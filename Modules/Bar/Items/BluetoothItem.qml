import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "bluetooth"

    visible: Bluetooth.adapter !== null
    onClicked: popupWindow.toggle()

    Icon {
        text: !Bluetooth.powered ? Icons.bluetoothOff : Bluetooth.connected.length > 0 ? Icons.bluetoothConnected : Icons.bluetooth
        color: root.hovered ? Theme.primary : Bluetooth.connected.length > 0 ? Theme.primary : Bluetooth.powered ? Theme.text : Theme.textMuted

        Dot {
            visible: Bluetooth.connected.length > 1
        }
    }

    BluetoothPopup {
        id: popupWindow
        anchorItem: root
    }
}
