import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "media"

    visible: Players.hasPlayer
    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: popupWindow.toggle()
    onRightClicked: Players.playPause()

    Icon {
        text: Players.playing ? Icons.play : Icons.pause
        color: root.hovered ? Theme.primary : Theme.textMuted
    }

    StyledText {
        text: Players.title
        maximumLineCount: 1
        width: Math.min(implicitWidth, 160)
        font.pixelSize: Theme.fontSmall
        color: root.hovered ? Theme.primary : Theme.text
        visible: !root.vertical
    }

    MediaPopup {
        id: popupWindow
        anchorItem: root
    }
}
