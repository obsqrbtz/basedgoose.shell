pragma Singleton

import QtQuick

QtObject {

    id: theme

    readonly property color background: '#18161A'
    readonly property color surfaceBase: '#242025'
    readonly property color surfaceContainer: '#2F2B33'
    readonly property color surfaceText: '#F5F5F7'
    readonly property color surfaceTextVariant: '#DADADA'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: '#7F82B3'

    readonly property color border: '#3F3B42'
    readonly property color borderFocused: Qt.lighter('#7F82B3', 1.2)

    readonly property color foreground: '#EDEDED'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.0)

    readonly property color primary: '#6C79D6'
    readonly property color primaryMuted: Qt.rgba(primary.r, primary.g, primary.b, 0.1)
    
    readonly property color secondary: '#D18B6B'
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
