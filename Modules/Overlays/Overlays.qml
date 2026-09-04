pragma Singleton

import Quickshell

Singleton {
    id: root

    property bool launcher: false
    property bool wallpapers: false
    property bool displays: false
    property bool settings: false
    property bool cheatsheet: false

    readonly property var names: ["launcher", "wallpapers", "displays", "settings", "cheatsheet"]

    function show(name: string): void {
        closeAll();
        root[name] = true;
    }

    function toggle(name: string): void {
        const wasOpen = root[name];
        closeAll();
        root[name] = !wasOpen;
    }

    function closeAll(): void {
        for (const name of names)
            root[name] = false;
    }
}
