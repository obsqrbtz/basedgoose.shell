pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property int historySize: 60
    property int watchers: 0
    readonly property int interval: watchers > 0 ? 500 : 2000
    readonly property int driveInterval: 5000

    function watch(): void {
        watchers++;
    }

    function unwatch(): void {
        watchers = Math.max(0, watchers - 1);
    }

    property real cpuUsage: 0
    property var cpuHistory: []

    property real memUsed: 0
    property real memTotal: 0
    readonly property real memUsage: memTotal > 0 ? memUsed / memTotal * 100 : 0
    property var memHistory: []

    property real netRxSpeed: 0
    property real netTxSpeed: 0
    property var netRxHistory: []
    property var netTxHistory: []

    property var drives: []

    readonly property bool loading: false
    readonly property bool hasError: false
    readonly property string errorText: ""

    function _push(history: var, value: real): var {
        const next = history.concat([value]);
        return next.length > historySize ? next.slice(next.length - historySize) : next;
    }

    property var _lastCpu: null

    function _readCpu(text: string): void {
        const fields = text.split("\n")[0].trim().split(/\s+/).slice(1).map(Number);
        const total = fields.reduce((a, b) => a + b, 0);
        const idle = fields[3] + (fields[4] ?? 0);

        if (_lastCpu) {
            const dTotal = total - _lastCpu.total;
            const dIdle = idle - _lastCpu.idle;
            if (dTotal > 0) {
                cpuUsage = Math.max(0, Math.min(100, (1 - dIdle / dTotal) * 100));
                cpuHistory = _push(cpuHistory, cpuUsage);
            }
        }
        _lastCpu = { total, idle };
    }

    function _readMemory(text: string): void {
        const kb = {};
        for (const line of text.split("\n")) {
            const [key, value] = line.split(":");
            if (value)
                kb[key] = parseFloat(value);
        }
        const toGib = v => v / 1024 / 1024;
        memTotal = toGib(kb.MemTotal ?? 0);
        memUsed = toGib((kb.MemTotal ?? 0) - (kb.MemAvailable ?? 0));
        memHistory = _push(memHistory, memUsage);
    }

    readonly property var _ignoredInterfaces: /^(lo|veth|docker|virbr|br-|tun|tap)/

    property var _lastNet: null

    function _readNetwork(text: string): void {
        let rx = 0, tx = 0;
        for (const line of text.split("\n").slice(2)) {
            const [name, rest] = line.split(":");
            if (!rest || _ignoredInterfaces.test(name.trim()))
                continue;
            const fields = rest.trim().split(/\s+/).map(Number);
            rx += fields[0];
            tx += fields[8];
        }

        const now = Date.now();
        if (_lastNet) {
            const dt = (now - _lastNet.time) / 1000;
            if (dt > 0) {
                netRxSpeed = Math.max(0, (rx - _lastNet.rx) / dt / 1024);
                netTxSpeed = Math.max(0, (tx - _lastNet.tx) / dt / 1024);
                netRxHistory = _push(netRxHistory, netRxSpeed);
                netTxHistory = _push(netTxHistory, netTxSpeed);
            }
        }
        _lastNet = { rx, tx, time: now };
    }

    property var _lastDiskStats: ({})
    property real _lastDiskTime: 0

    function _readDrives(text: string): void {
        const sections = {};
        let key = null;
        for (const line of text.split("\n")) {
            const marker = line.match(/^=([A-Z]+)=$/);
            if (marker)
                sections[key = marker[1]] = [];
            else if (key)
                sections[key].push(line);
        }

        let block;
        try {
            block = JSON.parse(sections.LSBLK.join("\n"));
        } catch (e) {
            return;
        }

        const usage = {};
        for (const line of (sections.DF ?? []).slice(1)) {
            const f = line.trim().split(/\s+/);
            if (f.length >= 6)
                usage[f.slice(5).join(" ")] = { total: +f[1], used: +f[2], usage: parseInt(f[4]) || 0 };
        }

        const io = {};
        for (const line of sections.DISKSTATS ?? []) {
            const f = line.trim().split(/\s+/);
            if (f.length >= 14)
                io[f[2]] = { read: +f[5] * 512, write: +f[9] * 512 };
        }

        const now = Date.now();
        const dt = _lastDiskTime > 0 ? (now - _lastDiskTime) / 1000 : 0;
        const nextStats = {};

        drives = (block.blockdevices ?? []).filter(d => d.type === "disk" && !/^(loop|zram)/.test(d.name)).map(disk => {
            const mounts = [];
            (function walk(node) {
                for (const path of [].concat(node.mountpoints ?? []).filter(m => m && m !== "[SWAP]"))
                    if (usage[path])
                        mounts.push(Object.assign({ path, fstype: node.fstype ?? "" }, usage[path]));
                (node.children ?? []).forEach(walk);
            })(disk);

            const kname = disk.kname ?? disk.name;
            const stat = io[kname] ?? { read: 0, write: 0 };
            const previous = _lastDiskStats[kname];
            nextStats[kname] = stat;

            const total = mounts.reduce((a, m) => a + m.total, 0);
            const used = mounts.reduce((a, m) => a + m.used, 0);
            const rate = field => previous && dt > 0 ? Math.max(0, (stat[field] - previous[field]) / dt / 1024) : 0;

            return {
                name: disk.name,
                model: disk.model ?? disk.path ?? disk.name,
                total,
                used,
                usage: total > 0 ? used / total * 100 : 0,
                mounts,
                readSpeed: rate("read"),
                writeSpeed: rate("write")
            };
        });

        _lastDiskStats = nextStats;
        _lastDiskTime = now;
    }

    FileView {
        id: cpuFile
        path: "/proc/stat"
        onLoaded: root._readCpu(text())
    }

    FileView {
        id: memFile
        path: "/proc/meminfo"
        onLoaded: root._readMemory(text())
    }

    FileView {
        id: netFile
        path: "/proc/net/dev"
        onLoaded: root._readNetwork(text())
    }

    Process {
        id: driveProc
        command: ["sh", "-c", "printf '=LSBLK=\\n'; lsblk -b -J -o NAME,KNAME,PATH,TYPE,SIZE,MODEL,MOUNTPOINTS,FSTYPE; printf '=DF=\\n'; df -B1 -P; printf '=DISKSTATS=\\n'; cat /proc/diskstats"]
        stdout: StdioCollector {
            onStreamFinished: root._readDrives(text)
        }
    }

    Timer {
        interval: root.interval
        running: true
        repeat: true
        triggeredOnStart: true
        onTriggered: {
            cpuFile.reload();
            memFile.reload();
            netFile.reload();
        }
    }

    Timer {
        interval: root.driveInterval
        running: root.watchers > 0
        repeat: true
        triggeredOnStart: true
        onTriggered: if (!driveProc.running)
            driveProc.running = true
    }
}
