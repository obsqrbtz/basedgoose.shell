import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.Notifications
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

Surface {
    id: root

    required property Notification notification

    signal dismissed

    readonly property var defaultAction: {
        for (const action of notification.actions)
            if (action.identifier === "default")
                return action;
        return null;
    }

    readonly property var visibleActions: {
        const actions = [];
        for (const action of notification.actions)
            if (action.identifier !== "default" && action.text !== "")
                actions.push(action);
        return actions;
    }

    readonly property string iconSource: {
        const image = notification.image;
        if (image !== "")
            return image.includes("/") ? image : Quickshell.iconPath(image, true);
        const appIcon = notification.appIcon;
        return appIcon !== "" ? Quickshell.iconPath(appIcon, true) : "";
    }

    readonly property color urgencyColor: notification.urgency === NotificationUrgency.Critical ? Theme.error : notification.urgency === NotificationUrgency.Low ? Theme.textMuted : Theme.primary

    implicitHeight: layout.implicitHeight + Theme.spacingMd * 2
    baseColor: Theme.surface
    radius: Theme.radiusPanel
    border.width: 1
    border.color: notification.urgency === NotificationUrgency.Critical ? Theme.error : Theme.borderSubtle
    accent: Theme.primary

    onClicked: {
        if (root.defaultAction)
            root.defaultAction.invoke();
        root.dismissed();
    }

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
            visible: root.iconSource !== ""

            Image {
                anchors.fill: parent
                source: root.iconSource
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
                visible: root.visibleActions.length > 0

                Repeater {
                    model: root.visibleActions

                    Button {
                        required property var modelData

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
