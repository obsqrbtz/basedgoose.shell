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

    readonly property string title: active?.trackTitle || "Nothing playing"
    readonly property string artist: active?.trackArtist ?? ""
    readonly property string album: active?.trackAlbum ?? ""
    readonly property string artUrl: active?.trackArtUrl ?? ""

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
