import QtQuick
import Quickshell

QtObject {
    id: root

    property string host: ""
    property string port: "9090"
    property bool active: true

    readonly property int historySize: 60
    readonly property int pollInterval: 15000

    property real cpuUsage: 0
    property var cpuHistory: []
    property real memUsed: 0
    property real memTotal: 0
    property real memUsage: 0
    property var memHistory: []
    property real netRxSpeed: 0
    property real netTxSpeed: 0
    property var netRxHistory: []
    property var netTxHistory: []
    property var drives: []

    property bool loading: false
    property bool hasError: false
    property string errorText: ""

    readonly property string _fsFilter: 'fstype!~"tmpfs|squashfs|overlay|ramfs|devtmpfs"'

    readonly property var _queries: ({
        cpu: '100-(avg(rate(node_cpu_seconds_total{mode="idle"}[1m]))*100)',
        memUsed: '(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/1073741824',
        memTotal: 'node_memory_MemTotal_bytes/1073741824',
        netRx: 'sum(rate(node_network_receive_bytes_total{device!="lo"}[1m]))/1024',
        netTx: 'sum(rate(node_network_transmit_bytes_total{device!="lo"}[1m]))/1024',
        diskSize: `node_filesystem_size_bytes{${_fsFilter}}`,
        diskAvail: `node_filesystem_avail_bytes{${_fsFilter}}`,
        diskRead: 'sum by (device)(rate(node_disk_read_bytes_total[1m]))/1024',
        diskWrite: 'sum by (device)(rate(node_disk_written_bytes_total[1m]))/1024'
    })

    readonly property int historyStep: 15

    readonly property var _rangeQueries: ({
        cpuHistory: _queries.cpu,
        memHistory: '(1-node_memory_MemAvailable_bytes/node_memory_MemTotal_bytes)*100',
        netRxHistory: _queries.netRx,
        netTxHistory: _queries.netTx
    })

    onActiveChanged: if (active)
        backfill()

    function backfill(): void {
        if (!host)
            return;

        const end = Math.floor(Date.now() / 1000);
        const start = end - historySize * historyStep;

        for (const key of Object.keys(_rangeQueries)) {
            const request = new XMLHttpRequest();
            request.onreadystatechange = () => {
                if (request.readyState !== XMLHttpRequest.DONE || request.status !== 200)
                    return;
                const samples = _parseRange(request.responseText);
                if (samples.length > 1)
                    root[key] = samples;
            };
            request.open("GET", `http://${host}:${port}/api/v1/query_range?query=${encodeURIComponent(_rangeQueries[key])}&start=${start}&end=${end}&step=${historyStep}`);
            request.send();
        }
    }

    function _parseRange(body: string): var {
        try {
            const json = JSON.parse(body);
            if (json.status !== "success" || !json.data.result.length)
                return [];
            return json.data.result[0].values.map(v => parseFloat(v[1]) || 0).slice(-historySize);
        } catch (e) {
            return [];
        }
    }

    function _push(history: var, value: real): var {
        const next = history.concat([value]);
        return next.length > historySize ? next.slice(next.length - historySize) : next;
    }

    function poll(): void {
        if (!host || loading)
            return;
        loading = true;

        const names = Object.keys(_queries);
        const results = {};
        let pending = names.length;

        for (const name of names) {
            const request = new XMLHttpRequest();
            request.onreadystatechange = () => {
                if (request.readyState !== XMLHttpRequest.DONE)
                    return;
                results[name] = request.status === 200 ? _parse(request.responseText) : null;
                if (--pending === 0)
                    _apply(results);
            };
            request.open("GET", `http://${host}:${port}/api/v1/query?query=${encodeURIComponent(_queries[name])}`);
            request.send();
        }
    }

    function _parse(body: string): var {
        try {
            const json = JSON.parse(body);
            if (json.status !== "success")
                return null;
            return json.data.result.map(r => ({ labels: r.metric ?? {}, value: parseFloat(r.value[1]) || 0 }));
        } catch (e) {
            return null;
        }
    }

    function _first(result: var): var {
        return result?.length ? result[0].value : null;
    }

    function _apply(results: var): void {
        loading = false;

        const cpu = _first(results.cpu);
        if (cpu === null) {
            hasError = true;
            errorText = results.cpu === null ? `Cannot reach ${host}:${port}` : "Reachable, but no node_exporter metrics found";
            return;
        }

        hasError = false;
        errorText = "";

        cpuUsage = cpu;
        cpuHistory = _push(cpuHistory, cpu);

        memUsed = _first(results.memUsed) ?? memUsed;
        memTotal = _first(results.memTotal) ?? memTotal;
        memUsage = memTotal > 0 ? memUsed / memTotal * 100 : 0;
        memHistory = _push(memHistory, memUsage);

        netRxSpeed = _first(results.netRx) ?? 0;
        netTxSpeed = _first(results.netTx) ?? 0;
        netRxHistory = _push(netRxHistory, netRxSpeed);
        netTxHistory = _push(netTxHistory, netTxSpeed);

        _applyDrives(results);
    }

    function _applyDrives(results: var): void {
        const baseDevice = path => (path ?? "").split("/").pop().replace(/p?\d+$/, "");

        const rate = (result, device) => (result ?? []).find(m => baseDevice(m.labels.device) === device)?.value ?? 0;
        const mounts = {};

        for (const m of results.diskSize ?? [])
            mounts[m.labels.mountpoint] = { path: m.labels.mountpoint, device: m.labels.device ?? "", fstype: m.labels.fstype ?? "", total: m.value, used: 0 };
        for (const m of results.diskAvail ?? [])
            if (mounts[m.labels.mountpoint])
                mounts[m.labels.mountpoint].used = mounts[m.labels.mountpoint].total - m.value;

        const byDevice = {};
        for (const mount of Object.values(mounts)) {
            const name = baseDevice(mount.device) || mount.path;
            if (!byDevice[name])
                byDevice[name] = { name, model: mount.device || name, total: 0, used: 0, mounts: [] };
            byDevice[name].mounts.push(Object.assign({ usage: mount.total > 0 ? mount.used / mount.total * 100 : 0 }, mount));
            byDevice[name].total += mount.total;
            byDevice[name].used += mount.used;
        }

        drives = Object.values(byDevice).map(d => Object.assign(d, {
            usage: d.total > 0 ? d.used / d.total * 100 : 0,
            readSpeed: rate(results.diskRead, d.name),
            writeSpeed: rate(results.diskWrite, d.name)
        }));
    }

    property Timer _timer: Timer {
        interval: root.pollInterval
        running: root.active && root.host !== ""
        repeat: true
        triggeredOnStart: true
        onTriggered: root.poll()
    }
}
