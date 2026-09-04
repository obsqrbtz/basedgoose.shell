pragma Singleton

import Quickshell
import Quickshell.Io

Singleton {
    id: root

    readonly property string tool: _tool
    readonly property bool available: tool !== ""

    property string _tool: ""
    property var _callback: null

    function pickDirectory(title: string, callback: var): void {
        if (!available)
            return;
        _callback = callback;
        picker.command = tool === "zenity" ? ["zenity", "--file-selection", "--directory", "--title", title] : ["yad", "--file", "--directory", "--title", title];
        picker.running = true;
    }

    function pickFile(title: string, callback: var): void {
        if (!available)
            return;
        _callback = callback;
        picker.command = tool === "zenity" ? ["zenity", "--file-selection", "--title", title] : ["yad", "--file", "--title", title];
        picker.running = true;
    }

    Process {
        id: detect
        running: true
        command: ["sh", "-c", "command -v zenity >/dev/null && echo zenity || (command -v yad >/dev/null && echo yad)"]
        stdout: StdioCollector {
            onStreamFinished: root._tool = text.trim()
        }
    }

    Process {
        id: picker
        stdout: StdioCollector {
            onStreamFinished: {
                const path = text.trim();
                if (path && root._callback)
                    root._callback(path);
                root._callback = null;
            }
        }
    }
}
