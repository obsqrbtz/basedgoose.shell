import Quickshell
import Quickshell.Io
import QtQuick
import "../Commons" as Commons

Item {
    id: driveMonitor

    property var drives: []
    property var lastStats: ({})
    property real lastTime: 0

    readonly property int maxHistory: 60
    readonly property int updateInterval: Commons.Config.driveUpdateInterval

    function push(arr, val) {
        var h = arr ? arr.slice() : []
        h.push(val)
        if (h.length > driveMonitor.maxHistory) h.shift()
        return h
    }

    function formatBytes(bytes) {
        if (bytes >= 1099511627776) return (bytes / 1099511627776).toFixed(1) + " TB"
        if (bytes >= 1073741824) return (bytes / 1073741824).toFixed(1) + " GB"
        if (bytes >= 1048576) return (bytes / 1048576).toFixed(0) + " MB"
        return Math.round(bytes / 1024) + " KB"
    }

    function sectionsFrom(output) {
        var sections = {}
        var key = null
        var buf = []
        var lines = output.split("\n")
        for (var i = 0; i < lines.length; i++) {
            var m = lines[i].match(/^=([A-Z_]+)=$/)
            if (m) {
                if (key) sections[key] = buf.join("\n")
                key = m[1]
                buf = []
            } else if (key) {
                buf.push(lines[i])
            }
        }
        if (key) sections[key] = buf.join("\n")
        return sections
    }

    function mountArray(value) {
        if (!value) return []
        if (value instanceof Array) return value.filter(function(m) { return m && m !== "[SWAP]" })
        if (typeof value === "string") return value.length > 0 && value !== "[SWAP]" ? [value] : []
        return []
    }

    function collectMounts(node, out) {
        var mounts = mountArray(node.mountpoints)
        for (var i = 0; i < mounts.length; i++)
            out.push({ mount: mounts[i], device: node.path || "", fstype: node.fstype || "" })

        var children = node.children || []
        for (var j = 0; j < children.length; j++)
            collectMounts(children[j], out)
    }

    function parseDf(text) {
        var map = {}
        var lines = text.trim().split("\n")
        for (var i = 1; i < lines.length; i++) {
            var line = lines[i].trim()
            if (!line) continue
            var fields = line.split(/\s+/)
            if (fields.length < 6) continue
            var mount = fields.slice(5).join(" ")
            map[mount] = {
                filesystem: fields[0],
                total: parseFloat(fields[1]) || 0,
                used: parseFloat(fields[2]) || 0,
                available: parseFloat(fields[3]) || 0,
                usage: parseInt(fields[4], 10) || 0,
                mount: mount
            }
        }
        return map
    }

    function parseDiskstats(text) {
        var stats = {}
        var lines = text.trim().split("\n")
        for (var i = 0; i < lines.length; i++) {
            var f = lines[i].trim().split(/\s+/)
            if (f.length < 14) continue
            stats[f[2]] = {
                readBytes: (parseFloat(f[5]) || 0) * 512,
                writeBytes: (parseFloat(f[9]) || 0) * 512
            }
        }
        return stats
    }

    function previousDrive(name) {
        for (var i = 0; i < driveMonitor.drives.length; i++) {
            if (driveMonitor.drives[i].name === name)
                return driveMonitor.drives[i]
        }
        return null
    }

    function rebuild(output) {
        var sections = sectionsFrom(output)
        var lsblk = {}
        try {
            lsblk = JSON.parse((sections["LSBLK"] || "").trim())
        } catch(e) {
            driveTimer.start()
            return
        }

        var df = parseDf(sections["DF"] || "")
        var diskstats = parseDiskstats(sections["DISKSTATS"] || "")
        var now = Date.now()
        var dt = driveMonitor.lastTime > 0 ? (now - driveMonitor.lastTime) / 1000.0 : 0
        var nextStats = {}
        var nextDrives = []
        var devices = lsblk.blockdevices || []

        for (var i = 0; i < devices.length; i++) {
            var disk = devices[i]
            if (disk.type !== "disk" || disk.name.indexOf("loop") === 0 || disk.name.indexOf("zram") === 0)
                continue

            var mounts = []
            collectMounts(disk, mounts)

            var mountPoints = []
            var total = 0
            var used = 0
            for (var j = 0; j < mounts.length; j++) {
                var info = df[mounts[j].mount]
                if (!info) continue
                mountPoints.push({
                    path: mounts[j].mount,
                    device: mounts[j].device || info.filesystem,
                    fstype: mounts[j].fstype,
                    total: info.total,
                    used: info.used,
                    available: info.available,
                    usage: info.usage
                })
                total += info.total
                used += info.used
            }

            var stat = diskstats[disk.kname || disk.name] || { readBytes: 0, writeBytes: 0 }
            var previousStat = driveMonitor.lastStats[disk.kname || disk.name]
            var readSpeed = 0
            var writeSpeed = 0
            if (previousStat && dt > 0) {
                readSpeed = Math.max(0, (stat.readBytes - previousStat.readBytes) / dt / 1024)
                writeSpeed = Math.max(0, (stat.writeBytes - previousStat.writeBytes) / dt / 1024)
            }
            nextStats[disk.kname || disk.name] = stat

            var prev = previousDrive(disk.name)
            nextDrives.push({
                name: disk.name,
                model: disk.model || disk.path || disk.name,
                size: parseFloat(disk.size) || total,
                total: total,
                used: used,
                usage: total > 0 ? Math.round(used * 100 / total) : 0,
                mountPoints: mountPoints,
                readSpeed: readSpeed,
                writeSpeed: writeSpeed,
                readHistory: push(prev ? prev.readHistory : [], readSpeed),
                writeHistory: push(prev ? prev.writeHistory : [], writeSpeed)
            })
        }

        driveMonitor.lastStats = nextStats
        driveMonitor.lastTime = now
        driveMonitor.drives = nextDrives
        driveTimer.start()
    }

    Process {
        id: driveProc
        running: false
        command: ["sh", "-c", "printf '=LSBLK=\\n'; lsblk -b -J -o NAME,KNAME,PATH,TYPE,SIZE,MODEL,MOUNTPOINTS,FSTYPE,RM; printf '\\n=DF=\\n'; df -B1 -P; printf '\\n=DISKSTATS=\\n'; cat /proc/diskstats"]

        stdout: StdioCollector {
            onStreamFinished: driveMonitor.rebuild(text)
        }

        onExited: function(code) {
            if (code !== 0)
                driveTimer.start()
        }
    }

    Timer {
        id: driveTimer
        interval: driveMonitor.updateInterval
        running: false
        onTriggered: driveProc.running = true
    }

    Component.onCompleted: driveProc.running = true
}
