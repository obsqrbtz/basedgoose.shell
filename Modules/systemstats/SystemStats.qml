import QtQuick
import QtQuick.Layouts
import "../../Services" as Services
import "../../Commons" as Commons

Rectangle {
    id: systemStats
    
    property int cpuUsage: 0
    property real memUsed: 0
    property real memTotal: 0
    property var barWindow
    property bool isVertical: false
    
    implicitWidth: isVertical ? Commons.Config.barWidth - Commons.Config.barPadding * 2 - 4 : statsRowH.implicitWidth
    implicitHeight: isVertical ? statsColV.implicitHeight : Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight
    color: "transparent"
    
    RowLayout {
        id: statsRowH
        anchors.centerIn: parent
        spacing: Commons.Config.statsSpacing
        visible: !isVertical
        
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
                text: systemStats.memUsed.toFixed(1) + "G" + " / " + systemStats.memTotal.toFixed(0) + "G"
                color: Commons.Theme.foreground
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.Medium }
            }
        }
    }
    
    ColumnLayout {
        id: statsColV
        anchors.centerIn: parent
        spacing: Commons.Config.statsSpacing
        visible: isVertical

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "\uf4bc"
                color: Commons.Theme.primary
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.iconSize; weight: Font.DemiBold }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: systemStats.cpuUsage + "%"
                color: Commons.Theme.foreground
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSizeCaption; weight: Font.Medium }
            }
        }

        Rectangle {
            Layout.alignment: Qt.AlignHCenter
            width: 16
            height: 1
            color: Commons.Theme.foregroundMuted
            opacity: Commons.Config.statsSeparatorOpacity
        }

        ColumnLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: 2

            Text {
                Layout.alignment: Qt.AlignHCenter
                text: "\uefc5"
                color: Commons.Theme.primary
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.iconSize; weight: Font.DemiBold }
            }
            Text {
                Layout.alignment: Qt.AlignHCenter
                text: systemStats.memUsed.toFixed(1) + "G"
                color: Commons.Theme.foreground
                font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSizeCaption; weight: Font.Medium }
            }
        }
    }
}
