pragma Singleton

import QtQuick 6.10
import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string userDir: "$HOME/.config/basedgoose.shell/colorschemes"
    readonly property string repoDir: Qt.resolvedUrl("../colorschemes").toString().replace(/^file:\/\//, "")

    property bool ready: false

    readonly property var paletteKeys: [
        "background", "surfaceBase", "surfaceContainer", "border", "surfaceBorder",
        "foreground", "foregroundMuted", "primary", "primaryMuted", "secondary",
        "secondaryMuted", "info", "warning", "success", "error"
    ]

    readonly property var defaultColors: ({
        "background": "#0C0C0C",
        "surfaceBase": "#111111",
        "surfaceContainer": "#181818",
        "border": "#2A2A2A",
        "surfaceBorder": "#222222",
        "foreground": "#C8C8C8",
        "foregroundMuted": "#525252",
        "primary": "#5FAD5F",
        "primaryMuted": "#0A190A",
        "secondary": "#B89A3C",
        "secondaryMuted": "#1A150A",
        "info": "#7AA2F7",
        "warning": "#B89A3C",
        "success": "#5FAD5F",
        "error": "#B85450"
    })

    property var colors: defaultColors

    property var available: []

    property string activeScheme: ConfigService.initialized && ConfigService.colorScheme
                                  ? ConfigService.colorScheme : "based-goose"

    onActiveSchemeChanged: applyScheme(activeScheme)

    Component.onCompleted: reload()

    function reload() {
        loadProc.running = false
        loadProc.running = true
    }

    function findScheme(file) {
        for (var i = 0; i < available.length; i++) {
            if (available[i].file === file)
                return available[i]
        }
        return null
    }

    function applyScheme(file) {
        var entry = findScheme(file)
        if (!entry)
            return
        var merged = {}
        for (var k = 0; k < paletteKeys.length; k++) {
            var key = paletteKeys[k]
            merged[key] = entry.colors[key] !== undefined ? entry.colors[key] : defaultColors[key]
        }
        colors = merged
    }

    function setScheme(file) {
        if (typeof ConfigService.setColorScheme === "function")
            ConfigService.setColorScheme(file)
    }

    function setColor(key, value) {
        var next = {}
        for (var k = 0; k < paletteKeys.length; k++) {
            var pk = paletteKeys[k]
            next[pk] = colors[pk]
        }
        next[key] = value
        colors = next
    }

    function resetScheme() {
        applyScheme(activeScheme)
    }

    function slugify(name) {
        return name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-+|-+$/g, "")
    }

    function saveScheme(displayName) {
        var slug = slugify(displayName)
        if (slug.length === 0)
            return
        var obj = { "name": displayName }
        for (var k = 0; k < paletteKeys.length; k++) {
            var key = paletteKeys[k]
            obj[key] = "" + colors[key]
        }
        var json = JSON.stringify(obj, null, 2)
        var escaped = json.replace(/%/g, "%%").replace(/'/g, "'\"'\"'")
        saveProc.pendingScheme = slug
        saveProc.command = ["sh", "-c",
            "mkdir -p " + root.userDir + " && printf '%s' '" + escaped + "' > " + root.userDir + "/" + slug + ".json"]
        saveProc.running = false
        saveProc.running = true
    }

    Process {
        id: loadProc
        command: ["sh", "-c",
            'DIR="' + root.userDir + '"; REPO="' + root.repoDir + '"; ' +
            'mkdir -p "$DIR"; ' +
            'for f in "$REPO"/*.json; do [ -e "$f" ] || continue; b=$(basename "$f"); [ -e "$DIR/$b" ] || cp "$f" "$DIR/$b"; done; ' +
            'first=1; printf "["; ' +
            'for f in "$DIR"/*.json; do [ -e "$f" ] || continue; ' +
            '[ $first -eq 1 ] || printf ","; first=0; ' +
            'printf "{\\"file\\":\\"%s\\",\\"data\\":" "$(basename "$f" .json)"; ' +
            'cat "$f"; printf "}"; done; printf "]"']
        stdout: StdioCollector {
            onStreamFinished: {
                var list = []
                try {
                    var arr = JSON.parse((text || "").trim() || "[]")
                    for (var i = 0; i < arr.length; i++) {
                        var entry = arr[i]
                        if (!entry || !entry.data)
                            continue
                        list.push({
                            file: entry.file,
                            name: entry.data.name || entry.file,
                            colors: entry.data
                        })
                    }
                } catch (e) {
                    console.error("[ThemeService] Failed to parse schemes:", e)
                }
                root.available = list
                root.applyScheme(root.activeScheme)
                root.ready = true
                console.log("[ThemeService] Loaded", list.length, "schemes; active:", root.activeScheme)
            }
        }
    }

    Process {
        id: saveProc
        property string pendingScheme: ""
        running: false
        stdout: StdioCollector {
            onStreamFinished: {
                var target = saveProc.pendingScheme
                root.reload()
                if (target.length > 0)
                    root.setScheme(target)
            }
        }
    }
}
