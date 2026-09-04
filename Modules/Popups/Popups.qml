pragma Singleton

import Quickshell

Singleton {
    signal requested(string name, string action)

    readonly property var names: ["volume", "network", "bluetooth", "calendar", "media", "stats", "notifications", "power", "menu"]

    function toggle(name: string): void {
        requested(name, "toggle");
    }

    function open(name: string): void {
        requested(name, "open");
    }

    function close(name: string): void {
        requested(name, "close");
    }
}
