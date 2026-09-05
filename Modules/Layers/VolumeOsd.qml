import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

OsdWindow {
    id: root

    screen: Compositor.focusedScreen
    contentWidth: 220
    contentHeight: 54

    Connections {
        target: Audio

        function onChanged(): void {
            if (Audio.sinkReady)
                root.trigger();
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingSm

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Icon {
                text: Icons.volumeLevel(Audio.percent, Audio.muted)
                font.pixelSize: Theme.iconLarge
                color: Audio.muted ? Theme.error : Theme.primary
            }

            StyledText {
                Layout.fillWidth: true
                text: Audio.muted ? "Muted" : Audio.sink?.description ?? ""
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }

            StyledText {
                text: `${Audio.percent}%`
                font.pixelSize: Theme.fontSmall
                font.weight: Font.DemiBold
            }
        }

        Meter {
            Layout.fillWidth: true
            value: Audio.muted ? 0 : Audio.percent
            warnWhenFull: false
        }
    }
}
