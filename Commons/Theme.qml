pragma Singleton
import QtQuick

QtObject {
    id: theme
    readonly property color background: '#262325'
    readonly property color border: '#484447'
    readonly property color borderFocused: Qt.lighter(primary, 1.2)
    readonly property color foreground: '#FFFFFF'
    readonly property color foregroundMuted: Qt.darker(foreground, 2.5)
    readonly property color primary: '#989A8E'
    readonly property color primaryMuted: Qt.darker(primary, 2.5)
    readonly property color secondary: '#BA9B83'
    readonly property color secondaryMuted: Qt.darker(secondary, 2.5)

    readonly property color warning: '#BDBFB2'
    readonly property color success: '#EABDA4'
    readonly property color error: '#9E939C'

    readonly property color surfaceBase: '#363235'
    readonly property color surfaceContainer: '#464044'
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: '#FDFDEB'
    readonly property color surfaceBorder: Qt.lighter(surfaceBase, 1.2)
    readonly property color surfaceAccent: primaryMuted

    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontUI: "Inter"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}



