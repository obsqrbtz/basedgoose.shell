import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Effects
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: powerMenu
    
    ipcTarget: "power"
    initialScale: 0.85
    closeOnClickOutside: true
    barPosition: Commons.Config.barPosition
    
    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)

    implicitWidth: 280
    implicitHeight: contentColumn.implicitHeight + 40

    function showConfirm(label, cmd) {
        confirmPopup.actionLabel = label
        confirmPopup.actionTitle = label
        var icon = "\udb81\udc25"
        if (label === "Reboot") icon = "\udb81\udf09"
        else if (label === "Logout") icon = "\udb81\uddfd"
        confirmPopup.actionIcon = icon
        confirmPopup.actionCmd = cmd
        confirmPopup.secondsLeft = 10

        var sw = powerMenu.screen ? powerMenu.screen.width : 1920
        var sh = powerMenu.screen ? powerMenu.screen.height : 1080
        var pw = confirmPopup.width || 360
        var ph = confirmPopup.implicitHeight || (contentColumn.implicitHeight + 40)
        confirmPopup.relativeX = Math.max(Commons.Config.popupMargin, Math.floor((sw - pw) / 2))
        confirmPopup.relativeY = Math.max(Commons.Config.popupMargin, Math.floor((sh - ph) / 2))
        confirmPopup.shouldShow = true
        powerMenu.shouldShow = false
    }

    Rectangle {
        anchors.fill: backgroundRect
        anchors.margins: -6
        radius: backgroundRect.radius + 3
        color: "transparent"
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, Commons.Theme.popupShadowOpacity)
            shadowBlur: Commons.Theme.popupShadowBlur
            shadowVerticalOffset: Commons.Theme.popupShadowOffset
        }
    }
      
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radiusPanel
        border.color: Commons.Theme.border
        border.width: 1
        
        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: Commons.Config.popupContentPadding
            spacing: Commons.Theme.spacingMd
            
            Widgets.HeaderWithIcon {
                Layout.fillWidth: true
                icon: "\udb81\udc25"
                title: "Power Menu"
                iconColor: Commons.Theme.secondary
            }
            
            Widgets.Divider {
                Layout.fillWidth: true
            }

            Widgets.MenuItem {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                icon: "\udb81\udc25"
                text: "Shutdown"
                iconColor: cPrimary
                textColor: cText
                borderColor: cBorder
                hoverColor: cHover
                onClicked: {
                    showConfirm("Shutdown", ["systemctl", "poweroff"]) 
                }
            }

            Widgets.MenuItem {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                icon: "\udb81\udf09"
                text: "Reboot"
                iconColor: cPrimary
                textColor: cText
                borderColor: cBorder
                hoverColor: cHover
                onClicked: {
                    showConfirm("Reboot", ["systemctl", "reboot"]) 
                }
            }

            Widgets.MenuItem {
                Layout.fillWidth: true
                Layout.preferredHeight: 40
                icon: "\udb81\uddfd"
                text: "Logout"
                iconColor: cPrimary
                textColor: cText
                borderColor: cBorder
                hoverColor: cHover
                onClicked: {
                    showConfirm("Logout", ["hyprshutdown"])
                }
            }
        }
        
        Component {
            id: processComponent
            Process {
                property var cmd: []
                running: true
                command: cmd
            }
        }

        Widgets.PopupWindow {
            id: confirmPopup
            width: Math.min((powerMenu.screen ? powerMenu.screen.width : 1920) - (Commons.Config.popupMargin * 2), Math.max(480, column.implicitWidth + Commons.Config.popupContentPadding * 2))
            implicitHeight: column.implicitHeight + 40
            closeOnClickOutside: false
            initialScale: 0.96
            barPosition: ""
            visible: shouldShow

            property var actionCmd: []
            property string actionLabel: ""
            property string actionIcon: "\udb81\udc25"
            property string actionTitle: ""
            property int secondsLeft: 10

            onShouldShowChanged: {
                if (shouldShow) {
                    secondsLeft = 10
                    countdownTimer.restart()
                } else {
                    countdownTimer.stop()
                }
            }

            Rectangle {
                anchors.fill: parent
                color: Commons.Theme.background
                radius: Commons.Theme.radiusPanel
                border.color: Commons.Theme.border
                border.width: 1

                ColumnLayout {
                    id: column
                    anchors.fill: parent
                    anchors.margins: Commons.Config.popupContentPadding
                    spacing: Commons.Theme.spacingMd

                    Widgets.HeaderWithIcon {
                        Layout.fillWidth: true
                        icon: confirmPopup.actionIcon
                        title: confirmPopup.actionTitle
                        iconColor: cPrimary
                    }

                    Text {
                        id: infoText
                           text: (confirmPopup.actionLabel === "Logout"
                               ? "Session will be closed in "
                               : "System will " + confirmPopup.actionLabel.toLowerCase() + " in ")
                               + confirmPopup.secondsLeft + " seconds."
                           Layout.fillWidth: true
                           horizontalAlignment: Text.AlignHCenter
                           color: cText
                           wrapMode: Text.Wrap
                           font.pixelSize: 14
                    }

                    RowLayout {
                        Layout.alignment: Qt.AlignHCenter
                        spacing: 12

                        Widgets.TextButton {
                            text: "Cancel"
                            onClicked: {
                                confirmPopup.shouldShow = false
                            }
                        }

                        Widgets.TextButton {
                            text: "Proceed Now"
                            onClicked: {
                                confirmPopup.shouldShow = false
                                processComponent.createObject(powerMenu, { cmd: confirmPopup.actionCmd })
                            }
                        }
                    }
                }
                Timer {
                    id: countdownTimer
                    interval: 1000
                    repeat: true
                    running: false
                    onTriggered: {
                        if (confirmPopup.secondsLeft > 1) {
                            confirmPopup.secondsLeft--
                        } else {
                            countdownTimer.stop()
                            confirmPopup.shouldShow = false
                            processComponent.createObject(powerMenu, { cmd: confirmPopup.actionCmd })
                        }
                    }
                }
            }
        }

    }
}

