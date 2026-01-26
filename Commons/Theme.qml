pragma Singleton

import QtQuick

QtObject {

    id: theme

    readonly property color background: '#1E1C20'
    readonly property color surfaceBase: '#2A262C'
    readonly property color surfaceContainer: '#38343B'
    readonly property color surfaceText: '#FFFFFF'
    readonly property color surfaceTextVariant: '#EAEAEA'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.3)
    readonly property color surfaceAccent: '#A6A8C1'

    readonly property color border: '#4C484F'
    readonly property color borderFocused: Qt.lighter('#A6A8C1', 1.2)

    readonly property color foreground: '#F5F5F7'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.0)

    readonly property color primary: '#8FA1E3'
    readonly property color primaryMuted: Qt.darker(primary, 2.0)
    readonly property color secondary: '#F4B183'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.0)

    readonly property color warning: '#F6E27F'
    readonly property color success: '#A3E6A3'
    readonly property color error: '#E27FA3'

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13

    readonly property int radius: 8
}
