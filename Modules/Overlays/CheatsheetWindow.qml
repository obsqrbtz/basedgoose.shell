import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets
import qs.Modules.Popups

OverlayWindow {
    id: root

    readonly property string prefix: "qs -c basedgoose.shell ipc call"

    readonly property var sections: [
        { title: "Windows", names: Overlays.names },
        { title: "Bar popups", names: Popups.names }
    ]

    open: Overlays.cheatsheet
    onCloseRequested: Overlays.cheatsheet = false

    contentWidth: 560
    contentHeight: 560

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.keyboard
            title: "IPC commands"
            closable: true
            onCloseRequested: root.closeRequested()
        }

        StyledText {
            Layout.fillWidth: true
            text: "Every entry accepts toggle, open and close. Bar popups act on the bar of the focused screen."
            color: Theme.textMuted
            font.pixelSize: Theme.fontCaption
            wrapMode: Text.Wrap
        }

        Flickable {
            Layout.fillWidth: true
            Layout.fillHeight: true
            contentHeight: list.implicitHeight
            clip: true
            boundsBehavior: Flickable.StopAtBounds

            ColumnLayout {
                id: list
                width: parent.width
                spacing: Theme.spacingMd

                Repeater {
                    model: root.sections

                    ColumnLayout {
                        required property var modelData

                        Layout.fillWidth: true
                        spacing: Theme.spacingXs

                        SectionLabel { text: modelData.title }

                        Repeater {
                            model: modelData.names

                            Surface {
                                id: entry

                                required property string modelData

                                Layout.fillWidth: true
                                implicitHeight: 26
                                accent: Theme.primary
                                onClicked: Clipboard.copy(command.text)

                                StyledText {
                                    id: command
                                    anchors.left: parent.left
                                    anchors.leftMargin: Theme.spacingSm
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: `${root.prefix} ${entry.modelData} toggle`
                                    font.pixelSize: Theme.fontCaption
                                    color: entry.hovered ? Theme.primary : Theme.textMuted
                                }

                                StyledText {
                                    anchors.right: parent.right
                                    anchors.rightMargin: Theme.spacingSm
                                    anchors.verticalCenter: parent.verticalCenter
                                    text: "click to copy"
                                    font.pixelSize: Theme.fontTiny
                                    color: Theme.alpha(Theme.textMuted, 0.7)
                                    visible: entry.hovered
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
