import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

Surface {
    id: root

    required property Notification notification

    signal dismissed

    readonly property color urgencyColor: notification.urgency === NotificationUrgency.Critical ? Theme.error : notification.urgency === NotificationUrgency.Low ? Theme.textMuted : Theme.primary

    implicitHeight: layout.implicitHeight + Theme.spacingMd * 2
    baseColor: Theme.surface
    radius: Theme.radiusPanel
    border.width: 1
    border.color: notification.urgency === NotificationUrgency.Critical ? Theme.error : Theme.borderSubtle
    accent: Theme.primary

    onClicked: root.dismissed()

    Rectangle {
        width: 2
        height: parent.height
        color: root.urgencyColor
    }

    RowLayout {
        id: layout
        anchors.fill: parent
        anchors.margins: Theme.spacingMd
        anchors.leftMargin: Theme.spacingMd + 2
        spacing: Theme.spacingSm

        ClippingRectangle {
            Layout.alignment: Qt.AlignTop
            Layout.preferredWidth: 32
            Layout.preferredHeight: 32
            radius: Theme.radiusPanel
            color: Theme.alpha(root.urgencyColor, 0.15)
            visible: root.notification.image !== "" || root.notification.appIcon !== ""

            Image {
                anchors.fill: parent
                source: root.notification.image || root.notification.appIcon
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                sourceSize.width: 64
                sourceSize.height: 64
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            RowLayout {
                Layout.fillWidth: true

                StyledText {
                    Layout.fillWidth: true
                    text: root.notification.summary
                    font.pixelSize: Theme.fontSmall
                    font.weight: Font.DemiBold
                }

                StyledText {
                    text: Notifications.age(root.notification)
                    font.pixelSize: Theme.fontTiny
                    color: Theme.textMuted
                }
            }

            StyledText {
                Layout.fillWidth: true
                text: root.notification.body
                font.pixelSize: Theme.fontCaption
                color: Theme.textMuted
                wrapMode: Text.Wrap
                maximumLineCount: 3
                visible: text !== ""
            }

            RowLayout {
                spacing: Theme.spacingXs
                visible: root.notification.actions.length > 0

                Repeater {
                    model: root.notification.actions

                    Button {
                        required property NotificationAction modelData

                        label: modelData.text
                        variant: Button.Outlined
                        fontSize: Theme.fontTiny
                        padding: Theme.spacingSm
                        implicitHeight: 22
                        onClicked: modelData.invoke()
                    }
                }
            }
        }

        IconButton {
            Layout.alignment: Qt.AlignTop
            icon: Icons.close
            size: 20
            onClicked: root.dismissed()
        }
    }
}
