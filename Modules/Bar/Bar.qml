import QtQuick
import Quickshell
import Quickshell.Wayland
import qs.Config

Variants {
    model: Quickshell.screens

    PanelWindow {
        id: bar

        required property var modelData

        readonly property bool vertical: Settings.barVertical
        readonly property string position: Settings.barPosition
        readonly property int edgeMargin: Theme.spacingXs

        screen: modelData
        color: Theme.background
        implicitWidth: vertical ? 44 : 0
        implicitHeight: vertical ? 0 : 34

        WlrLayershell.layer: WlrLayer.Top
        WlrLayershell.namespace: "basedgoose-bar"

        anchors {
            top: bar.position !== "bottom"
            bottom: bar.position !== "top"
            left: bar.position !== "right"
            right: bar.position !== "left"
        }

        Rectangle {
            color: Theme.border
            width: bar.vertical ? 1 : parent.width
            height: bar.vertical ? parent.height : 1
            x: bar.position === "left" ? parent.width - 1 : 0
            y: bar.position === "top" ? parent.height - 1 : 0
        }

        BarSection {
            modules: Settings.barModules.left ?? []
            x: bar.vertical ? (bar.width - width) / 2 : bar.edgeMargin
            y: bar.vertical ? bar.edgeMargin : (bar.height - height) / 2
        }

        BarSection {
            modules: Settings.barModules.center ?? []
            x: (bar.width - width) / 2
            y: (bar.height - height) / 2
        }

        BarSection {
            modules: Settings.barModules.right ?? []
            x: bar.vertical ? (bar.width - width) / 2 : bar.width - width - bar.edgeMargin
            y: bar.vertical ? bar.height - height - bar.edgeMargin : (bar.height - height) / 2
        }
    }
}
