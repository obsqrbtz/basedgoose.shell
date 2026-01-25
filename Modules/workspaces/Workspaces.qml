import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: workspaces
    
    Layout.preferredWidth: workspaceRow.implicitWidth + 16
    Layout.preferredHeight: Commons.Config.componentHeight
    implicitHeight: Commons.Config.componentHeight
    color: Commons.Theme.surfaceBase
    radius: Commons.Theme.radius
    clip: true
    
    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Commons.Config.workspaceSpacing
        
        Repeater {
            model: Commons.Config.workspaceCount
            
            delegate: Rectangle {
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
                property bool hasWindows: ws !== undefined && ws !== null
                
                Layout.preferredWidth: isActive ? Commons.Config.workspaceIndicatorActiveWidth : Commons.Config.workspaceIndicatorWidth
                Layout.preferredHeight: Commons.Config.workspaceIndicatorHeight
                radius: Commons.Config.workspaceIndicatorRadius
                color: isActive ? Commons.Theme.primary : (hasWindows ? Commons.Theme.secondary : Commons.Theme.foregroundMuted)
                
                Behavior on Layout.preferredWidth { NumberAnimation { duration: 200; easing.type: Easing.OutCubic } }
                Behavior on color { ColorAnimation { duration: 200 } }
                
                MouseArea {
                    anchors.fill: parent
                    hoverEnabled: true
                    cursorShape: Qt.PointingHandCursor
                    onClicked: Hyprland.dispatch("workspace " + (parent.index + 1))
                }
            }
        }
    }
}
