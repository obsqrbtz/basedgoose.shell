import QtQuick
import "../../Services" as Services
import "../../Commons" as Commons

Item {
    id: root

    property var barWindow
    property var calendarPopup
    property bool isVertical: false

    readonly property bool isHovered: mouseArea.containsMouse
    property string currentTime: Qt.formatDateTime(new Date(), "HH:mm")
    property string currentDate: Qt.formatDateTime(new Date(), "ddd MMM d")

    implicitWidth: isVertical ? Commons.Config.barWidth - Commons.Config.barPadding * 2 - 4 : clockColH.implicitWidth + Commons.Config.componentPadding * 2
    implicitHeight: isVertical ? clockColV.implicitHeight : Commons.Config.componentHeight
    width: parent ? parent.width : implicitWidth
    height: parent ? parent.height : implicitHeight

    Rectangle {
        anchors.fill: parent
        radius: Commons.Theme.radiusLg
        color: Commons.Theme.primary
        opacity: isHovered ? Commons.Theme.stateLayerHover : 0.0
        Behavior on opacity { NumberAnimation { duration: Commons.Theme.animNormal } }
    }

    Row {
        id: clockColH
        anchors.centerIn: parent
        spacing: 6
        visible: !isVertical

        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: isHovered ? Commons.Theme.primary : Commons.Theme.foreground
            font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSize; weight: Font.DemiBold }
            text: root.currentTime
            Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
        }
        Text {
            anchors.verticalCenter: parent.verticalCenter
            color: Commons.Theme.foregroundMuted
            font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSizeCaption; weight: Font.Normal }
            text: root.currentDate
        }
    }

    Column {
        id: clockColV
        anchors.centerIn: parent
        spacing: 2
        visible: isVertical

        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: isHovered ? Commons.Theme.primary : Commons.Theme.foreground
            font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSizeCaption; weight: Font.DemiBold }
            text: root.currentTime
            Behavior on color { ColorAnimation { duration: Commons.Theme.animNormal } }
        }
        Text {
            anchors.horizontalCenter: parent.horizontalCenter
            color: Commons.Theme.foregroundMuted
            font { family: Commons.Theme.fontMono; pixelSize: Commons.Theme.fontSizeTiny; weight: Font.Normal }
            text: Qt.formatDateTime(new Date(), "ddd")
        }
    }

    Timer {
        interval: Commons.Config.clockUpdateInterval
        running: true
        repeat: true
        onTriggered: {
            root.currentTime = Qt.formatDateTime(new Date(), "HH:mm")
            root.currentDate = Qt.formatDateTime(new Date(), "ddd MMM d")
        }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        cursorShape: Qt.PointingHandCursor

        onClicked: {
            if (calendarPopup && barWindow) {
                if (!calendarPopup.shouldShow) {
                    calendarPopup.positionNear(root, barWindow)
                }
                calendarPopup.shouldShow = !calendarPopup.shouldShow
            }
        }
    }
}
