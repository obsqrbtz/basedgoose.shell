import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import "../../Services" as Services
import "../../Commons" as Commons

Item {
    id: root
    property var barWindow
    property var bluetoothPopup
    
    readonly property bool isEnabled: Services.Bluetooth.powered
    readonly property bool hasConnection: Services.Bluetooth.connected
    readonly property string deviceName: Services.Bluetooth.deviceName
    readonly property int deviceCount: Services.Bluetooth.deviceCount
    readonly property bool isHovered: mouseArea.containsMouse
    
    implicitWidth: bluetoothRow.implicitWidth
    implicitHeight: 20
    
    RowLayout {
        id: bluetoothRow
        anchors.centerIn: parent
        spacing: 5
        Layout.leftMargin: Commons.Config.componentPadding / 2
        Layout.alignment: Qt.AlignVCenter
        
        Text {
            Layout.alignment: Qt.AlignVCenter
            text: {
                if (!isEnabled) return "󰂲"
                if (hasConnection) return "󰂱"
                return "󰂯"
            }
            font.family: "Material Design Icons"
            font.pixelSize: 14
            color: {
                if (!isEnabled) return Commons.Theme.foreground
                if (isHovered) return Commons.Theme.primary
                if (hasConnection) return Commons.Theme.success
                return Commons.Theme.foreground
            }
            Behavior on color { ColorAnimation { duration: 150 } }
            scale: isHovered ? 1.05 : 1.0
            Behavior on scale { NumberAnimation { duration: 100 } }
        }
        
        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.maximumWidth: 120
            text: {
                if (!isEnabled) return "Off"
                if (!hasConnection) return "No device"
                if (deviceCount > 1) return deviceName + " +" + (deviceCount - 1)
                return deviceName
            }
            font.family: "Inter"
            font.pixelSize: 10
            font.weight: hasConnection ? Font.Medium : Font.Normal
            elide: Text.ElideRight
            color: {
                if (!isEnabled || !hasConnection) return Commons.Theme.foreground
                if (isHovered) return Commons.Theme.primary
                return Commons.Theme.foreground
            }
            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }
    
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        anchors.margins: 0
        cursorShape: Qt.PointingHandCursor
        hoverEnabled: true
        
        onClicked: {
            if (!bluetoothPopup) return
            
            bluetoothPopup.shouldShow = !bluetoothPopup.shouldShow
            if (!bluetoothPopup.shouldShow) return
            if (!barWindow || !barWindow.screen) return
            
            const pos = root.mapToItem(barWindow.contentItem, 0, 0)
            const rightEdge = pos.x + root.width
            const screenWidth = barWindow.screen.width
            const barHeight = barWindow.implicitHeight || 36
            
            bluetoothPopup.margins.right = Math.round(screenWidth - rightEdge - 8)
            bluetoothPopup.margins.top = barHeight + 6
        }
    }
}

