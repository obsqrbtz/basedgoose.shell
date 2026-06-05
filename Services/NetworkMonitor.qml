import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: networkMonitor

    property real rxSpeed: 0.0
    property real txSpeed: 0.0
    property var rxHistory: []
    property var txHistory: []

    property real lastRxBytes: -1
    property real lastTxBytes: -1
    property real lastTime: 0

    readonly property int maxHistory: 60
    readonly property int updateInterval: 2000

    function formatSpeed(kbps) {
        if (kbps >= 1024) return (kbps / 1024).toFixed(1) + " MB/s"
        if (kbps < 0.5) return "0 KB/s"
        return kbps.toFixed(0) + " KB/s"
    }

    Process {
        id: netProc
        running: false
        command: ["sh", "-c", "cat /proc/net/dev"]

        stdout: StdioCollector {
            onStreamFinished: {
                var lines = text.trim().split('\n');
                var totalRx = 0, totalTx = 0;
                for (var i = 2; i < lines.length; i++) {
                    var line = lines[i].trim();
                    if (!line) continue;
                    var colon = line.indexOf(':');
                    if (colon < 0) continue;
                    var iface = line.substring(0, colon).trim();
                    if (iface === 'lo'
                        || iface.indexOf('veth') === 0
                        || iface.indexOf('docker') === 0
                        || iface.indexOf('virbr') === 0
                        || iface.indexOf('br-') === 0) continue;
                    var fields = line.substring(colon + 1).trim().split(/\s+/);
                    totalRx += parseFloat(fields[0]) || 0;
                    totalTx += parseFloat(fields[8]) || 0;
                }

                var now = Date.now();
                if (networkMonitor.lastRxBytes >= 0 && networkMonitor.lastTime > 0) {
                    var dt = (now - networkMonitor.lastTime) / 1000.0;
                    if (dt > 0) {
                        networkMonitor.rxSpeed = Math.max(0, (totalRx - networkMonitor.lastRxBytes) / dt / 1024);
                        networkMonitor.txSpeed = Math.max(0, (totalTx - networkMonitor.lastTxBytes) / dt / 1024);
                    }

                    var rh = networkMonitor.rxHistory.slice();
                    rh.push(networkMonitor.rxSpeed);
                    if (rh.length > networkMonitor.maxHistory) rh.shift();
                    networkMonitor.rxHistory = rh;

                    var th = networkMonitor.txHistory.slice();
                    th.push(networkMonitor.txSpeed);
                    if (th.length > networkMonitor.maxHistory) th.shift();
                    networkMonitor.txHistory = th;
                }

                networkMonitor.lastRxBytes = totalRx;
                networkMonitor.lastTxBytes = totalTx;
                networkMonitor.lastTime = now;

                netTimer.start();
            }
        }
    }

    Timer {
        id: netTimer
        interval: networkMonitor.updateInterval
        running: false
        onTriggered: netProc.running = true
    }

    Component.onCompleted: netProc.running = true
}
