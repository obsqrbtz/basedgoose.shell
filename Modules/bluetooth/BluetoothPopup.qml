import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import Quickshell.Bluetooth
import Quickshell.Io
import "../../Services" as Services
import "../../Commons" as Commons
import "../../Widgets" as Widgets

Widgets.PopupWindow {
    id: popupWindow
    
    ipcTarget: "bluetooth"
    initialScale: 0.94
    transformOriginX: 1.0
    transformOriginY: 0.0
    
    readonly property var adapter: Bluetooth.defaultAdapter
    readonly property var devices: [...Bluetooth.devices.values].sort((a, b) => {
        if (a.connected !== b.connected) return b.connected - a.connected
        if (a.bonded !== b.bonded) return b.bonded - a.bonded
        return a.name.localeCompare(b.name)
    })
    
    readonly property color cSurface: Commons.Theme.background
    readonly property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Commons.Theme.border
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
    
    anchors {
        top: true
        right: true
    }
    
    margins {
        right: Commons.Config.popupMargin
        top: Commons.Config.popupMargin
    }
    
    implicitWidth: 320
    implicitHeight: contentColumn.implicitHeight + 32
    
    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: cSurface
        radius: Commons.Theme.radius * 2
        border.color: cBorder
        border.width: 1
        
        Process {
            id: settingsProcess
            command: ["blueman-manager"]
            onStarted: popupWindow.shouldShow = false
        }
        
        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowBlur: 1.0
            shadowVerticalOffset: 6
        }
        
        ColumnLayout {
            id: contentColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.top: parent.top
            anchors.margins: 16
            spacing: 12
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Widgets.HeaderWithIcon {
                        Layout.fillWidth: true
                        icon: "󰂯"
                        title: "Bluetooth"
                        subtitle: {
                            var connected = devices.filter(d => d.connected)
                            return connected.length > 0 ? connected[0].name : "No device connected"
                        }
                        iconColor: cPrimary
                        titleColor: cText
                        subtitleColor: cSubText
                    }
                    
                    Item {
                        Layout.fillWidth: true
                    }
                    
                    Widgets.ToggleSwitch {
                        width: 44
                        height: 24
                        checked: adapter?.enabled ?? false
                        checkedColor: cPrimary
                        uncheckedColor: Qt.rgba(cText.r, cText.g, cText.b, 0.15)
                        thumbColor: "#ffffff"
                        animationDuration: 150
                        onToggled: if (adapter) adapter.enabled = !adapter.enabled
                    }
                }
                
                Widgets.HoverButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    icon: adapter?.discovering ? "󰑐" : "󰑓"
                    text: adapter?.discovering ? "Scanning..." : "Scan for devices"
                    iconSize: 16
                    textSize: 12
                    iconColor: adapter?.discovering ? cPrimary : cText
                    hoverIconColor: adapter?.discovering ? cPrimary : cPrimary
                    textColor: cText
                    hoverTextColor: cText
                    baseColor: cSurfaceContainer
                    hoverColor: cHover
                    onClicked: if (adapter) adapter.discovering = !adapter.discovering
                    
                    Text {
                        anchors.centerIn: parent
                        anchors.horizontalCenterOffset: -40
                        text: "󰑐"
                        font.family: Commons.Theme.fontIcon
                        font.pixelSize: 16
                        color: cPrimary
                        visible: adapter?.discovering ?? false
                        
                        RotationAnimation on rotation {
                            running: adapter?.discovering ?? false
                            from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                        }
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: devices.length === 0 ? 120 : Math.min(deviceList.contentHeight + 8, 260)
                    radius: 12
                    color: cSurfaceContainer
                    clip: true
                    
                    ListView {
                        id: deviceList
                        anchors.fill: parent
                        anchors.margins: 4
                        spacing: 2
                        model: devices
                        clip: true
                        
                        delegate: Widgets.ListItem {
                            id: deviceItem
                            width: deviceList.width
                            height: 52
                            
                            required property var modelData
                            property bool isConnected: modelData.connected
                            
                            icon: {
                                const iconStr = deviceItem.modelData.icon || ""
                                if (iconStr.includes("audio")) return "󰋋"
                                if (iconStr.includes("phone")) return "󰄜"
                                if (iconStr.includes("computer")) return "󰌢"
                                if (iconStr.includes("mouse")) return "󰍽"
                                if (iconStr.includes("keyboard")) return "󰌌"
                                return "󰂯"
                            }
                            title: deviceItem.modelData.name
                            subtitle: {
                                if (deviceItem.modelData.state === BluetoothDeviceState.Connecting) return "Connecting..."
                                if (isConnected) return "Connected"
                                if (deviceItem.modelData.bonded) return "Paired"
                                return "Available"
                            }
                            iconColor: isConnected ? cPrimary : cText
                            titleColor: cText
                            subtitleColor: isConnected ? cPrimary : cSubText
                            hoverColor: cHover
                            borderColor: "transparent"
                            showBorder: false
                            
                            Widgets.IconButton {
                                anchors.right: parent.right
                                anchors.rightMargin: 12
                                anchors.verticalCenter: parent.verticalCenter
                                width: 28
                                height: 28
                                icon: deviceItem.isConnected ? "󰌊" : "󰌘"
                                iconSize: 14
                                iconColor: deviceItem.isConnected ? cPrimary : cSubText
                                hoverIconColor: deviceItem.isConnected ? cPrimary : cPrimary
                                baseColor: "transparent"
                                hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                                borderWidth: 1
                                borderColor: deviceItem.isConnected ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.15)
                                onClicked: {
                                    if (deviceItem.isConnected) {
                                        deviceItem.modelData.connected = false
                                    } else {
                                        deviceItem.modelData.connected = true
                                    }
                                }
                            }
                        }
                    }
                    
                    Widgets.EmptyState {
                        anchors.centerIn: parent
                        visible: devices.length === 0
                        icon: "󰂲"
                        iconSize: 32
                        iconOpacity: 0.2
                        title: adapter?.enabled ? "No devices found" : "Bluetooth disabled"
                        subtitle: ""
                        textOpacity: 1.0
                    }
                }
                
                Widgets.TextButton {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    icon: "󰒓"
                    text: "Bluetooth Settings"
                    iconColor: cSubText
                    textColor: cSubText
                    hoverColor: cHover
                    showBorder: false
                    onClicked: settingsProcess.running = true
                }
            }
        }
    }

