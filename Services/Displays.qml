pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import qs.Config

Singleton {
    id: root

    property var outputs: []

    property var draft: []

    property bool loading: false
    property string error: ""

    readonly property bool hasChanges: JSON.stringify(outputs) !== JSON.stringify(draft)

    readonly property string configPath: Settings.outputConfigPath || Compositor.defaultOutputConfigPath

    function refresh(): void {
        if (!loading)
            reader.running = true;
    }

    function edit(name: string, changes: var): void {
        draft = draft.map(o => o.name === name ? Object.assign({}, o, changes) : o);
    }

    function discard(): void {
        draft = JSON.parse(JSON.stringify(outputs));
    }

    function arrangeHorizontally(): void {
        let x = 0;
        const ordered = draft.filter(o => o.enabled).sort((a, b) => a.name.localeCompare(b.name));
        for (const output of ordered) {
            edit(output.name, { x, y: 0 });
            x += Math.round(output.width / output.scale);
        }
    }

    function apply(): void {
        if (!hasChanges)
            return;
        const args = [];
        for (const output of draft) {
            args.push("--output", output.name);
            if (!output.enabled) {
                args.push("--off");
                continue;
            }
            const mirrored = output.mirror ? draft.find(o => o.name === output.mirror) : null;
            args.push("--on",
                      "--mode", `${output.width}x${output.height}@${output.refresh}Hz`,
                      "--pos", `${mirrored ? mirrored.x : output.x},${mirrored ? mirrored.y : output.y}`,
                      "--scale", String(output.scale),
                      "--transform", output.transform);
        }
        applier.exec(["wlr-randr"].concat(args));
    }

    function persist(): void {
        if (!configPath)
            return;
        writer.path = Settings.expand(configPath);
        writer.setText(Compositor.renderOutputConfig(outputs));
        Compositor.reloadConfig();
    }

    function _parse(json: string): void {
        let parsed;
        try {
            parsed = JSON.parse(json);
        } catch (e) {
            error = "Could not read outputs from wlr-randr";
            return;
        }

        error = "";
        outputs = parsed.map(o => {
            const modes = (o.modes ?? []).map(m => ({
                width: m.width,
                height: m.height,
                refresh: Math.round(m.refresh * 1000) / 1000,
                preferred: !!m.preferred,
                current: !!m.current
            }));
            const active = modes.find(m => m.current) ?? modes.find(m => m.preferred) ?? modes[0] ?? { width: 1920, height: 1080, refresh: 60 };

            return {
                name: o.name,
                description: o.description ?? o.name,
                enabled: o.enabled !== false,
                modes,
                width: active.width,
                height: active.height,
                refresh: active.refresh,
                x: o.position?.x ?? 0,
                y: o.position?.y ?? 0,
                scale: o.scale > 0 ? o.scale : 1,
                transform: o.transform ?? "normal",
                mirror: ""
            };
        });

        const atPosition = {};
        for (const output of outputs.filter(o => o.enabled)) {
            const key = `${output.x},${output.y}`;
            if (atPosition[key])
                output.mirror = atPosition[key];
            else
                atPosition[key] = output.name;
        }

        discard();
    }

    Process {
        id: reader
        command: ["wlr-randr", "--json"]
        onRunningChanged: root.loading = running
        stdout: StdioCollector {
            onStreamFinished: root._parse(text)
        }
        onExited: code => {
            if (code !== 0)
                root.error = "wlr-randr is not available";
        }
    }

    Process {
        id: applier
        onExited: code => {
            if (code !== 0)
                root.error = "Failed to apply the new layout";
            refreshTimer.restart();
        }
    }

    FileView {
        id: writer
        atomicWrites: true
    }

    Timer {
        id: refreshTimer
        interval: 500
        onTriggered: root.refresh()
    }

    Component.onCompleted: refresh()
}
