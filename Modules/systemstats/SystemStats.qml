import QtQuick
import QtQuick.Layouts
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: systemStats
    
    property int cpuUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    
    Layout.preferredWidth: statsRow.implicitWidth + 20
    Layout.preferredHeight: Commons.Config.componentHeight
    implicitWidth: statsRow.implicitWidth + 20
    implicitHeight: Commons.Config.componentHeight
    color: Commons.Theme.surfaceBase
    radius: Commons.Theme.radius
    clip: true
    
    RowLayout {
        id: statsRow
        anchors.centerIn: parent
        spacing: Commons.Config.statsSpacing
        
        RowLayout {
            spacing: Commons.Config.statsLabelSpacing
            
            Text {
                text: "\uf4bc"
                color: Commons.Theme.primary
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize + 2; weight: Font.DemiBold }
            }
            Text {
                text: systemStats.cpuUsage + "%"
                color: Commons.Theme.foreground
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
            }
        }
        
        Rectangle {
            width: Commons.Config.statsSeparatorWidth
            height: Commons.Config.statsSeparatorHeight
            color: Commons.Theme.foregroundMuted
            opacity: Commons.Config.statsSeparatorOpacity
        }
        
        RowLayout {
            spacing: Commons.Config.statsLabelSpacing
            
            Text {
                text: "\uefc5"
                color: Commons.Theme.primary
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize + 2; weight: Font.DemiBold }
            }
            Text {
                text: systemStats.memUsed.toFixed(2) + "GB / " + systemStats.memTotal.toFixed(2) + "GB"
                color: Commons.Theme.foreground
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
            }
        }
    }
}
