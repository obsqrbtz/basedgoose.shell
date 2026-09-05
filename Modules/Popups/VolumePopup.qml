import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    contentWidth: 280
    contentHeight: column.implicitHeight + padding * 2

    ColumnLayout {
        id: column
        anchors.fill: parent
        spacing: Theme.spacingMd

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.volumeLevel(Audio.percent, Audio.muted)
            title: "Audio"
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                IconButton {
                    icon: Icons.volumeLevel(Audio.percent, Audio.muted)
                    size: Theme.controlHeight
                    contentColor: Audio.muted ? Theme.error : Theme.text
                    onClicked: Audio.toggleMute()
                }

                Slider {
                    Layout.fillWidth: true
                    value: Audio.volume
                    accent: Audio.muted ? Theme.textMuted : Theme.primary
                    onMoved: value => Audio.setVolume(value)
                }

                StyledText {
                    text: `${Audio.percent}%`
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 32
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: Audio.sink?.description ?? "No output device"
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }
        }

        Divider { Layout.fillWidth: true }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingXs
            visible: Audio.sourceReady

            RowLayout {
                Layout.fillWidth: true
                spacing: Theme.spacingSm

                IconButton {
                    icon: Audio.sourceMuted ? Icons.micOff : Icons.micOn
                    size: Theme.controlHeight
                    contentColor: Audio.sourceMuted ? Theme.error : Theme.text
                    onClicked: Audio.toggleSourceMute()
                }

                Slider {
                    Layout.fillWidth: true
                    value: Audio.sourceVolume
                    accent: Audio.sourceMuted ? Theme.textMuted : Theme.secondary
                    onMoved: value => Audio.setSourceVolume(value)
                }

                StyledText {
                    text: `${Audio.sourcePercent}%`
                    font.pixelSize: Theme.fontNormal
                    color: Theme.text
                    horizontalAlignment: Text.AlignRight
                    Layout.preferredWidth: 32
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: Audio.source?.description ?? ""
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }
        }
    }
}
