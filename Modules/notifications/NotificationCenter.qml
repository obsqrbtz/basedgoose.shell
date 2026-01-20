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
        top: Commons.Config.notifications.centerMargin + Commons.Config.barHeight + Commons.Config.barMargin * 2
        right: Commons.Config.notifications.centerMargin
    }
    
    implicitWidth: Commons.Config.notifications.centerWidth
    implicitHeight: Commons.Config.notifications.centerHeight
        
    Rectangle {
        anchors.fill: parent
        radius: Commons.Config.notifications.centerRadius
        color: surfaceBase
        border.width: 1
        border.color: surfaceBorder
        
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
            
            Rectangle {
                Layout.preferredWidth: 48
                Layout.preferredHeight: 32
                radius: 16
                color: root.hasDnd ? secondary : surfaceContainer
                border.width: 1
                border.color: surfaceBorder
                
                Behavior on color {
                    ColorAnimation { duration: 200 }
                }
                
                Rectangle {
                    width: 24
                    height: 24
                    radius: 12
                    x: root.hasDnd ? parent.width - width - 4 : 4
                    y: 4
                    color: root.hasDnd ? Commons.Theme.background : surfaceTextVariant
                    
                    Behavior on x {
                        NumberAnimation { 
                            duration: 200
                            easing.type: Easing.OutCubic
                        }
                    }
                    
                    Behavior on color {
                        ColorAnimation { duration: 200 }
                    }
                    
                    Text {
                        anchors.centerIn: parent
                        text: root.hasDnd ? "󰂛" : "󰂚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 14
                        color: root.hasDnd ? Commons.Theme.secondary : Commons.Theme.background
                    }
                }
                
                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notifService.toggleDnd()
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: clearAllMouse.containsMouse ? 
                       Qt.rgba(error.r, error.g, error.b, 0.15) :
                       surfaceContainer
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "󰎘"
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: clearAllMouse.containsMouse ? error : surfaceTextVariant
                    
                    Behavior on color {
                        ColorAnimation { duration: 150 }
                    }
                }
                
                MouseArea {
                    id: clearAllMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.notifService.clearAll()
                }
            }
            
            Rectangle {
                Layout.preferredWidth: 36
                Layout.preferredHeight: 36
                radius: 18
                color: closeMouse.containsMouse ? 
                       Qt.rgba(surfaceText.r, surfaceText.g, surfaceText.b, 0.08) :
                       "transparent"
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                
                Text {
                    anchors.centerIn: parent
                    text: "󰅖"
                    font.family: "Material Design Icons"
                    font.pixelSize: 18
                    color: surfaceTextVariant
                }
                
                MouseArea {
                    id: closeMouse
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: root.shouldShow = false
                }
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
                
                ColumnLayout {
                    anchors.centerIn: parent
                    spacing: 12
                    
                    Text {
                        text: "󰂚"
                        font.family: "Material Design Icons"
                        font.pixelSize: 64
                        color: surfaceTextVariant
                        opacity: 0.3
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "No notifications"
                        font.pixelSize: 16
                        font.weight: Font.Medium
                        font.family: "Inter"
                        color: surfaceTextVariant
                        opacity: 0.6
                        Layout.alignment: Qt.AlignHCenter
                    }
                    
                    Text {
                        text: "You're all caught up!"
                        font.pixelSize: 13
                        font.family: "Inter"
                        color: surfaceTextVariant
                        opacity: 0.4
                        Layout.alignment: Qt.AlignHCenter
                    }
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
                
                Behavior on color {
                    ColorAnimation { duration: 150 }
                }
                                
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
                        
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: surfaceAccent
                            visible: modelData.appIcon && modelData.appIcon.length > 0
                            
                            Image {
                                anchors.centerIn: parent
                                width: 18
                                height: 18
                                source: {
                                    if (!modelData.appIcon) return ""
                                    if (modelData.appIcon.startsWith("/") || modelData.appIcon.startsWith("file://")) {
                                        return modelData.appIcon
                                    }
                                    return "image://icon/" + modelData.appIcon
                                }
                                fillMode: Image.PreserveAspectFit
                                smooth: true
                                cache: true
                                asynchronous: true
                            }
                        }
                        
                        Rectangle {
                            Layout.preferredWidth: 32
                            Layout.preferredHeight: 32
                            radius: 16
                            color: surfaceAccent
                            visible: !modelData.appIcon || modelData.appIcon.length === 0
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰂞"
                                font.family: "Material Design Icons"
                                font.pixelSize: 14
                                color: secondary
                            }
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
                        
                        Rectangle {
                            Layout.preferredWidth: 28
                            Layout.preferredHeight: 28
                            radius: 14
                            color: deleteMouse.pressed ?
                                   Qt.rgba(error.r, error.g, error.b, 0.2) :
                                   deleteMouse.containsMouse ?
                                   Qt.rgba(error.r, error.g, error.b, 0.1) :
                                   "transparent"
                            
                            Behavior on color {
                                ColorAnimation { duration: 150 }
                            }
                            
                            Text {
                                anchors.centerIn: parent
                                text: "󰆴"
                                font.family: "Material Design Icons"
                                font.pixelSize: 14
                                color: deleteMouse.containsMouse ? error : surfaceTextVariant
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                            }
                            
                            MouseArea {
                                id: deleteMouse
                                anchors.fill: parent
                                hoverEnabled: true
                                cursorShape: Qt.PointingHandCursor
                                onClicked: mouse => {
                                    mouse.accepted = true
                                    root.notifService.deleteNotification(modelData)
                                }
                            }
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
                            
                            Rectangle {
                                required property var modelData
                                
                                width: actionText.width + 16
                                height: 26
                                radius: 13
                                
                                color: actionMouse.pressed ?
                                       Qt.rgba(secondary.r, secondary.g, secondary.b, 0.25) :
                                       actionMouse.containsMouse ?
                                       Qt.rgba(secondary.r, secondary.g, secondary.b, 0.15) :
                                       Qt.rgba(secondary.r, secondary.g, secondary.b, 0.08)
                                
                                Behavior on color {
                                    ColorAnimation { duration: 150 }
                                }
                                
                                Text {
                                    id: actionText
                                    anchors.centerIn: parent
                                    text: parent.modelData.text || parent.modelData.identifier
                                    font.pixelSize: 10
                                    font.weight: Font.Medium
                                    font.family: "Inter"
                                    color: secondary
                                }
                                
                                MouseArea {
                                    id: actionMouse
                                    anchors.fill: parent
                                    hoverEnabled: true
                                    cursorShape: Qt.PointingHandCursor
                                    onClicked: {
                                        parent.modelData.invoke()
                                        notificationItemHover.modelData.close()
                                    }
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


