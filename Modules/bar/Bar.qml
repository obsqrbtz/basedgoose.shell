//@ pragma ComponentBehavior: Bound
import QtQuick 6.10
import QtQuick.Layouts 6.10
import Quickshell
import Quickshell.Wayland
import "../../Commons" as Commons
import "../../Services" as Services
import "../bluetooth" as Bluetooth
import "../network" as Network
import "../volume" as Volume
import "../clock" as Clock

PanelWindow {
    id: bar

    signal showPowerMenu()

    property var mediaPopup
    property var notificationPopups
    property var notificationCenter
    property var shellMenuPopup
    property var powerMenuPopup

    Bluetooth.BluetoothPopup { id: btPopup }
    Network.NetworkPopup     { id: netPopup }
    Volume.VolumePopup       { id: volPopup }
    Clock.CalendarPopup      { id: calPopup }

    readonly property var volumePopup: volPopup

    Services.CpuMonitor    { id: cpuMonitor }
    Services.MemoryMonitor { id: memoryMonitor }

    readonly property string barPosition: Commons.Config.barPosition
    readonly property bool isHorizontal: barPosition === "top" || barPosition === "bottom"
    readonly property bool isVertical: barPosition === "left" || barPosition === "right"

    ModuleRegistry {
        id: registry
        barWindow:          bar
        isVertical:         bar.isVertical
        cpuUsage:           cpuMonitor.cpuUsage
        memUsed:            memoryMonitor.memUsed
        memTotal:           memoryMonitor.memTotal
        shellMenuPopup:     bar.shellMenuPopup
        powerMenuPopup:     bar.powerMenuPopup
        notificationCenter: bar.notificationCenter
        mediaPopup:         bar.mediaPopup
        bluetoothPopup:     btPopup
        networkPopup:       netPopup
        volumePopup:        volPopup
        calendarPopup:      calPopup
    }

    anchors.top:    barPosition === "top"    || barPosition === "left" || barPosition === "right"
    anchors.bottom: barPosition === "bottom" || barPosition === "left" || barPosition === "right"
    anchors.left:   barPosition === "left"   || barPosition === "top"  || barPosition === "bottom"
    anchors.right:  barPosition === "right"  || barPosition === "top"  || barPosition === "bottom"

    margins {
        top:    (barPosition === "top"    || barPosition === "left" || barPosition === "right")  ? Commons.Config.barMargin : 0
        bottom: (barPosition === "bottom" || barPosition === "left" || barPosition === "right")  ? Commons.Config.barMargin : 0
        left:   (barPosition === "left"   || barPosition === "top"  || barPosition === "bottom") ? Commons.Config.barMargin : 0
        right:  (barPosition === "right"  || barPosition === "top"  || barPosition === "bottom") ? Commons.Config.barMargin : 0
    }

    implicitWidth:  isVertical   ? Commons.Config.barWidth  : undefined
    implicitHeight: isHorizontal ? Commons.Config.barHeight : undefined
    color: "transparent"

    Rectangle {
        anchors.fill: parent
        color:        Commons.Theme.background
        radius:       0

        Rectangle {
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            anchors.right:  parent.right
            height: 1
            color:  Commons.Theme.border
            visible: barPosition === "top"
        }
        Rectangle {
            anchors.top:   parent.top
            anchors.left:  parent.left
            anchors.right: parent.right
            height: 1
            color:  Commons.Theme.border
            visible: barPosition === "bottom"
        }
        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            anchors.right:  parent.right
            width: 1
            color:  Commons.Theme.border
            visible: barPosition === "left"
        }
        Rectangle {
            anchors.top:    parent.top
            anchors.bottom: parent.bottom
            anchors.left:   parent.left
            width: 1
            color:  Commons.Theme.border
            visible: barPosition === "right"
        }
    }

    Component.onCompleted: {
        console.log("[Bar] Position:", barPosition, "isVertical:", isVertical)
    }

    Item {
        anchors.fill: parent
        visible: isHorizontal

        Rectangle {
            id: leftPillH
            anchors.left: parent.left
            anchors.leftMargin: Commons.Config.barPadding
            anchors.verticalCenter: parent.verticalCenter
            width: leftRowH.implicitWidth + Commons.Config.sectionPillPadding * 2
            height: Commons.Config.componentHeight
            color: "transparent"
            radius: 0
            border.width: 0
            visible: (Commons.Config.barModules.left || []).length > 0

            RowLayout {
                id: leftRowH
                anchors.centerIn: parent
                spacing: Commons.Config.barSpacing

                Repeater {
                    model: Commons.Config.barModules.left || []
                    delegate: Loader {
                        required property string modelData
                        sourceComponent: registry.getBarComponent(modelData)
                        Layout.preferredHeight: Commons.Config.componentHeight
                    }
                }
            }
        }

        Rectangle {
            id: centerPillH
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
            width: centerRowH.implicitWidth + Commons.Config.sectionPillPadding * 2
            height: Commons.Config.componentHeight
            color: "transparent"
            radius: 0
            border.width: 0
            visible: (Commons.Config.barModules.center || []).length > 0

            RowLayout {
                id: centerRowH
                anchors.centerIn: parent
                spacing: Commons.Config.barSpacing

                Repeater {
                    model: Commons.Config.barModules.center || []
                    delegate: Loader {
                        required property string modelData
                        sourceComponent: registry.getBarComponent(modelData)
                        Layout.preferredHeight: Commons.Config.componentHeight
                    }
                }
            }
        }

        Rectangle {
            id: rightPillH
            anchors.right: parent.right
            anchors.rightMargin: Commons.Config.barPadding
            anchors.verticalCenter: parent.verticalCenter
            width: rightRowH.implicitWidth + Commons.Config.sectionPillPadding * 2
            height: Commons.Config.componentHeight
            color: "transparent"
            radius: 0
            border.width: 0
            visible: (Commons.Config.barModules.right || []).length > 0

            RowLayout {
                id: rightRowH
                anchors.centerIn: parent
                spacing: Commons.Config.barSpacing

                Repeater {
                    model: Commons.Config.barModules.right || []
                    delegate: Loader {
                        required property string modelData
                        sourceComponent: registry.getBarComponent(modelData)
                        Layout.alignment: Qt.AlignVCenter
                        Layout.preferredHeight: Commons.Config.componentHeight
                    }
                }
            }
        }
    }

    Item {
        anchors.fill: parent
        visible: isVertical

        ColumnLayout {
            id: leftColV
            anchors.top: parent.top
            anchors.topMargin: Commons.Config.barPadding
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.left || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: registry.getBarComponent(modelData)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        ColumnLayout {
            id: centerColV
            anchors.verticalCenter: parent.verticalCenter
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.center || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: registry.getBarComponent(modelData)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }

        ColumnLayout {
            id: rightColV
            anchors.bottom: parent.bottom
            anchors.bottomMargin: Commons.Config.barPadding
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Commons.Config.barSpacing

            Repeater {
                model: Commons.Config.barModules.right || []
                delegate: Loader {
                    required property string modelData
                    sourceComponent: registry.getBarComponent(modelData)
                    Layout.alignment: Qt.AlignHCenter
                }
            }
        }
    }
}
