pragma Singleton

import QtQuick
import Quickshell

Singleton {
    id: root

    readonly property color background: Schemes.colors.background
    readonly property color surface: Schemes.colors.surfaceBase
    readonly property color surfaceAlt: Schemes.colors.surfaceContainer
    readonly property color surfaceHigh: Schemes.colors.surfaceHigh
    readonly property color border: Schemes.colors.border
    readonly property color borderSubtle: Schemes.colors.surfaceBorder
    readonly property color text: Schemes.colors.foreground
    readonly property color textMuted: Schemes.colors.foregroundMuted
    readonly property color primary: Schemes.colors.primary
    readonly property color primaryMuted: Schemes.colors.primaryMuted
    readonly property color secondary: Schemes.colors.secondary
    readonly property color secondaryMuted: Schemes.colors.secondaryMuted
    readonly property color info: Schemes.colors.info
    readonly property color warning: Schemes.colors.warning
    readonly property color success: Schemes.colors.success
    readonly property color error: Schemes.colors.error

    readonly property string fontFamily: "JetBrainsMono Nerd Font"
    readonly property string iconFontFamily: "JetBrainsMono Nerd Font Propo"

    readonly property int fontSmall: 11
    readonly property int fontNormal: 13
    readonly property int fontLarge: 16
    readonly property int fontHeading: 20

    readonly property int iconSmall: 14
    readonly property int iconNormal: 16
    readonly property int iconLarge: 20
    readonly property int iconHuge: 28

    readonly property int controlHeight: 28
    readonly property int controlHeightSmall: 22
    readonly property int controlHeightLarge: 34
    readonly property int controlHeightBar: 26
    readonly property int barItemInner: 20

    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 20

    readonly property int radius: 0
    readonly property int radiusPanel: 2

    readonly property int animFast: 100
    readonly property int animNormal: 150
    readonly property int animSlow: 200

    readonly property real hoverAlpha: 0.08
    readonly property real pressedAlpha: 0.14

    function alpha(color: color, a: real): color {
        return Qt.rgba(color.r, color.g, color.b, a);
    }
}
