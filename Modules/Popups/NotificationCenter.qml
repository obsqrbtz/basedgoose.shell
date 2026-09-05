import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import qs.Config
import qs.Services
import qs.Widgets

BarPopup {
    id: root

    contentWidth: 380
    contentHeight: 520

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingSm

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.bell
            title: "Notifications"

            IconButton {
                icon: Icons.dnd
                size: Theme.controlHeight
                active: Notifications.dnd
                onClicked: Notifications.dnd = !Notifications.dnd
            }

            IconButton {
                icon: Icons.trash
                size: Theme.controlHeight
                visible: Notifications.count > 0
                onClicked: Notifications.clearAll()
            }
        }

        Divider { Layout.fillWidth: true }

        ScrollList {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingSm
            model: Object.keys(Notifications.grouped)

            delegate: ColumnLayout {
                required property string modelData

                width: ListView.view.width
                spacing: Theme.spacingXs

                RowLayout {
                    Layout.fillWidth: true

                    SectionLabel { text: modelData }

                    StyledText {
                        text: Notifications.grouped[modelData].length
                        font.pixelSize: Theme.fontSmall
                        color: Theme.textMuted
                    }

                    Item { Layout.fillWidth: true }

                    IconButton {
                        icon: Icons.close
                        size: Theme.controlHeightSmall
                        onClicked: Notifications.clearApp(modelData)
                    }
                }

                Repeater {
                    model: Notifications.grouped[modelData]

                    NotificationCard {
                        required property Notification modelData

                        Layout.fillWidth: true
                        notification: modelData
                        onDismissed: Notifications.close(modelData)
                    }
                }
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.topMargin: Theme.spacingXl
            icon: Icons.bellOff
            title: "No notifications"
            visible: Notifications.count === 0
        }
    }
}
