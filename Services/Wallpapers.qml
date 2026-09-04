pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Qt.labs.folderlistmodel
import qs.Config

Singleton {
    id: root

    readonly property var imageFilters: ["*.jpg", "*.jpeg", "*.png", "*.gif", "*.bmp", "*.webp", "*.avif", "*.jxl"]

    readonly property FolderListModel saved: savedModel
    readonly property FolderListModel downloaded: downloadedModel

    property alias current: persist.current

    property string backend: ""

    signal applied(string path)

    function apply(path: string): void {
        if (!backend)
            return;
        setter.exec(_command(path));
        current = path;
        applied(path);
    }

    function _command(path: string): var {
        switch (backend) {
        case "swww":
        case "awww":
            return [backend, "img", path, "--resize", Settings.wallpaperResizeMode, "--transition-type", "outer", "--transition-fps", "60"];
        default:
            return ["swaybg", "-i", path, "-m", Settings.wallpaperResizeMode === "fit" ? "fit" : "fill"];
        }
    }

    function copyToSaved(path: string): void {
        helper.exec(["cp", "-n", path, Settings.expand(Settings.wallpaperDir)]);
    }

    function remove(path: string): void {
        helper.exec(["rm", "-f", path]);
    }

    function openExternally(path: string): void {
        Quickshell.execDetached(["xdg-open", path]);
    }

    FolderListModel {
        id: savedModel
        folder: `file://${Settings.expand(Settings.wallpaperDir)}`
        nameFilters: root.imageFilters
        showDirs: false
        sortField: FolderListModel.Name
    }

    FolderListModel {
        id: downloadedModel
        folder: `file://${Settings.expand(Settings.wallpaperDownloadDir)}`
        nameFilters: root.imageFilters
        showDirs: false
        sortField: FolderListModel.Time
    }

    Process {
        id: setter
    }

    Process {
        id: helper
    }

    Process {
        running: true
        command: ["sh", "-c", "for c in swww awww swaybg; do command -v $c >/dev/null && { echo $c; break; }; done"]
        stdout: StdioCollector {
            onStreamFinished: {
                root.backend = text.trim();
                if (["swww", "awww"].includes(root.backend))
                    Quickshell.execDetached([`${root.backend}-daemon`]);
            }
        }
    }

    FileView {
        path: `${Settings.cacheDir}/wallpaper.json`
        watchChanges: true
        onFileChanged: reload()
        onAdapterUpdated: writeAdapter()
        onLoadFailed: error => {
            if (error === FileViewError.FileNotFound)
                writeAdapter();
        }

        JsonAdapter {
            id: persist
            property string current: ""
        }
    }
}
