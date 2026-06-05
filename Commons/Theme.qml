pragma Singleton
import QtQuick

QtObject {
    id: theme

    readonly property color background:       '#0C0C0C'
    readonly property color surfaceBase:      '#111111'
    readonly property color surfaceContainer: '#181818'

    readonly property color border:           '#2A2A2A'
    readonly property color borderFocused:    Qt.lighter(primary, 1.3)
    readonly property color surfaceBorder:    '#222222'

    readonly property color foreground:         '#C8C8C8'
    readonly property color foregroundMuted:    '#525252'
    readonly property color surfaceText:        foreground
    readonly property color surfaceTextVariant: '#525252'

    readonly property color primary:      '#5FAD5F'
    readonly property color primaryMuted: '#0A190A'
    readonly property color secondary:    '#B89A3C'
    readonly property color secondaryMuted: '#1A150A'
    readonly property color surfaceAccent: primaryMuted

    readonly property color info: '#7AA2F7'

    readonly property color warning: '#B89A3C'
    readonly property color success: '#5FAD5F'
    readonly property color error:   '#B85450'

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
