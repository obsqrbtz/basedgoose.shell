pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

Singleton {
    id: root

    readonly property list<MprisPlayer> list: Mpris.players.values

    readonly property MprisPlayer active: list.find(p => p.isPlaying) ?? list[0] ?? null

    readonly property bool playing: active?.isPlaying ?? false
    readonly property bool hasPlayer: active !== null

    readonly property string title: root.track(active?.trackTitle ?? "") || "Nothing playing"
    readonly property string artist: root.track(active?.trackArtist ?? "")
    readonly property string album: root.track(active?.trackAlbum ?? "")
    readonly property string artUrl: active?.trackArtUrl ?? ""

    function track(value: string): string {
        const text = value.trim();
        if (text === "")
            return "";
        const self = [active?.identity ?? "", active?.desktopEntry ?? ""];
        return self.some(name => name.trim().toLowerCase() === text.toLowerCase()) ? "" : text;
    }

    readonly property real position: active?.position ?? 0
    readonly property real length: active?.length ?? 0
    readonly property real progress: length > 0 ? Math.min(1, position / length) : 0

    function playPause(): void {
        if (active?.canTogglePlaying)
            active.togglePlaying();
    }

    function next(): void {
        if (active?.canGoNext)
            active.next();
    }

    function previous(): void {
        if (active?.canGoPrevious)
            active.previous();
    }

    function seek(fraction: real): void {
        if (active?.canSeek && length > 0)
            active.position = fraction * length;
    }

    Timer {
        running: root.playing && root.active?.positionSupported
        interval: 1000
        repeat: true
        onTriggered: root.active.positionChanged()
    }
}
