import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Modules.Bar
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "calendar"

    onClicked: popupWindow.toggle()

    SystemClock {
        id: clock
        precision: SystemClock.Minutes
    }

    GridLayout {
        flow: root.vertical ? GridLayout.TopToBottom : GridLayout.LeftToRight
        rows: root.vertical ? -1 : 1
        columns: root.vertical ? 1 : -1
        rowSpacing: 0
        columnSpacing: Theme.spacingXs

        StyledText {
            Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignBaseline
            text: Qt.formatDateTime(clock.date, "HH:mm")
            font.pixelSize: root.vertical ? Theme.fontCaption : Theme.fontNormal
            font.weight: Font.DemiBold
            color: root.hovered ? Theme.primary : Theme.text
        }

        StyledText {
            Layout.alignment: root.vertical ? Qt.AlignHCenter : Qt.AlignBaseline
            text: Qt.formatDateTime(clock.date, root.vertical ? "ddd" : "ddd MMM d")
            font.pixelSize: root.vertical ? Theme.fontTiny : Theme.fontCaption
            color: Theme.textMuted
        }
    }

    CalendarPopup {
        id: popupWindow
        anchorItem: root
    }
}
