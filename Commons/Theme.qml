pragma Singleton
import QtQuick

QtObject {
    id: theme
    // Colors: #AARRGGBB
    readonly property color background: '#111111'
    readonly property color border: '#313131'
    readonly property color borderFocused: Qt.lighter(primary, 1.2)
    readonly property color foreground: '#D2D2D2'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.5)
    readonly property color primary: '#9A8652'
    readonly property color primaryMuted: Qt.darker(primary, 2.5)
    readonly property color secondary: '#B6AB82'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.5)

    readonly property color warning: '#B47837'
    readonly property color success: '#668A51'
    readonly property color error: '#AA4E4A'

    readonly property color surfaceBase: '#1C1C1C'
    readonly property color surfaceContainer: '#202020'
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: '#D4D4D4'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: primaryMuted

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}
