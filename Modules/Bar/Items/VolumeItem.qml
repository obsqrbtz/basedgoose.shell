import QtQuick
import qs.Config
import qs.Modules.Bar
import qs.Services
import qs.Widgets
import qs.Modules.Popups

BarItem {
    id: root

    popup: popupWindow
    ipcName: "volume"

    acceptedButtons: Qt.LeftButton | Qt.RightButton

    onClicked: popupWindow.toggle()
    onRightClicked: Audio.toggleMute()

    Icon {
        text: Icons.volumeLevel(Audio.percent, Audio.muted)
        color: root.hovered ? Theme.primary : Audio.muted ? Theme.textMuted : Theme.text
    }

    StyledText {
        text: `${Audio.percent}%`
        font.pixelSize: root.vertical ? Theme.fontTiny : Theme.fontCaption
        color: Theme.textMuted
        visible: !Audio.muted
    }

    VolumePopup {
        id: popupWindow
        anchorItem: root
    }
}
