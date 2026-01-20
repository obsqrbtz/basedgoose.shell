import Quickshell
import Quickshell.Hyprland
import QtQuick
import QtQuick.Layouts
import "../Services" as Services

Rectangle {
    id: workspaces
    
    width: workspaceRow.width + 16
    height: Services.Config.componentHeight
    color: Services.Theme.surfaceBase
    radius: Services.Config.componentRadius
    
    RowLayout {
        id: workspaceRow
        anchors.centerIn: parent
        spacing: Services.Config.workspaceSpacing
        
        Repeater {
            model: Services.Config.workspaceCount
            
            delegate: Rectangle {
                required property int index
                property var ws: Hyprland.workspaces.values.find(w => w.id === index + 1)
                property bool isActive: Hyprland.focusedWorkspace ? Hyprland.focusedWorkspace.id === (index + 1) : false
                property bool hasWindows: ws !== undefined && ws !== null
                
                Layout.preferredWidth: isActive ? Services.Config.workspaceIndicatorActiveWidth : Services.Config.workspaceIndicatorWidth
                Layout.preferredHeight: Services.Config.workspaceIndicatorHeight
                radius: Services.Config.workspaceIndicatorRadius
                color: isActive ? Services.Theme.primary : (hasWindows ? Services.Theme.primaryMuted : Services.Theme.foregroundMuted)
                
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
