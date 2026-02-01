import QtQuick 6.10
import QtQuick.Layouts 6.10
import QtQuick.Effects
import Quickshell
import "../../Commons" as Commons
import "../../Widgets" as Widgets
import "../../Services" as Services

Widgets.PopupWindow {
    id: popupWindow

    ipcTarget: "settings"
    initialScale: 0.94
    transformOriginX: 0.5
    transformOriginY: 0.5
    closeOnClickOutside: false

    anchors {
        top: true
        left: true
    }

    margins {
        top: Quickshell.screens[0] ? (Quickshell.screens[0].height - implicitHeight) / 2 : 100
        left: Quickshell.screens[0] ? (Quickshell.screens[0].width - implicitWidth) / 2 : 100
    }

    readonly property color cSurface: Commons.Theme.background
    readonly property color cSurfaceContainer: Qt.lighter(Commons.Theme.background, 1.15)
    readonly property color cPrimary: Commons.Theme.secondary
    readonly property color cText: Commons.Theme.foreground
    readonly property color cSubText: Qt.rgba(cText.r, cText.g, cText.b, 0.6)
    readonly property color cBorder: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
    readonly property color cHover: Qt.rgba(cText.r, cText.g, cText.b, 0.06)

    implicitWidth: 600
    implicitHeight: 640

    property Component moduleChipComponent: Component {
        Item {
            id: chipContainer

            property string moduleName: ""
            property bool isDraggable: true
            property string sourceSection: ""
            property color chipColor: Qt.rgba(popupWindow.cText.r, popupWindow.cText.g, popupWindow.cText.b, 0.08)
            property color chipBorderColor: Qt.rgba(popupWindow.cText.r, popupWindow.cText.g, popupWindow.cText.b, 0.2)
            property color chipTextColor: popupWindow.cText

            implicitWidth: chipText.implicitWidth + 20
            implicitHeight: 28
            width: implicitWidth
            height: implicitHeight

            Rectangle {
                id: chip
                anchors.fill: parent
                radius: Commons.Theme.radius - 2
                color: chipContainer.chipColor
                border.color: chipContainer.chipBorderColor
                border.width: 1
                opacity: dragArea.pressed ? 0.5 : 1

                Text {
                    id: chipText
                    anchors.centerIn: parent
                    text: chipContainer.moduleName
                    font.family: Commons.Theme.fontMono
                    font.pixelSize: 11
                    color: chipContainer.chipTextColor
                }
            }

            MouseArea {
                id: dragArea
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor

                drag.target: chipContainer.isDraggable ? dragItem : null

                Item {
                    id: dragItem
                    visible: dragArea.drag.active

                    Drag.active: dragArea.drag.active
                    Drag.dragType: Drag.Automatic
                    Drag.supportedActions: Qt.MoveAction
                    Drag.keys: ["text/plain"]
                    Drag.mimeData: {
                        "text/plain": "module:" + chipContainer.moduleName + ":" + chipContainer.sourceSection
                    }

                    Rectangle {
                        width: chipContainer.width
                        height: chipContainer.height
                        radius: chip.radius
                        color: chipContainer.chipColor
                        border.color: chipContainer.chipBorderColor
                        border.width: 1
                        opacity: 0.8

                        Text {
                            anchors.centerIn: parent
                            text: chipContainer.moduleName
                            font.family: Commons.Theme.fontMono
                            font.pixelSize: 11
                            color: chipContainer.chipTextColor
                        }
                    }
                }
            }
        }
    }

    function addModuleToSection(moduleName, section) {
        var updatedBarModules = Object.assign({}, Services.ConfigService.barModules)
        if (!updatedBarModules[section]) {
            updatedBarModules[section] = []
        }
        if (updatedBarModules[section].indexOf(moduleName) === -1) {
            updatedBarModules[section].push(moduleName)
            Services.ConfigService.setBarModules(updatedBarModules)
        }
    }

    function removeModuleFromSection(moduleName, section) {
        var updatedBarModules = Object.assign({}, Services.ConfigService.barModules)
        if (updatedBarModules[section]) {
            var index = updatedBarModules[section].indexOf(moduleName)
            if (index !== -1) {
                updatedBarModules[section].splice(index, 1)
                Services.ConfigService.setBarModules(updatedBarModules)
            }
        }
    }

    Rectangle {
        id: backgroundRect
        anchors.fill: parent
        color: Commons.Theme.background
        radius: Commons.Theme.radius * 2
        border.color: cBorder
        border.width: 1

        layer.enabled: true
        layer.effect: MultiEffect {
            shadowEnabled: true
            shadowColor: Qt.rgba(0, 0, 0, 0.35)
            shadowBlur: 1.0
            shadowVerticalOffset: 6
        }

        ColumnLayout {
            id: contentColumn
            anchors.fill: parent
            anchors.margins: 16
            spacing: 16

            Widgets.HeaderWithIcon {
                Layout.fillWidth: true
                icon: "\uf013"
                title: "Settings"
                subtitle: "Configure basedgoose.shell"
                iconColor: cPrimary
                titleColor: cText
                subtitleColor: cSubText
            }

            Widgets.Divider {
                Layout.fillWidth: true
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                radius: 12
                color: cSurfaceContainer
                clip: true

                Flickable {
                    id: settingsFlickable
                    anchors.fill: parent
                    anchors.margins: 16
                    contentWidth: width
                    contentHeight: settingsColumn.height
                    boundsBehavior: Flickable.StopAtBounds
                    clip: true

                    ColumnLayout {
                        id: settingsColumn
                        width: settingsFlickable.width
                        spacing: 20

                        // Bar Position Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 8

                            Widgets.SectionLabel {
                                Layout.fillWidth: true
                                text: "Bar Position"
                                color: cText
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Choose where the bar appears on your screen"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cSubText
                                wrapMode: Text.WordWrap
                            }

                            RowLayout {
                                Layout.fillWidth: true
                                spacing: 8

                                Repeater {
                                    model: [
                                        { value: "top", label: "Top" },
                                        { value: "bottom", label: "Bottom" },
                                        { value: "left", label: "Left" },
                                        { value: "right", label: "Right" }
                                    ]

                                    delegate: Rectangle {
                                        Layout.fillWidth: true
                                        Layout.preferredHeight: 44
                                        radius: Commons.Theme.radius
                                        color: Services.ConfigService.barPosition === modelData.value ? 
                                               Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15) : 
                                               Qt.rgba(cText.r, cText.g, cText.b, 0.03)
                                        border.color: Services.ConfigService.barPosition === modelData.value ? 
                                                     cPrimary : 
                                                     Qt.rgba(cText.r, cText.g, cText.b, 0.1)
                                        border.width: Services.ConfigService.barPosition === modelData.value ? 2 : 1

                                        Text {
                                            anchors.centerIn: parent
                                            text: modelData.label
                                            font.family: Commons.Theme.fontUI
                                            font.pixelSize: 13
                                            color: Services.ConfigService.barPosition === modelData.value ? 
                                                   cText : cSubText
                                        }

                                        MouseArea {
                                            anchors.fill: parent
                                            cursorShape: Qt.PointingHandCursor
                                            onClicked: {
                                                Services.ConfigService.setBarPosition(modelData.value)
                                                Quickshell.reload(true)
                                            }
                                        }
                                    }
                                }
                            }
                        }

                        // Bar Modules Section
                        ColumnLayout {
                            Layout.fillWidth: true
                            spacing: 12

                            Widgets.SectionLabel {
                                Layout.fillWidth: true
                                text: "Bar Modules"
                                color: cText
                            }

                            Text {
                                Layout.fillWidth: true
                                text: "Drag and drop modules to arrange them in the bar"
                                font.family: Commons.Theme.fontUI
                                font.pixelSize: 12
                                color: cSubText
                                wrapMode: Text.WordWrap
                            }

                            // Available modules
                            ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 6

                                Text {
                                    text: "Available Modules"
                                    font.family: Commons.Theme.fontUI
                                    font.pixelSize: 13
                                    font.weight: Font.Medium
                                    color: cText
                                }

                                Rectangle {
                                    id: modulePool
                                    Layout.fillWidth: true
                                    Layout.minimumHeight: 80
                                    radius: Commons.Theme.radius
                                    color: Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.08)
                                    border.color: Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.2)
                                    border.width: 1

                                    property var availableModules: ["shellmenu", "workspaces", "mediaplayer", "systemstats", "clock", "systemtray", "volume", "bluetooth", "notifications", "power"]
                                    property var usedModules: {
                                        var used = []
                                        if (Services.ConfigService.barModules.left) used = used.concat(Services.ConfigService.barModules.left)
                                        if (Services.ConfigService.barModules.center) used = used.concat(Services.ConfigService.barModules.center)
                                        if (Services.ConfigService.barModules.right) used = used.concat(Services.ConfigService.barModules.right)
                                        return used
                                    }

                                    Flow {
                                        anchors.fill: parent
                                        anchors.margins: 8
                                        spacing: 6

                                        Repeater {
                                            model: modulePool.availableModules.filter(function(m) {
                                                return modulePool.usedModules.indexOf(m) === -1
                                            })

                                            delegate: Loader {
                                                sourceComponent: moduleChipComponent

                                                property string moduleName: modelData
                                                property bool isDraggable: true
                                                property color chipColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                                                property color chipBorderColor: cPrimary
                                                property color chipTextColor: cText

                                                onLoaded: {
                                                    item.moduleName = moduleName
                                                    item.isDraggable = isDraggable
                                                    item.chipColor = chipColor
                                                    item.chipBorderColor = chipBorderColor
                                                    item.chipTextColor = chipTextColor
                                                }
                                            }
                                        }
                                    }

                                    DropArea {
                                        anchors.fill: parent
                                        keys: ["text/plain"]

                                        onDropped: function(drop) {
                                            console.log("[Drop] Pool received drop")
                                            var text = drop.getDataAsString("text/plain")
                                            console.log("[Drop] Data:", text)
                                            
                                            if (text.startsWith("module:")) {
                                                var parts = text.split(":")
                                                if (parts.length >= 3) {
                                                    var moduleName = parts[1]
                                                    var sourceSection = parts[2]
                                                    console.log("[Drop] Removing module:", moduleName, "from:", sourceSection)
                                                    if (sourceSection !== "") {
                                                        popupWindow.removeModuleFromSection(moduleName, sourceSection)
                                                    }
                                                    drop.accept()
                                                }
                                            }
                                        }
                                    }
                                }
                            }

                            // Bar sections
                            Repeater {
                                model: ["left", "center", "right"]

                                delegate: ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 6

                                    property string sectionName: modelData

                                    Text {
                                        text: modelData.charAt(0).toUpperCase() + modelData.slice(1) + ":"
                                        font.family: Commons.Theme.fontUI
                                        font.pixelSize: 13
                                        font.weight: Font.Medium
                                        color: cText
                                    }

                                    Rectangle {
                                        Layout.fillWidth: true
                                        Layout.minimumHeight: 50
                                        radius: Commons.Theme.radius
                                        color: dropArea.containsDrag ? 
                                               Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15) :
                                               Qt.rgba(cText.r, cText.g, cText.b, 0.03)
                                        border.color: dropArea.containsDrag ?
                                                     cPrimary :
                                                     Qt.rgba(cText.r, cText.g, cText.b, 0.1)
                                        border.width: dropArea.containsDrag ? 2 : 1

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                        Behavior on border.width { NumberAnimation { duration: 150 } }

                                        Flow {
                                            id: moduleFlow
                                            anchors.fill: parent
                                            anchors.margins: 8
                                            spacing: 6

                                            Repeater {
                                                model: Services.ConfigService.barModules[sectionName] || []

                                                delegate: Loader {
                                                    sourceComponent: moduleChipComponent

                                                    property string moduleName: modelData
                                                    property bool isDraggable: true
                                                    property string sourceSection: sectionName
                                                    property color chipColor: Qt.rgba(cText.r, cText.g, cText.b, 0.08)
                                                    property color chipBorderColor: Qt.rgba(cText.r, cText.g, cText.b, 0.2)
                                                    property color chipTextColor: cText

                                                    onLoaded: {
                                                        item.moduleName = moduleName
                                                        item.isDraggable = isDraggable
                                                        item.sourceSection = sourceSection
                                                        item.chipColor = chipColor
                                                        item.chipBorderColor = chipBorderColor
                                                        item.chipTextColor = chipTextColor
                                                    }
                                                }
                                            }

                                            Text {
                                                visible: moduleFlow.children.length === 1
                                                text: "Drop modules here"
                                                font.family: Commons.Theme.fontUI
                                                font.pixelSize: 11
                                                color: cSubText
                                                anchors.verticalCenter: parent.verticalCenter
                                            }
                                        }

                                        DropArea {
                                            id: dropArea
                                            anchors.fill: parent
                                            keys: ["text/plain"]

                                            onDropped: function(drop) {
                                                console.log("[Drop] Section", sectionName, "received drop")
                                                var text = drop.getDataAsString("text/plain")
                                                console.log("[Drop] Data:", text)
                                                
                                                if (text.startsWith("module:")) {
                                                    var parts = text.split(":")
                                                    if (parts.length >= 3) {
                                                        var moduleName = parts[1]
                                                        var sourceSection = parts[2]
                                                        console.log("[Drop] Moving module:", moduleName, "from:", sourceSection, "to:", sectionName)
                                                        
                                                        if (sourceSection !== "" && sourceSection !== sectionName) {
                                                            popupWindow.removeModuleFromSection(moduleName, sourceSection)
                                                        }
                                                        
                                                        if (sourceSection !== sectionName) {
                                                            popupWindow.addModuleToSection(moduleName, sectionName)
                                                        }
                                                        drop.accept()
                                                    }
                                                }
                                            }

                                            onEntered: function(drag) {
                                                console.log("[Drop] Entered section:", sectionName)
                                            }

                                            onExited: {
                                                console.log("[Drop] Exited section:", sectionName)
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: 8

                Widgets.TextButton {
                    text: "Reload Shell"
                    baseColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.15)
                    textColor: cText
                    hoverColor: Qt.rgba(cPrimary.r, cPrimary.g, cPrimary.b, 0.25)
                    onClicked: {
                        Quickshell.reload(true)
                    }
                }

                Item {
                    Layout.fillWidth: true
                }

                Widgets.TextButton {
                    text: "Close"
                    baseColor: Qt.rgba(cText.r, cText.g, cText.b, 0.06)
                    textColor: cText
                    hoverColor: Qt.rgba(cText.r, cText.g, cText.b, 0.1)
                    onClicked: popupWindow.shouldShow = false
                }
            }
        }
    }
}
