import QtQuick
import Quickshell
import qs.Config
import qs.Services
import qs.Widgets
import qs.Modules.Popups

Surface {
    id: root

    property int spacing: Theme.spacingXs
    property BarPopup popup: null
    property string ipcName: ""

    default property alias content: layout.data

    readonly property bool vertical: Settings.barVertical
    readonly property bool onFocusedScreen: QsWindow.window?.screen === Compositor.focusedScreen

    accent: Theme.primary
    implicitWidth: vertical ? 36 : layout.implicitWidth + Theme.spacingSm * 2
    implicitHeight: vertical ? layout.implicitHeight + Theme.spacingSm : Theme.controlHeightBar

    Grid {
        id: layout

        anchors.centerIn: parent
        flow: root.vertical ? Grid.TopToBottom : Grid.LeftToRight
        columns: root.vertical ? 1 : -1
        rows: root.vertical ? -1 : 1
        spacing: root.spacing
        horizontalItemAlignment: Grid.AlignHCenter
        verticalItemAlignment: Grid.AlignVCenter
    }

    Binding {
        target: root.popup
        property: "anchorWindow"
        value: QsWindow.window
        when: root.popup !== null
    }

    Connections {
        target: Popups
        enabled: root.ipcName !== "" && root.popup !== null && root.onFocusedScreen

        function onRequested(name: string, action: string): void {
            if (name !== root.ipcName)
                return;
            root.popup.request(action);
        }
    }
}
