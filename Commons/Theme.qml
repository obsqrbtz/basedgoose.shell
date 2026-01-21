pragma Singleton
import QtQuick

QtObject {
    id: theme
    // Colors: #AARRGGBB
    readonly property color background: '#FF151515'
    readonly property color border: '#484848'
    readonly property color borderFocused: Qt.lighter(primary, 1.2)
    readonly property color foreground: '#FFC2C2B0'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.5)
    readonly property color primary: '#FF95A328'
    readonly property color primaryMuted: Qt.darker(primary, 2.5)
    readonly property color secondary: '#FFE1C135'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.5)

    readonly property color warning: '#FFE1C135'
    readonly property color success: '#FF95A328'
    readonly property color error: '#FFB44242'

    readonly property color surfaceBase: '#FF1C1C1C'
    readonly property color surfaceContainer: '#FF1E1E1E'
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: '#8CC2C2B0'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: '#1FE1C135'

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}

