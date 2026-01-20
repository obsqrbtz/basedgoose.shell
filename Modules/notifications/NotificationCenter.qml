import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Controls 6.10
import QtQuick.Effects
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: root
    
    ipcTarget: "notifications"
    initialScale: 0.95
    transformOriginX: 1.0
    transformOriginY: 0.0
    closeOnClickOutside: true
    
    property alias notifs: root.notifService
    
    readonly property var notifService: Services.Notifs
    readonly property var recentNotifs: notifService.recentNotifications
    readonly property var groupedNotifs: notifService.groupedNotifications
    readonly property bool hasDnd: notifService.dnd
    
    readonly property color surfaceBase: Commons.Theme.surfaceBase
    readonly property color surfaceContainer: Commons.Theme.surfaceContainer
    readonly property color secondary: Commons.Theme.secondary
    readonly property color surfaceText: Commons.Theme.surfaceText
    readonly property color surfaceTextVariant: Commons.Theme.surfaceTextVariant
    readonly property color error: Commons.Theme.error
    readonly property color surfaceBorder: Commons.Theme.surfaceBorder
    readonly property color surfaceAccent: Commons.Theme.surfaceAccent
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: Commons.Config.popupMargin
        right: Commons.Config.popupMargin
    }
    
    implicitWidth: Commons.Config.notifications.centerWidth
    implicitHeight: Commons.Config.notifications.centerHeight
        
    Rectangle {
        anchors.fill: parent
        radius: Commons.Config.notifications.centerRadius
        color: surfaceBase
        border.width: 1
        border.color: Commons.Theme.border
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.25)
            shadowBlur: 0.8
            shadowVerticalOffset: 8
            shadowHorizontalOffset: 0
        }
    }
    
    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 20
        spacing: 16
        
        RowLayout {
            Layout.fillWidth: true
            spacing: 12
            
            Text {
                text: "Notifications"
                font.pixelSize: 20
                font.weight: Font.Bold
                font.family: "Inter"
                color: surfaceText
                Layout.fillWidth: true
            }
            
            Widgets.ToggleSwitch {
                checked: root.hasDnd
                checkedColor: secondary
                uncheckedColor: surfaceContainer
                thumbColor: root.hasDnd ? Commons.Theme.background : surfaceTextVariant
                icon: root.hasDnd ? "󰂛" : "󰂚"
                iconColor: root.hasDnd ? Commons.Theme.secondary : Commons.Theme.background
                onToggled: root.notifService.toggleDnd()
            }
            
            Widgets.IconButton {
                icon: "\udb80\udf9f"
                iconSize: 18
                iconColor: surfaceTextVariant
                hoverIconColor: error
                baseColor: surfaceContainer
                hoverColor: Qt.rgba(error.r, error.g, error.b, 0.15)
                onClicked: root.notifService.clearAll()
            }
            
            Widgets.IconButton {
                icon: "󰅖"
                iconSize: 18
                iconColor: surfaceTextVariant
                onClicked: root.shouldShow = false
            }
        }
        
        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: 1
            color: surfaceBorder
        }
        
        ListView {
            id: notifListView
            Layout.fillWidth: true
            Layout.fillHeight: true
            
            clip: true
            spacing: Commons.Config.notifications.itemSpacing
            
            model: root.recentNotifs
            
            ScrollBar.vertical: ScrollBar {
                policy: ScrollBar.AsNeeded
            }
            
            Item {
                anchors.centerIn: parent
                width: parent.width
                height: 200
                visible: notifListView.count === 0
                
                Widgets.EmptyState {
                    anchors.centerIn: parent
                    icon: "󰂚"
                    iconSize: 64
                    title: "No notifications"
                    subtitle: "You're all caught up!"
                }
            }
            
            delegate: Rectangle {
                id: notificationItemHover
                
                required property var modelData
                required property int index
                
                width: notifListView.width
                height: contentCol.implicitHeight + 24
                radius: 14
                
                color: notifMouse.containsMouse ? 
                       Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.04) :
                       surfaceContainer
                
                border.width: 1
                border.color: surfaceBorder
                
                opacity: modelData.closed ? 0.5 : 1.0
                                
                Rectangle {
                    width: 3
                    height: 20
                    anchors.left: parent.left
                    anchors.leftMargin: 8
                    anchors.verticalCenter: parent.verticalCenter
                    radius: 1.5
                    visible: modelData.urgency >= 1
                    color: modelData.urgency === 2 ? error : Commons.Theme.warning
                }
                
                ColumnLayout {
                    id: contentCol
                    anchors.fill: parent
                    anchors.margins: 12
                    anchors.leftMargin: modelData.urgency >= 1 ? 20 : 12
                    spacing: 6
                    
                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        
                        Widgets.AppIcon {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            size: 32
                            iconSize: 18
                            iconSource: modelData.appIcon || ""
                            fallbackIcon: "󰂞"
                        }
                        
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 1
                            
                            Text {
                                text: modelData.appName || "Notification"
                                font.pixelSize: 11
                                font.weight: Font.Medium
                                font.family: "Inter"
                                color: surfaceTextVariant
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                            }
                            
                            Text {
                                text: modelData.timeString || "now"
                                font.pixelSize: 9
                                font.family: "Inter"
                                color: Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.35)
                            }
                        }
                        
                        Widgets.IconButton {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            icon: "󰅖"
                            iconSize: 14
                            iconColor: surfaceTextVariant
                            hoverIconColor: error
                            hoverColor: Qt.rgba(error.r, error.g, error.b, 0.1)
                            pressedColor: Qt.rgba(error.r, error.g, error.b, 0.2)
                            onClicked: root.notifService.deleteNotification(modelData)
                        }
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: modelData.summary || ""
                        font.pixelSize: 13
                        font.weight: Font.DemiBold
                        font.family: "Inter"
                        color: surfaceText
                        wrapMode: Text.Wrap
                        maximumLineCount: 2
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                    
                    Text {
                        Layout.fillWidth: true
                        text: modelData.body || ""
                        font.pixelSize: 11
                        font.family: "Inter"
                        color: surfaceTextVariant
                        wrapMode: Text.Wrap
                        maximumLineCount: 3
                        elide: Text.ElideRight
                        visible: text.length > 0
                    }
                    
                    Flow {
                        Layout.fillWidth: true
                        Layout.topMargin: 4
                        spacing: 6
                        visible: modelData.actions && modelData.actions.length > 0
                        
                        Repeater {
                            model: notificationItemHover.modelData.actions || []
                            
                            Widgets.ActionButton {
                                required property var modelData
                                
                                text: modelData.text || modelData.identifier
                                fontSize: 10
                                horizontalPadding: 16
                                onClicked: {
                                    modelData.invoke()
                                    notificationItemHover.modelData.close()
                                }
                            }
                        }
                    }
                }
                
                MouseArea {
                    id: notifMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    propagateComposedEvents: true
                    z: -1
                }
            }
        }
    }
}


