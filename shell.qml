//@ pragma UseQApplication

import QtQml
import Quickshell
import Quickshell.Io
import qs.Modules.Bar
import qs.Modules.Popups
import qs.Modules.Overlays
import qs.Modules.Layers

ShellRoot {
    Bar {}

    LauncherWindow {}
    WallpaperWindow {}
    DisplayWindow {}
    SettingsWindow {}
    CheatsheetWindow {}

    Toasts {}
    VolumeOsd {}

    Instantiator {
        model: Overlays.names

        delegate: Scope {
            id: overlayEntry

            required property string modelData

            IpcHandler {
                target: overlayEntry.modelData

                function toggle(): void { Overlays.toggle(overlayEntry.modelData); }
                function open(): void { Overlays.show(overlayEntry.modelData); }
                function close(): void { Overlays[overlayEntry.modelData] = false; }
            }
        }
    }

    Instantiator {
        model: Popups.names

        delegate: Scope {
            id: popupEntry

            required property string modelData

            IpcHandler {
                target: popupEntry.modelData

                function toggle(): void { Popups.toggle(popupEntry.modelData); }
                function open(): void { Popups.open(popupEntry.modelData); }
                function close(): void { Popups.close(popupEntry.modelData); }
            }
        }
    }
}
