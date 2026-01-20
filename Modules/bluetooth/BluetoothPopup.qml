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
        radius: 16
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
            anchors.fill: parent
            anchors.margins: 16
            spacing: 12
                
                RowLayout {
                    Layout.fillWidth: true
                    spacing: 12
                    
                    Rectangle {
                        width: 36
                        height: 36
                        radius: 12
                        color: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                        
                        Text {
                            anchors.centerIn: parent
                            text: "󰂯"
                            font.family: "Material Design Icons"
                            font.pixelSize: 18
                            color: cPrimary
                        }
                    }
                    
                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        
                        Text {
                            text: "Bluetooth"
                            font.family: "Inter"
                            font.pixelSize: 15
                            font.weight: Font.Bold
                            color: cText
                        }
                        
                        Text {
                            property var connected: devices.filter(d => d.connected)
                            text: connected.length > 0 ? connected[0].name : "No device connected"
                            font.family: "Inter"
                            font.pixelSize: 11
                            color: cSubText
                        }
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
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: scanArea.containsMouse ? cHover : cSurfaceContainer
                    
                    Behavior on color { ColorAnimation { duration: 100 } }
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 8
                        
                        Text {
                            text: adapter?.discovering ? "󰑐" : "󰑓"
                            font.family: "Material Design Icons"
                            font.pixelSize: 16
                            color: adapter?.discovering ? cPrimary : cText
                            
                            RotationAnimation on rotation {
                                running: adapter?.discovering ?? false
                                from: 0; to: 360; duration: 1000; loops: Animation.Infinite
                            }
                        }
                        
                        Text {
                            text: adapter?.discovering ? "Scanning..." : "Scan for devices"
                            font.family: "Inter"
                            font.pixelSize: 12
                            font.weight: Font.Medium
                            color: cText
                        }
                    }
                    
                    MouseArea {
                        id: scanArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: if (adapter) adapter.discovering = !adapter.discovering
                    }
                }
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: Math.min(deviceList.contentHeight + 8, 260)
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
                        
                        delegate: Rectangle {
                            id: deviceItem
                            width: deviceList.width
                            height: 52
                            radius: 10
                            color: itemArea.containsMouse ? cHover : "transparent"
                            
                            required property var modelData
                            property bool isConnected: modelData.connected
                            
                            Behavior on color { ColorAnimation { duration: 80 } }
                            
                            RowLayout {
                                anchors.fill: parent
                                anchors.leftMargin: 12
                                anchors.rightMargin: 12
                                spacing: 10
                                
                                Text {
                                    text: {
                                        const icon = deviceItem.modelData.icon || ""
                                        if (icon.includes("audio")) return "󰋋"
                                        if (icon.includes("phone")) return "󰄜"
                                        if (icon.includes("computer")) return "󰌢"
                                        if (icon.includes("mouse")) return "󰍽"
                                        if (icon.includes("keyboard")) return "󰌌"
                                        return "󰂯"
                                    }
                                    font.family: "Material Design Icons"
                                    font.pixelSize: 18
                                    color: isConnected ? cPrimary : cText
                                }
                                
                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    
                                    Text {
                                        text: deviceItem.modelData.name
                                        font.family: "Inter"
                                        font.pixelSize: 12
                                        font.weight: Font.Medium
                                        color: cText
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                    
                                    Text {
                                        text: {
                                            if (deviceItem.modelData.state === BluetoothDeviceState.Connecting) return "Connecting..."
                                            if (isConnected) return "Connected"
                                            if (deviceItem.modelData.bonded) return "Paired"
                                            return "Available"
                                        }
                                        font.family: "Inter"
                                        font.pixelSize: 10
                                        color: isConnected ? cPrimary : cSubText
                                    }
                                }
                                
                                Widgets.IconButton {
                                    width: 28
                                    height: 28
                                    icon: isConnected ? "󰌊" : "󰌘"
                                    iconSize: 14
                                    iconColor: isConnected ? cPrimary : cSubText
                                    hoverIconColor: isConnected ? cPrimary : cPrimary
                                    baseColor: "transparent"
                                    hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                                    border.width: 1
                                    border.color: isConnected ? cPrimary : Qt.rgba(cText.r, cText.g, cText.b, 0.15)
                                    onClicked: {
                                        if (isConnected) {
                                            deviceItem.modelData.connected = false
                                        } else {
                                            deviceItem.modelData.connected = true
                                        }
                                    }
                                }
                            }
                            
                            MouseArea {
                                id: itemArea
                                anchors.fill: parent
                                hoverEnabled: true
                                z: -1
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
                
                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 36
                    radius: 10
                    color: settingsArea.containsMouse ? cHover : "transparent"
                    
                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        
                        Text {
                            text: "󰒓"
                            font.family: "Material Design Icons"
                            font.pixelSize: 14
                            color: cSubText
                        }
                        
                        Text {
                            text: "Bluetooth Settings"
                            font.family: "Inter"
                            font.pixelSize: 12
                            color: cSubText
                        }
                    }
                    
                    MouseArea {
                        id: settingsArea
                        anchors.fill: parent
                        hoverEnabled: true
                        cursorShape: Qt.PointingHandCursor
                        onClicked: settingsProcess.running = true
                    }
                }
            }
        }
    }

