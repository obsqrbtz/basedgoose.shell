import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    contentWidth: 300
    contentHeight: column.implicitHeight + padding * 2

    ColumnLayout {
        id: column
        anchors.fill: parent

        spacing: 0

        ClippingRectangle {
            Layout.alignment: Qt.AlignHCenter
            Layout.preferredWidth: 180
            Layout.preferredHeight: 180
            radius: Theme.radiusPanel
            color: Theme.surfaceAlt

            Image {
                anchors.fill: parent
                source: Players.artUrl
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 360
                sourceSize.height: 360
            }

            Icon {
                anchors.centerIn: parent
                text: Icons.music
                font.pixelSize: 40
                visible: Players.artUrl === ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 9
            spacing: 2

            StyledText {
                Layout.fillWidth: true
                Layout.preferredHeight: font.pixelSize
                text: Players.title
                font.pixelSize: Theme.fontHeading
                font.weight: Font.DemiBold
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
            }

            StyledText {
                Layout.fillWidth: true
                Layout.preferredHeight: font.pixelSize
                text: Players.artist
                font.pixelSize: Theme.fontSmall
                opacity: 0.6
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                visible: Players.artist !== ""
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.topMargin: 11
            spacing: 2
            visible: Players.length > 0

            Slider {
                Layout.fillWidth: true
                value: Players.progress
                onMoved: value => Players.seek(value)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 0

                StyledText {
                    text: Format.time(Players.position)
                    font.pixelSize: Theme.fontTiny
                    color: Theme.textMuted
                }

                Item { Layout.fillWidth: true }

                StyledText {
                    text: Format.time(Players.length)
                    font.pixelSize: Theme.fontTiny
                    color: Theme.textMuted
                    horizontalAlignment: Text.AlignRight
                }
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: 9
            spacing: Theme.spacingXs

            IconButton {
                icon: Icons.previous
                size: 30
                iconSize: Theme.iconHuge
                enabled: Players.active?.canGoPrevious ?? false
                onClicked: Players.previous()
            }

            IconButton {
                icon: Players.playing ? Icons.pause : Icons.play
                size: 30
                iconSize: Theme.iconHuge
                variant: Button.Filled
                onClicked: Players.playPause()
            }

            IconButton {
                icon: Icons.next
                size: 30
                iconSize: Theme.iconHuge
                enabled: Players.active?.canGoNext ?? false
                onClicked: Players.next()
            }
        }
    }
}
