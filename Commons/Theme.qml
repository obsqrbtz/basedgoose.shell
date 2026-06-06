pragma Singleton
import QtQuick
import "../Services" as Services

QtObject {
    id: theme

    readonly property var palette: Services.ThemeService.colors

    readonly property color background:       palette.background
    readonly property color surfaceBase:      palette.surfaceBase
    readonly property color surfaceContainer: palette.surfaceContainer

    readonly property color border:           palette.border
    readonly property color borderFocused:    Qt.lighter(primary, 1.3)
    readonly property color surfaceBorder:    palette.surfaceBorder

    readonly property color foreground:         palette.foreground
    readonly property color foregroundMuted:    palette.foregroundMuted
    readonly property color surfaceText:        foreground
    readonly property color surfaceTextVariant: foregroundMuted

    readonly property color primary:      palette.primary
    readonly property color primaryMuted: palette.primaryMuted
    readonly property color secondary:    palette.secondary
    readonly property color secondaryMuted: palette.secondaryMuted
    readonly property color surfaceAccent: primaryMuted

    readonly property color info: palette.info

    readonly property color warning: palette.warning
    readonly property color success: palette.success
    readonly property color error:   palette.error

    readonly property string fontUI:   "JetBrainsMono Nerd Font"
    readonly property string fontMono: "JetBrainsMono Nerd Font"
    readonly property string fontIcon: "JetBrainsMono Nerd Font"

    readonly property int fontSize:           12
    readonly property int fontSizeHeading:    16
    readonly property int fontSizeSubheading: 13
    readonly property int fontSizeCaption:    10
    readonly property int fontSizeTiny:       8

    readonly property int iconSize:   14
    readonly property int iconSizeLg: 16

    readonly property int animFast:   100
    readonly property int animNormal: 150
    readonly property int animMedium: 200

    readonly property real stateLayerHover:   0.08
    readonly property real stateLayerPressed: 0.12

    readonly property int radius:      0
    readonly property int radiusSm:    0
    readonly property int radiusLg:    0
    readonly property int radiusPanel: 2

    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 20

    readonly property color colorWhite: '#FFFFFF'

    readonly property real dividerOpacity:     0.35
    readonly property real popupShadowBlur:    1.0
    readonly property real popupShadowOffset:  8
    readonly property real popupShadowOpacity: 0.35
}
