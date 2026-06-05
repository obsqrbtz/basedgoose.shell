import Quickshell
import Quickshell.Io
import QtQuick

Item {
    id: client

    width: 0; height: 0

    property string host: ""
    property string port: "9091"
    property bool active: true

    property real cpuUsage: 0
    property var  cpuHistory: []
    property real memUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    property var  memHistory: []
    property real netRxSpeed: 0
    property real netTxSpeed: 0
    property var  netRxHistory: []
    property var  netTxHistory: []
    property var  drives: []

    property bool loading: false
    property bool hasError: false
    property string errorText: ""

    readonly property int maxHistory: 60
    readonly property int pollInterval: 15000

    function formatSpeed(kbps) {
        if (kbps >= 1024) return (kbps / 1024).toFixed(1) + " MB/s"
        if (kbps < 0.5)   return "0 KB/s"
        return kbps.toFixed(0) + " KB/s"
    }

    function push(arr, val) {
        var h = arr.slice()
        h.push(val)
        if (h.length > maxHistory) h.shift()
        return h
    }

    function poll() {
        if (!host || loading) return
        loading = true
        hasError = false
        fetchProc.command = ["sh", "-c", buildScript()]
        fetchProc.running = true
    }

    function buildScript() {
        var base = "http://" + host + ":" + port

        function enc(q) {
            return q.replace(/%/g,"%25").replace(/ /g,"%20")
                    .replace(/\{/g,"%7B").replace(/\}/g,"%7D")
                    .replace(/"/g,"%22").replace(/=/g,"%3D")
                    .replace(/\[/g,"%5B").replace(/\]/g,"%5D")
                    .replace(/\(/g,"%28").replace(/\)/g,"%29")
                    .replace(/\*/g,"%2A").replace(/!/g,"%21")
        }

        var queries = [
            ["CPU",      '100-(avg(rate(node_cpu_seconds_total{mode="idle"}[1m]))*100)'],
            ["MEM_PCT",  '100*((node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/node_memory_MemTotal_bytes)'],
            ["MEM_USED", '(node_memory_MemTotal_bytes-node_memory_MemAvailable_bytes)/1073741824'],
            ["MEM_TOTAL",'node_memory_MemTotal_bytes/1073741824'],
            ["NET_RX",   'sum(rate(node_network_receive_bytes_total{device!="lo"}[1m]))/1024'],
            ["NET_TX",   'sum(rate(node_network_transmit_bytes_total{device!="lo"}[1m]))/1024']
        ]

        queries.push(["DISK_SIZE",  'node_filesystem_size_bytes{fstype!~"tmpfs|squashfs|overlay|ramfs|devtmpfs"}'])
        queries.push(["DISK_AVAIL", 'node_filesystem_avail_bytes{fstype!~"tmpfs|squashfs|overlay|ramfs|devtmpfs"}'])
        queries.push(["DISK_READ",  'sum by (device)(rate(node_disk_read_bytes_total[1m]))/1024'])
        queries.push(["DISK_WRITE", 'sum by (device)(rate(node_disk_written_bytes_total[1m]))/1024'])

        var lines = []
        lines.push("echo '=PING='")
        lines.push("curl -sf '" + base + "/-/healthy' > /dev/null 2>&1 && echo ok || echo fail")
        for (var i = 0; i < queries.length; i++) {
            lines.push("echo '=" + queries[i][0] + "='")
            lines.push("curl -sf '" + base + "/api/v1/query?query=" + enc(queries[i][1]) + "' 2>/dev/null; echo")
        }
        return lines.join("\n")
    }

    Process {
        id: fetchProc
        running: false

        stdout: StdioCollector {
            onStreamFinished: {
                client.loading = false

                var sections = {}
                var key = null
                var buf = []
                var lines = text.split("\n")
                for (var i = 0; i < lines.length; i++) {
                    var m = lines[i].match(/^=([A-Z_]+)=$/)
                    if (m) {
                        if (key) sections[key] = buf.join("\n")
                        key = m[1]; buf = []
                    } else if (key) {
                        buf.push(lines[i])
                    }
                }
                if (key) sections[key] = buf.join("\n")

                function parseVal(json) {
                    try {
                        var r = JSON.parse(json.trim())
                        if (r.status !== "success") return null
                        var res = r.data && r.data.result
                        if (!res || !res.length) return null
                        var v = parseFloat(res[0].value[1])
                        return isNaN(v) ? null : v
                    } catch(e) { return null }
                }

                function parseMulti(json) {
                    try {
                        var r = JSON.parse(json.trim())
                        if (r.status !== "success") return []
                        var res = r.data && r.data.result
                        if (!res || !res.length) return []
                        var out = []
                        for (var i = 0; i < res.length; i++) {
                            var m = res[i]
                            var v = parseFloat(m.value[1])
                            out.push({ metric: m.metric || {}, value: isNaN(v) ? 0 : v })
                        }
                        return out
                    } catch(e) { return [] }
                }

                var ping = (sections["PING"] || "").trim()
                if (ping.indexOf("ok") === -1) {
                    client.hasError  = true
                    client.errorText = "Cannot reach " + client.host + ":" + client.port
                    pollTimer.restart(); return
                }

                var cpu = parseVal(sections["CPU"])
                if (cpu === null) {
                    client.hasError  = true
                    client.errorText = "Prometheus up but no node metrics.\nIs node_exporter running and scraped?"
                    pollTimer.restart(); return
                }

                client.hasError  = false
                client.cpuUsage  = Math.round(cpu)
                client.cpuHistory = client.push(client.cpuHistory, cpu)

                var memPct = parseVal(sections["MEM_PCT"])
                if (memPct !== null) {
                    client.memUsage   = Math.round(memPct)
                    client.memHistory = client.push(client.memHistory, memPct)
                }
                var memUsed = parseVal(sections["MEM_USED"])
                if (memUsed !== null) client.memUsed = memUsed
                var memTotal = parseVal(sections["MEM_TOTAL"])
                if (memTotal !== null) client.memTotal = memTotal

                var rx = parseVal(sections["NET_RX"])
                if (rx !== null) {
                    client.netRxSpeed   = rx
                    client.netRxHistory = client.push(client.netRxHistory, rx)
                }
                var tx = parseVal(sections["NET_TX"])
                if (tx !== null) {
                    client.netTxSpeed   = tx
                    client.netTxHistory = client.push(client.netTxHistory, tx)
                }

                    var sizes  = parseMulti(sections["DISK_SIZE"] || "")
                    var avails = parseMulti(sections["DISK_AVAIL"] || "")
                    var reads  = parseMulti(sections["DISK_READ"] || "")
                    var writes = parseMulti(sections["DISK_WRITE"] || "")

                    var mountMap = {}
                    for (var i = 0; i < sizes.length; i++) {
                        var m = sizes[i]
                        var mount = m.metric.mountpoint || m.metric.mount || ""
                        if (!mount) continue
                        mountMap[mount] = mountMap[mount] || { path: mount }
                        mountMap[mount].total = m.value
                        mountMap[mount].device = m.metric.device || m.metric.dev || ""
                        mountMap[mount].fstype = m.metric.fstype || ""
                    }
                    for (var j = 0; j < avails.length; j++) {
                        var a = avails[j]
                        var mountA = a.metric.mountpoint || a.metric.mount || ""
                        if (!mountA) continue
                        mountMap[mountA] = mountMap[mountA] || { path: mountA }
                        mountMap[mountA].available = a.value
                        mountMap[mountA].used = (mountMap[mountA].total || 0) - a.value
                    }

                    function basenameDevice(dev) {
                        if (!dev) return ""
                        var b = dev.split('/').pop()
                        return b.replace(/p?\d+$/, '')
                    }

                    var readMap = {}
                    for (var r = 0; r < reads.length; r++) {
                        var item = reads[r]
                        var dev = item.metric.device || item.metric.name || ""
                        var base = basenameDevice(dev)
                        readMap[base] = item.value
                    }
                    var writeMap = {}
                    for (var w = 0; w < writes.length; w++) {
                        var itemw = writes[w]
                        var devw = itemw.metric.device || itemw.metric.name || ""
                        var basew = basenameDevice(devw)
                        writeMap[basew] = itemw.value
                    }

                    var nextDrives = []
                    for (var k in mountMap) {
                        var info = mountMap[k]
                        var dev = info.device || ""
                        var base = basenameDevice(dev)
                        var readSpeed = readMap[base] || 0
                        var writeSpeed = writeMap[base] || 0
                        var prev = null
                        for (var p = 0; p < client.drives.length; p++) if (client.drives[p].name === base) { prev = client.drives[p]; break }

                        nextDrives.push({
                            name: base || info.device || info.path,
                            model: info.device || base || info.path,
                            size: info.total || 0,
                            total: info.total || 0,
                            used: info.used || 0,
                            usage: (info.total && info.total > 0) ? Math.round((info.used || 0) * 100 / info.total) : 0,
                            mountPoints: [{ path: info.path, device: info.device, fstype: info.fstype, total: info.total || 0, used: info.used || 0 }],
                            readSpeed: readSpeed,
                            writeSpeed: writeSpeed,
                            readHistory: client.push(prev ? prev.readHistory : [], readSpeed),
                            writeHistory: client.push(prev ? prev.writeHistory : [], writeSpeed)
                        })
                    }

                    client.drives = nextDrives

                pollTimer.restart()
            }
        }

        onExited: function(code) {
            if (code !== 0) {
                client.loading   = false
                client.hasError  = true
                client.errorText = "Process error (exit " + code + ")"
                pollTimer.restart()
            }
        }
    }

    Timer {
        id: pollTimer
        interval: client.pollInterval
        repeat: false
        running: false
        onTriggered: { if (client.active && client.host) client.poll() }
    }

    onActiveChanged: { if (active && host) poll() }
    Component.onCompleted: { if (active && host) poll() }
}
