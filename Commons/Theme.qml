pragma Singleton
import QtQuick

QtObject {
    id: theme
    
    readonly property color background: '#151515'
    readonly property color border: Qt.rgba(secondary.r, secondary.g, secondary.b, 0.12)
    readonly property color foreground: '#C2C2B0'
    readonly property color foregroundMuted: '#CCCCCC'
    readonly property color primary: '#95A328'
    readonly property color primaryMuted: '#6d781e'
    readonly property color secondary: '#E1C135'
    readonly property color secondaryMuted: '#9f8925'

    readonly property color warning: '#E1C135'
    readonly property color success: '#95A328'
    readonly property color error: '#B44242'

    readonly property color surfaceBase: '#1C1C1C'
    readonly property color surfaceContainer: Qt.lighter(surfaceBase, 1.08)
    readonly property color surfaceText: foreground
    readonly property color surfaceTextVariant: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.55)
    readonly property color surfaceBorder: Qt.rgba(foreground.r, foreground.g, foreground.b, 0.04)
    readonly property color surfaceAccent: Qt.rgba(secondary.r, secondary.g, secondary.b, 0.12)

    readonly property string font: "JetBrainsMono Nerd Font"
    readonly property int fontSize: 13
    readonly property int radius: 8
}

