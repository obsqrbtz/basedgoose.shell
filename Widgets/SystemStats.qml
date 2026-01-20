import QtQuick
import QtQuick.Layouts
import "../Services" as Services

Rectangle {
    id: systemStats
    
    property int cpuUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    
    width: statsRow.width + 20
    height: Services.Config.componentHeight
    color: Services.Theme.surfaceBase
    radius: Services.Config.componentRadius
    
    RowLayout {
        id: statsRow
        anchors.centerIn: parent
        spacing: Services.Config.statsSpacing
        
        RowLayout {
            spacing: Services.Config.statsLabelSpacing
            
            Text {
                text: "\uf4bc"
                color: Services.Theme.primary
                font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.DemiBold }
            }
            Text {
                text: systemStats.cpuUsage + "%"
                color: Services.Theme.foreground
                font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize; weight: Font.Medium }
            }
        }
        
        Rectangle {
            width: Services.Config.statsSeparatorWidth
            height: Services.Config.statsSeparatorHeight
            color: Services.Theme.foregroundMuted
            opacity: Services.Config.statsSeparatorOpacity
        }
        
        RowLayout {
            spacing: Services.Config.statsLabelSpacing
            
            Text {
                text: "\uefc5"
                color: Services.Theme.primary
                font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize + 2; weight: Font.DemiBold }
            }
            Text {
                text: Math.round(systemStats.memUsed) + "M / " + Math.round(systemStats.memTotal) + "M"
                color: Services.Theme.foreground
                font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize; weight: Font.Medium }
            }
        }
    }
}
