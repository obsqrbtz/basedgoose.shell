pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel

Singleton {
    id: root

    readonly property var keys: ["background", "surfaceBase", "surfaceContainer", "surfaceHigh", "border", "surfaceBorder", "foreground", "foregroundMuted", "primary", "primaryMuted", "secondary", "secondaryMuted", "info", "warning", "success", "error"]

    readonly property var fallback: ({
        background: "#0C0C0C",
        surfaceBase: "#151515",
        surfaceContainer: "#1F1F1F",
        surfaceHigh: "#2A2A2A",
        border: "#383838",
        surfaceBorder: "#242424",
        foreground: "#C8C8C8",
        foregroundMuted: "#6E6E6E",
        primary: "#5FAD5F",
        primaryMuted: "#0A190A",
        secondary: "#B89A3C",
        secondaryMuted: "#1A150A",
        info: "#7AA2F7",
        warning: "#B89A3C",
        success: "#5FAD5F",
        error: "#B85450"
    })

    property var available: []

    property var overrides: ({})

    readonly property var colors: {
        const scheme = available.find(s => s.id === Settings.colorScheme);
        const result = {};
        for (const key of keys)
            result[key] = overrides[key] ?? scheme?.colors[key] ?? null;

        for (const key of keys)
            result[key] = result[key] ?? fallback[key];
        return result;
    }

    function isDark(color: string): bool {
        return Qt.color(color).hslLightness < 0.5;
    }

    function shade(color: string, amount: real): string {
        const c = Qt.color(color);
        const out = Qt.hsla(c.hslHue, c.hslSaturation, Math.max(0, Math.min(1, c.hslLightness + amount)), 1);
        const hex = v => Math.round(v * 255).toString(16).padStart(2, "0");
        return `#${hex(out.r)}${hex(out.g)}${hex(out.b)}`;
    }

    readonly property bool edited: Object.keys(overrides).length > 0

    function setColor(key: string, value: string): bool {
        const hex = value.trim().replace(/^#/, "");
        if (!/^([0-9a-fA-F]{3}|[0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(hex))
            return false;
        overrides = Object.assign({}, overrides, { [key]: `#${hex}` });
        return true;
    }

    function resetColors(): void {
        overrides = ({});
    }

    function save(name: string): void {
        const id = name.toLowerCase().replace(/[^a-z0-9]+/g, "-").replace(/^-|-$/g, "");
        if (!id)
            return;
        writer.path = `${Settings.schemeDir}/${id}.json`;
        writer.setText(JSON.stringify(Object.assign({ name }, colors), null, 2));
        resetColors();
        Settings.colorScheme = id;
    }

    function collect(): void {
        const merged = {};
        for (const entry of [builtins, custom]) {
            for (let i = 0; i < entry.count; i++) {
                const path = entry.get(i, "filePath");
                const id = entry.get(i, "fileName").replace(/\.json$/, "");
                merged[id] = { id, path };
            }
        }
        loader.model = Object.values(merged);
    }

    Connections {
        target: Settings
        function onColorSchemeChanged(): void { root.resetColors(); }
    }

    FileView {
        id: writer
        atomicWrites: true
    }

    FolderListModel {
        id: builtins
        folder: `${Qt.resolvedUrl("../colorschemes")}`
        nameFilters: ["*.json"]
        showDirs: false
        onCountChanged: root.collect()
    }

    FolderListModel {
        id: custom
        folder: `file://${Settings.schemeDir}`
        nameFilters: ["*.json"]
        showDirs: false
        onCountChanged: root.collect()
    }

    Instantiator {
        id: loader

        delegate: FileView {
            required property var modelData
            path: modelData?.path ?? ""
            watchChanges: true
            onFileChanged: reload()
            onLoaded: root.available = root.available.filter(s => s.id !== modelData.id).concat([
                { id: modelData.id, name: JSON.parse(text()).name ?? modelData.id, colors: JSON.parse(text()) }
            ]).sort((a, b) => a.name.localeCompare(b.name))
        }

        onObjectRemoved: (index, object) => root.available = root.available.filter(s => s.id !== object.modelData.id)
    }
}
