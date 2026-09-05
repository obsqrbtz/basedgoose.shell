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
    scrollable: true

    onClicked: popupWindow.toggle()
    onRightClicked: Audio.toggleMute()
    onScrolled: steps => Audio.step(steps * 0.05)

    Icon {
        text: Icons.volumeLevel(Audio.percent, Audio.muted)
        color: root.hovered ? Theme.primary : Audio.muted ? Theme.textMuted : Theme.text
    }

    StyledText {
        text: `${Audio.percent}%`
        font.pixelSize: Theme.fontSmall
        color: Theme.textMuted
        visible: !Audio.muted
    }

    VolumePopup {
        id: popupWindow
        anchorItem: root
    }
}
