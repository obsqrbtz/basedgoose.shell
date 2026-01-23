import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Wayland
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

PanelWindow {
    id: root
    
    readonly property var notifs: Services.Notifs
    
    readonly property color surfaceBase: Commons.Theme.surfaceBase
    readonly property color surfaceContainer: Commons.Theme.surfaceContainer
    readonly property color secondary: Commons.Theme.secondary
    readonly property color surfaceText: Commons.Theme.surfaceText
    readonly property color surfaceTextVariant: Commons.Theme.surfaceTextVariant
    readonly property color error: Commons.Theme.error
    readonly property color warning: Commons.Theme.warning
    readonly property color surfaceBorder: Commons.Theme.surfaceBorder
    readonly property color surfaceAccent: Commons.Theme.surfaceAccent
    
    readonly property var activePopups: (
        notifs.notifications
            .filter(n => !n.closed)
            .slice(0, Commons.Config.notifications.maxVisible)
    )
    
    screen: Quickshell.screens[0]
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        top: Commons.Config.popupMargin
             + Commons.Config.barHeight
             + Commons.Config.barMargin * 2
        right: Commons.Config.popupMargin
    }
    
    visible: activePopups.length > 0
    color: "transparent"
    
    implicitWidth: Commons.Config.notifications.popupWidth
    implicitHeight: notifColumn.implicitHeight
    
    Column {
        id: notifColumn
        width: parent.width
        spacing: Commons.Config.notifications.spacing
        
        move: Transition {
            NumberAnimation {
                properties: "y"
                duration: 120
                easing.type: Easing.OutQuad
            }
        }
        
        Repeater {
            model: root.activePopups
            
            Item {
                id: notifCard
                
                required property var modelData
                required property int index
                
                width: Commons.Config.notifications.popupWidth
                height: cardWrapper.height
                clip: true
                
                property bool isVisible: true
                property bool isHovered: false
                property bool isExpanded: false
                property real animProgress: 0
                
                property real entranceScale: 0.7
                property real entranceX: 120
                property real entranceOpacity: 0
                
                Component.onCompleted: {
                    animProgress = 1.0
                    entranceScale = 1.0
                    entranceX = 0
                    entranceOpacity = 1.0
                }
                                
                function dismiss() {
                    isVisible = false
                    modelData.close()
                }
                
                Item {
                    id: cardWrapper
                    width: parent.width
                    height: cardBg.height
                    
                    scale: notifCard.entranceScale
                    opacity: notifCard.entranceOpacity
                    transform: Translate {
                        x: notifCard.entranceX
                    }
                    
                    transformOrigin: Item.Right
                    
                    Rectangle {
                        id: cardBg
                        width: parent.width
                        height: contentLayout.implicitHeight + 28
                        radius: 20
                        
                        color: root.surfaceBase
                        border.width: 1
                        border.color: notifCard.isHovered ? 
                                     Qt.rgba(root.secondary.r, root.secondary.g, root.secondary.b, 0.15) : 
                                     Commons.Theme.border
                        
                        Behavior on border.color {
                            ColorAnimation { duration: 200; easing.type: Easing.OutCubic }
                        }
                        
                        layer.enabled: true
                        layer.effect: MultiEffect {
                            shadowEnabled: true
                            shadowColor: Qt.rgba(0, 0, 0, 0.18 * animProgress)
                            shadowBlur: 0.6
                            shadowVerticalOffset: 4 * animProgress
                            shadowHorizontalOffset: 0
                        }
                        
                        Rectangle {
                            id: hoverLayer
                            anchors.fill: parent
                            radius: parent.radius
                            color: root.surfaceText
                            opacity: notifCard.isHovered ? 0.03 : 0
                        }
                        
                        MouseArea {
                            id: mouseArea
                            anchors.fill: parent
                            hoverEnabled: true
                            
                            onEntered: {
                                notifCard.isHovered = true
                            }
                            
                            onExited: {
                                if (!pressed) {
                                    notifCard.isHovered = false
                                }
                            }
                            
                            onReleased: mouse => {
                                if (!containsMouse) {
                                    notifCard.isHovered = false
                                }
                            }
                            
                            acceptedButtons: Qt.LeftButton | Qt.MiddleButton
                            
                            onClicked: mouse => {
                                if (mouse.button === Qt.MiddleButton) {
                                    notifCard.dismiss()
                                } else {
                                    if (modelData.actions && modelData.actions.length === 1) {
                                        modelData.actions[0].invoke()
                                        notifCard.dismiss()
                                    }
                                }
                            }
                        }
                    
                        ColumnLayout {
                            id: contentLayout
                            anchors {
                                left: parent.left
                                right: parent.right
                                top: parent.top
                                margins: 16
                                leftMargin: modelData.urgency >= 1 ? 20 : 16
                            }
                            spacing: 8
                            
                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 12
                                
                                Widgets.AppIcon {
                                    Layout.preferredWidth: 38
                                    Layout.preferredHeight: 38
                                    size: 38
                                    iconSize: 20
                                    iconSource: modelData.appIcon || ""
                                    fallbackIcon: "󰂞"
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 1
                                    
                                    Text {
                                        text: modelData.appName || "Notification"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        font.family: Commons.Theme.fontUI
                                        font.letterSpacing: 0.3
                                        color: root.surfaceTextVariant
                                        Layout.fillWidth: true
                                        elide: Text.ElideRight
                                    }
                                    
                                    Text {
                                        text: modelData.timeString || "now"
                                        font.pixelSize: 10
                                        font.family: Commons.Theme.fontUI
                                        font.letterSpacing: 0.2
                                        color: Qt.rgba(root.surfaceText.r, root.surfaceText.g, root.surfaceText.b, 0.35)
                                    }
                                }
                                
                                Widgets.IconButton {
                                    Layout.preferredWidth: 28
                                    Layout.preferredHeight: 28
                                    icon: "󰅖"
                                    iconSize: 14
                                    iconColor: Qt.rgba(root.surfaceText.r, root.surfaceText.g, root.surfaceText.b, 0.4)
                                    hoverIconColor: root.error
                                    hoverColor: Qt.rgba(root.surfaceText.r, root.surfaceText.g, root.surfaceText.b, 0.06)
                                    pressedColor: Qt.rgba(root.error.r, root.error.g, root.error.b, 0.15)
                                    onClicked: notifCard.dismiss()
                                }
                            }
                        
                            Text {
                                Layout.fillWidth: true
                                Layout.topMargin: 2
                                text: modelData.summary || ""
                                font.pixelSize: 13
                                font.weight: Font.DemiBold
                                font.family: Commons.Theme.fontUI
                                font.letterSpacing: -0.1
                                color: root.surfaceText
                                wrapMode: Text.Wrap
                                maximumLineCount: 2
                                elide: Text.ElideRight
                                lineHeight: 1.25
                                visible: text.length > 0
                            }
                            
                            Text {
                                Layout.fillWidth: true
                                text: modelData.body || ""
                                font.pixelSize: 12
                                font.family: Commons.Theme.fontUI
                                font.letterSpacing: 0.1
                                color: root.surfaceTextVariant
                                wrapMode: Text.Wrap
                                maximumLineCount: notifCard.isExpanded ? 10 : 3
                                elide: Text.ElideRight
                                lineHeight: 1.35
                                visible: text.length > 0
                                
                                Behavior on maximumLineCount {
                                    NumberAnimation { duration: 200 }
                                }
                            }
                            
                            Item {
                                Layout.fillWidth: true
                                Layout.preferredHeight: 90
                                Layout.topMargin: 4
                                visible: modelData.image && modelData.image.length > 0
                                
                                Rectangle {
                                    anchors.fill: parent
                                    radius: 14
                                    clip: true
                                    color: root.surfaceContainer
                                    border.width: 1
                                    border.color: root.surfaceBorder
                                    
                                    Image {
                                        anchors.fill: parent
                                        anchors.margins: 1
                                        source: {
                                            if (!modelData.image) return ""
                                            if (modelData.image.startsWith("/") || modelData.image.startsWith("file://")) {
                                                return modelData.image
                                            }
                                            return "image://icon/" + modelData.image
                                        }
                                        fillMode: Image.PreserveAspectCrop
                                        smooth: true
                                        cache: true
                                        asynchronous: true
                                        
                                        layer.enabled: true
                                        layer.effect: MultiEffect {
                                            maskEnabled: true
                                            maskThresholdMin: 0.5
                                            maskSpreadAtMin: 1.0
                                            maskSource: ShaderEffectSource {
                                                sourceItem: Rectangle {
                                                    width: 1
                                                    height: 1
                                                    radius: 13
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                            
                            Flow {
                                Layout.fillWidth: true
                                Layout.topMargin: 6
                                spacing: 6
                                visible: modelData.actions && modelData.actions.length > 0
                                
                                Repeater {
                                    model: notifCard.modelData.actions || []
                                    
                                    Widgets.ActionButton {
                                        required property var modelData
                                        required property int index
                                        
                                        text: modelData.text || modelData.identifier
                                        fontSize: 11
                                        horizontalPadding: 20
                                        implicitHeight: 30
                                        onClicked: {
                                            modelData.invoke()
                                            notifCard.dismiss()
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}