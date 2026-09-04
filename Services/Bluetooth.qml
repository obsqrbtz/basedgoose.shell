pragma Singleton

import Quickshell
import Quickshell.Bluetooth

Singleton {
    id: root

    readonly property BluetoothAdapter adapter: Bluetooth.defaultAdapter
    readonly property bool powered: adapter?.enabled ?? false
    readonly property bool discovering: adapter?.discovering ?? false

    readonly property list<BluetoothDevice> devices: Bluetooth.devices.values
    readonly property list<BluetoothDevice> paired: devices.filter(d => d.paired || d.trusted)
    readonly property list<BluetoothDevice> connected: devices.filter(d => d.connected)

    readonly property string statusText: {
        if (!adapter)
            return "No adapter";
        if (!powered)
            return "Bluetooth off";
        if (connected.length === 1)
            return connected[0].name;
        if (connected.length > 1)
            return `${connected.length} devices`;
        return "Not connected";
    }

    function activate(device: BluetoothDevice): void {
        if (device.connected)
            device.disconnect();
        else if (device.paired || device.trusted)
            device.connect();
        else
            device.pair();
    }

    function statusOf(device: BluetoothDevice): string {
        if (device.pairing)
            return "Pairing…";
        if (device.connected)
            return device.batteryAvailable ? `Connected · ${Math.round(device.battery * 100)}%` : "Connected";
        return device.paired ? "Paired" : "Available";
    }

    function togglePower(): void {
        if (adapter)
            adapter.enabled = !adapter.enabled;
    }

    function setDiscovering(enabled: bool): void {
        if (adapter && powered)
            adapter.discovering = enabled;
    }
}
