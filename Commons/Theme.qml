pragma Singleton
import QtQuick

QtObject {
    id: theme

    readonly property color background:       '#0D1520'
    readonly property color surfaceBase:      '#131D2E'
    readonly property color surfaceContainer: '#1A2640'

    readonly property color border:           '#2A3554'
    readonly property color borderFocused:    Qt.lighter(primary, 1.3)
    readonly property color surfaceBorder:    '#212F47'

    readonly property color foreground:         '#C8D0E0'
    readonly property color foregroundMuted:    '#5A6478'
    readonly property color surfaceText:        foreground
    readonly property color surfaceTextVariant: '#5A6478'

    readonly property color primary:      '#7B6ECB'
    readonly property color primaryMuted: '#1E1A42'
    readonly property color secondary:    '#4D9E7C'
    readonly property color secondaryMuted: '#142B22'
    readonly property color surfaceAccent: primaryMuted

    readonly property color warning: '#C49138'
    readonly property color success: '#4D9E7C'
    readonly property color error:   '#B8524E'

    readonly property string fontUI:   "Inter"
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

    readonly property int radius:      4
    readonly property int radiusSm:    2
    readonly property int radiusLg:    12
    readonly property int radiusPanel: 10

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
