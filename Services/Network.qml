pragma Singleton

import Quickshell
import Quickshell.Networking

Singleton {
    id: root

    readonly property list<NetworkDevice> devices: Networking.devices.values

    readonly property WifiDevice wifiDevice: devices.find(d => d.type === DeviceType.Wifi) ?? null

    readonly property var wiredDevices: devices.filter(d => d.type === DeviceType.Wired)
    readonly property WiredDevice wiredDevice: wiredDevices.find(d => d.connected) ?? wiredDevices[0] ?? null

    readonly property bool wifiAvailable: wifiDevice !== null
    readonly property bool wifiEnabled: Networking.wifiEnabled

    readonly property bool ethernetConnected: wiredDevices.some(d => d.connected)
    readonly property WifiNetwork activeWifi: wifiDevice?.networks.values.find(n => n.connected) ?? null
    readonly property bool wifiConnected: activeWifi !== null

    readonly property bool connected: ethernetConnected || wifiConnected
    readonly property int signalStrength: Math.round((activeWifi?.signalStrength ?? 0) * 100)

    readonly property var networks: {
        const seen = {};
        for (const n of wifiDevice?.networks.values ?? [])
            if (!seen[n.name] || n.signalStrength > seen[n.name].signalStrength)
                seen[n.name] = n;
        return Object.values(seen).sort((a, b) => b.signalStrength - a.signalStrength);
    }

    readonly property string statusText: {
        if (ethernetConnected)
            return wifiConnected ? `Wired · ${activeWifi.name}` : "Wired";
        if (wifiConnected)
            return activeWifi.name;
        if (!wifiAvailable && wiredDevices.length === 0)
            return "No network devices";
        return wifiEnabled ? "Disconnected" : "Wi-Fi off";
    }

    function deviceStatus(device: var): string {
        return device ? ConnectionState.toString(device.state) : "";
    }

    readonly property bool busy: networks.some(n => n.stateChanging)

    function setWifiEnabled(enabled: bool): void {
        Networking.wifiEnabled = enabled;
    }

    function setScanning(enabled: bool): void {
        if (wifiDevice)
            wifiDevice.scannerEnabled = enabled;
    }

    function requiresPassword(network: WifiNetwork): bool {
        return !network.known && [WifiSecurityType.WpaPsk, WifiSecurityType.Wpa2Psk, WifiSecurityType.Sae].includes(network.security);
    }

    function securityName(network: WifiNetwork): string {
        return network.security === WifiSecurityType.None ? "Open" : WifiSecurityType.toString(network.security);
    }

    function activate(network: WifiNetwork): bool {
        if (network.connected)
            network.disconnect();
        else if (requiresPassword(network))
            return false;
        else
            network.connect();
        return true;
    }
}
