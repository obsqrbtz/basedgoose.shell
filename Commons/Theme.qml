pragma Singleton

import QtQuick

QtObject {

    id: theme

    readonly property color background: '#0f0f1e'
    readonly property color surfaceBase: '#1a1a2e'
    readonly property color surfaceContainer: '#22223b'
    readonly property color surfaceText: '#f2e9e4'
    readonly property color surfaceTextVariant: '#c9ada7'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: '#4a4e69'

    readonly property color border: '#22223b'
    readonly property color borderFocused: Qt.lighter('#4a4e69', 1.2)

    readonly property color foreground: '#f2e9e4'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.0)

    readonly property color primary: '#9a8c98'
    readonly property color primaryMuted: Qt.rgba(primary.r, primary.g, primary.b, 0.1)
    
    readonly property color secondary: '#c9ada7'
    readonly property color secondaryMuted: Qt.rgba(secondary.r, secondary.g, secondary.b, 0.1)

    readonly property color warning: '#D4C87D'
    readonly property color success: '#7EC87E'
    readonly property color error: '#D16C8B'

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13

    readonly property int radius: 8
}
