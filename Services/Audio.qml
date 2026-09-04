pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Pipewire

Singleton {
    id: root

    readonly property PwNode sink: Pipewire.defaultAudioSink
    readonly property PwNode source: Pipewire.defaultAudioSource

    readonly property bool sinkReady: (sink?.ready ?? false) && !!sink.audio
    readonly property bool sourceReady: (source?.ready ?? false) && !!source.audio

    readonly property real volume: sinkReady ? Math.max(0, Math.min(1, sink.audio.volume)) : 0
    readonly property bool muted: sinkReady ? sink.audio.muted : true
    readonly property int percent: Math.round(volume * 100)

    readonly property real sourceVolume: sourceReady ? Math.max(0, Math.min(1, source.audio.volume)) : 0
    readonly property bool sourceMuted: sourceReady ? source.audio.muted : true
    readonly property int sourcePercent: Math.round(sourceVolume * 100)

    signal changed

    function setVolume(value: real): void {
        if (!sinkReady)
            return;
        sink.audio.muted = false;
        sink.audio.volume = Math.max(0, Math.min(1, value));
    }

    function step(delta: real): void {
        setVolume(volume + delta);
    }

    function toggleMute(): void {
        if (sinkReady)
            sink.audio.muted = !sink.audio.muted;
    }

    function setSourceVolume(value: real): void {
        if (!sourceReady)
            return;
        source.audio.muted = false;
        source.audio.volume = Math.max(0, Math.min(1, value));
    }

    function toggleSourceMute(): void {
        if (sourceReady)
            source.audio.muted = !source.audio.muted;
    }

    PwObjectTracker {
        objects: [root.sink, root.source].filter(n => n)
    }

    Connections {
        target: root.sinkReady ? root.sink.audio : null
        function onVolumeChanged(): void { root.changed(); }
        function onMutedChanged(): void { root.changed(); }
    }
}
