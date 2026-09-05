import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import qs.Config
import qs.Services
import qs.Widgets

OverlayWindow {
    id: root

    readonly property var tabs: [
        { label: "Saved", icon: Icons.folder },
        { label: "Downloaded", icon: Icons.download },
        { label: "Wallhaven", icon: Icons.search }
    ]

    property int tab: 0

    open: Overlays.wallpapers
    onCloseRequested: Overlays.wallpapers = false

    contentWidth: 900
    contentHeight: 640

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.image
            title: "Wallpapers"
            closable: true
            onCloseRequested: root.closeRequested()

            StyledText {
                text: Wallpapers.backend ? `via ${Wallpapers.backend}` : "no wallpaper daemon found"
                font.pixelSize: Theme.fontSmall
                color: Wallpapers.backend ? Theme.textMuted : Theme.error
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Tabs {
                model: root.tabs
                currentIndex: root.tab
                onCurrentIndexChanged: root.tab = currentIndex
            }

            Item { Layout.fillWidth: true }

            TextField {
                Layout.preferredWidth: 220
                icon: Icons.search
                placeholder: "Search Wallhaven"
                visible: root.tab === 2
                onAccepted: text => {
                    Wallhaven.query = text;
                    Wallhaven.setPage(1);
                }
            }

            Button {
                icon: Icons.refresh
                label: "Reload"
                variant: Button.Outlined
                visible: root.tab === 2
                onClicked: Wallhaven.search()
            }
        }

        Divider { Layout.fillWidth: true }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.tab < 2
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 200)))
            cellHeight: cellWidth * 0.68

            model: root.tab === 0 ? Wallpapers.saved : Wallpapers.downloaded

            delegate: Thumbnail {
                required property string filePath
                required property string fileName

                source: `file://${filePath}`
                caption: fileName
                current: Wallpapers.current === filePath
                onClicked: Wallpapers.apply(filePath)
                onSecondary: Wallpapers.remove(filePath)
                secondaryIcon: Icons.trash
            }

            EmptyState {
                anchors.centerIn: parent
                icon: Icons.folder
                title: "Nothing here yet"
                hint: root.tab === 0 ? Settings.wallpaperDir : Settings.wallpaperDownloadDir
                visible: parent.count === 0
            }
        }

        GridView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            visible: root.tab === 2
            clip: true
            reuseItems: true
            boundsBehavior: Flickable.StopAtBounds
            cellWidth: Math.floor(width / Math.max(1, Math.floor(width / 200)))
            cellHeight: cellWidth * 0.68

            model: Wallhaven.results

            delegate: Thumbnail {
                required property var modelData

                source: modelData.thumbUrl
                caption: modelData.resolution
                busy: Wallhaven.downloading
                onClicked: Wallhaven.download(modelData.id, modelData.fullUrl, true)
                onSecondary: Wallhaven.download(modelData.id, modelData.fullUrl, false)
                secondaryIcon: Icons.download
            }
        }

        RowLayout {
            Layout.alignment: Qt.AlignHCenter
            spacing: Theme.spacingSm
            visible: root.tab === 2

            IconButton {
                icon: Icons.chevronDown
                rotation: 90
                enabled: Wallhaven.page > 1
                onClicked: Wallhaven.setPage(Wallhaven.page - 1)
            }

            StyledText {
                text: `${Wallhaven.page} / ${Wallhaven.lastPage}`
                font.pixelSize: Theme.fontNormal
                color: Theme.text
            }

            IconButton {
                icon: Icons.chevronRight
                enabled: Wallhaven.page < Wallhaven.lastPage
                onClicked: Wallhaven.setPage(Wallhaven.page + 1)
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: Wallhaven.error
            color: Theme.error
            font.pixelSize: Theme.fontSmall
            horizontalAlignment: Text.AlignHCenter
            visible: root.tab === 2 && Wallhaven.error !== ""
        }
    }

    onTabChanged: {
        if (tab === 2 && Wallhaven.results.length === 0)
            Wallhaven.search();
    }

    component Thumbnail: Surface {
        id: thumb

        property alias source: image.source
        property string caption: ""
        property bool current: false
        property bool busy: false
        property string secondaryIcon: ""

        signal secondary

        width: GridView.view.cellWidth - Theme.spacingXs
        height: GridView.view.cellHeight - Theme.spacingXs
        accent: Theme.primary
        baseColor: Theme.surface
        border.width: 2
        border.color: current ? Theme.primary : "transparent"
        radius: Theme.radiusPanel
        acceptedButtons: Qt.LeftButton | Qt.RightButton
        onRightClicked: thumb.secondary()

        ClippingRectangle {
            anchors.fill: parent
            anchors.margins: thumb.border.width
            radius: Theme.radiusPanel
            color: "transparent"

            Image {
                id: image
                anchors.fill: parent
                fillMode: Image.PreserveAspectCrop
                asynchronous: true
                cache: false
                sourceSize.width: 400
            }
        }

        Rectangle {
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.bottom: parent.bottom
            anchors.margins: thumb.border.width
            height: 20
            color: Theme.alpha(Theme.background, 0.85)
            visible: thumb.hovered || thumb.current

            StyledText {
                anchors.fill: parent
                anchors.leftMargin: Theme.spacingXs
                anchors.rightMargin: Theme.spacingXs
                text: thumb.caption
                font.pixelSize: Theme.fontSmall
                verticalAlignment: Text.AlignVCenter
            }
        }

        Icon {
            anchors.top: parent.top
            anchors.right: parent.right
            anchors.margins: Theme.spacingXs
            text: thumb.secondaryIcon
            color: Theme.text
            visible: thumb.hovered && thumb.secondaryIcon !== ""
        }
    }
}
