import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: workspaces
    
    property var barWindow
    property bool isVertical: false
    
    Layout.preferredWidth: isVertical ? Commons.Config.componentHeight : workspaceRowH.implicitWidth
    Layout.preferredHeight: isVertical ? workspaceColV.implicitHeight : Commons.Config.componentHeight
    implicitWidth: isVertical ? Commons.Config.componentHeight : workspaceRowH.implicitWidth
    implicitHeight: isVertical ? workspaceColV.implicitHeight : Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight
    color: "transparent"
    
    RowLayout {
        id: workspaceRowH
        anchors.centerIn: parent
        spacing: Commons.Config.workspaceSpacing
        visible: !isVertical
        
        Repeater {
            model: Commons.Config.workspaceCount

            delegate: Rectangle {
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
                property bool hasWindows: ws !== undefined && ws !== null
                property bool isHovered: wsHoverH.hovered

                Layout.preferredWidth: isActive ? Commons.Config.workspaceIndicatorActiveWidth : Commons.Config.workspaceIndicatorWidth
                Layout.preferredHeight: isActive ? Commons.Config.workspaceIndicatorHeight : Commons.Config.workspaceIndicatorInactiveHeight
                Layout.alignment: Qt.AlignVCenter
                radius: Commons.Config.workspaceIndicatorRadius
                color: isActive ? Commons.Theme.primary : (hasWindows ? Commons.Theme.secondary : Commons.Theme.foregroundMuted)
                opacity: isActive ? 1.0 : (isHovered ? 0.75 : (hasWindows ? 0.6 : 0.4))

                Behavior on Layout.preferredWidth { NumberAnimation { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }
                Behavior on Layout.preferredHeight { NumberAnimation { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }
                Behavior on color   { ColorAnimation  { duration: Commons.Theme.animMedium } }
                Behavior on opacity { NumberAnimation  { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }

                HoverHandler { id: wsHoverH }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + (parent.index + 1))
                }
            }
        }
    }

    ColumnLayout {
        id: workspaceColV
        anchors.centerIn: parent
        spacing: Commons.Config.workspaceSpacing
        visible: isVertical

        Repeater {
            model: Commons.Config.workspaceCount

            delegate: Rectangle {
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
                property bool hasWindows: ws !== undefined && ws !== null
                property bool isHovered: wsHoverV.hovered

                Layout.preferredWidth: isActive ? Commons.Config.workspaceIndicatorHeight : Commons.Config.workspaceIndicatorInactiveHeight
                Layout.preferredHeight: isActive ? Commons.Config.workspaceIndicatorActiveWidth : Commons.Config.workspaceIndicatorWidth
                Layout.alignment: Qt.AlignHCenter
                radius: Commons.Config.workspaceIndicatorRadius
                color: isActive ? Commons.Theme.primary : (hasWindows ? Commons.Theme.secondary : Commons.Theme.foregroundMuted)
                opacity: isActive ? 1.0 : (isHovered ? 0.75 : (hasWindows ? 0.6 : 0.4))

                Behavior on Layout.preferredWidth { NumberAnimation { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }
                Behavior on Layout.preferredHeight { NumberAnimation { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }
                Behavior on color   { ColorAnimation  { duration: Commons.Theme.animMedium } }
                Behavior on opacity { NumberAnimation  { duration: Commons.Theme.animMedium; easing.type: Easing.OutCubic } }

                HoverHandler { id: wsHoverV }

                MouseArea {
                    anchors.fill: parent
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + (parent.index + 1))
                }
            }
        }
    }
}
