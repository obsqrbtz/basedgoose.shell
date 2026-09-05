import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

OverlayWindow {
    id: root

    readonly property var tabs: [
        { label: "Appearance", icon: Icons.image },
        { label: "Bar", icon: Icons.menu },
        { label: "Wallpaper", icon: Icons.folder },
        { label: "Monitoring", icon: Icons.server }
    ]

    property int tab: 0

    open: Overlays.settings
    onCloseRequested: Overlays.settings = false

    contentWidth: 640
    contentHeight: 620

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.settings
            title: "Settings"
            closable: true
            onCloseRequested: root.closeRequested()

            StyledText {
                text: `${Compositor.displayName} · ${Settings.configDir}`
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }
        }

        Tabs {
            Layout.fillWidth: true
            model: root.tabs
            currentIndex: root.tab
            onCurrentIndexChanged: root.tab = currentIndex
        }

        Divider { Layout.fillWidth: true }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.tab

            AppearanceTab {}
            BarTab {}
            WallpaperTab {}
            MonitoringTab {}
        }
    }

    component AppearanceTab: Page {
        SectionLabel { text: "Colour scheme" }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Repeater {
                model: Schemes.available

                Surface {
                    id: swatch

                    required property var modelData

                    readonly property bool active: Settings.colorScheme === modelData.id

                    implicitWidth: 150
                    implicitHeight: 44
                    radius: Theme.radiusPanel
                    baseColor: modelData.colors.surfaceBase
                    border.width: 2
                    border.color: active ? modelData.colors.primary : modelData.colors.border
                    accent: modelData.colors.primary
                    onClicked: Settings.colorScheme = modelData.id

                    RowLayout {
                        anchors.fill: parent
                        anchors.margins: Theme.spacingSm
                        spacing: Theme.spacingSm

                        StyledText {
                            Layout.fillWidth: true
                            text: swatch.modelData.name
                            font.pixelSize: Theme.fontNormal
                            color: swatch.modelData.colors.foreground
                        }

                        Repeater {
                            model: [swatch.modelData.colors.primary, swatch.modelData.colors.secondary, swatch.modelData.colors.error]

                            Rectangle {
                                required property color modelData
                                width: 10
                                height: 10
                                radius: 5
                                color: modelData
                            }
                        }
                    }
                }
            }
        }

        Divider { Layout.fillWidth: true }

        SectionLabel { text: "Palette" }

        StyledText {
            Layout.fillWidth: true
            text: "Edit a colour, then save the result as a new scheme in your config directory."
            font.pixelSize: Theme.fontSmall
            color: Theme.textMuted
            wrapMode: Text.Wrap
        }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Repeater {
                model: Schemes.keys

                RowLayout {
                    id: entry

                    required property string modelData

                    width: 190
                    spacing: Theme.spacingSm

                    Rectangle {
                        width: 16
                        height: 16
                        radius: Theme.radius
                        color: Schemes.colors[entry.modelData]
                        border.width: 1
                        border.color: Theme.border
                    }

                    StyledText {
                        Layout.preferredWidth: 92
                        text: entry.modelData
                        font.pixelSize: Theme.fontSmall
                        color: Theme.textMuted
                    }

                    TextField {
                        Layout.fillWidth: true
                        implicitHeight: Theme.controlHeightSmall
                        text: String(Schemes.colors[entry.modelData]).toUpperCase()
                        inputItem.font.pixelSize: Theme.fontSmall
                        onAccepted: value => {
                            if (!Schemes.setColor(entry.modelData, value))
                                text = String(Schemes.colors[entry.modelData]).toUpperCase();
                        }
                    }
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            TextField {
                id: schemeName
                Layout.fillWidth: true
                placeholder: "New scheme name"
                onAccepted: text => Schemes.save(text)
            }

            Button {
                label: "Reset"
                variant: Button.Outlined
                enabled: Schemes.edited
                onClicked: Schemes.resetColors()
            }

            Button {
                label: "Save scheme"
                variant: Button.Filled
                enabled: schemeName.text !== ""
                onClicked: {
                    Schemes.save(schemeName.text);
                    schemeName.text = "";
                }
            }
        }
    }

    component BarTab: Page {
        id: barTab

        readonly property var known: ["menu", "workspaces", "media", "stats", "clock", "tray", "volume", "network", "bluetooth", "notifications", "power"]

        SectionLabel { text: "Position" }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Repeater {
                model: Settings.barPositions

                Button {
                    required property string modelData

                    Layout.fillWidth: true
                    label: modelData
                    variant: Button.Outlined
                    active: Settings.barPosition === modelData
                    onClicked: Settings.barPosition = modelData
                }
            }
        }

        Divider { Layout.fillWidth: true }

        SectionLabel { text: "Modules" }

        StyledText {
            Layout.fillWidth: true
            text: "Click a module to move it to the next section, or off the bar."
            font.pixelSize: Theme.fontSmall
            color: Theme.textMuted
            wrapMode: Text.Wrap
        }

        Repeater {
            model: ["left", "center", "right"]

            ColumnLayout {
                required property string modelData

                Layout.fillWidth: true
                spacing: Theme.spacingXs

                SectionLabel {
                    text: modelData
                    color: Theme.primary
                }

                Flow {
                    Layout.fillWidth: true
                    spacing: Theme.spacingXs

                    Repeater {
                        model: Settings.barModules[modelData] ?? []

                        Button {
                            required property string modelData

                            label: modelData
                            variant: Button.Filled
                            fontSize: Theme.fontSmall
                            onClicked: root.moveModule(modelData)
                        }
                    }
                }
            }
        }

        Divider { Layout.fillWidth: true }

        SectionLabel { text: "Not on the bar" }

        Flow {
            Layout.fillWidth: true
            spacing: Theme.spacingXs

            Repeater {
                model: barTab.known.filter(name => !root.sectionOf(name))

                Button {
                    required property string modelData

                    label: modelData
                    variant: Button.Outlined
                    fontSize: Theme.fontSmall
                    onClicked: root.moveModule(modelData)
                }
            }
        }
    }

    function sectionOf(name: string): string {
        for (const section of ["left", "center", "right"])
            if ((Settings.barModules[section] ?? []).includes(name))
                return section;
        return "";
    }

    function moveModule(name: string): void {
        const order = ["left", "center", "right", ""];
        const next = order[(order.indexOf(sectionOf(name)) + 1) % order.length];

        const modules = {};
        for (const section of ["left", "center", "right"]) {
            modules[section] = (Settings.barModules[section] ?? []).filter(m => m !== name);
            if (section === next)
                modules[section] = modules[section].concat([name]);
        }
        Settings.barModules = modules;
    }

    component WallpaperTab: Page {
        SectionLabel { text: "Library" }

        PathRow {
            label: "Wallpapers"
            value: Settings.wallpaperDir
            onPicked: path => Settings.wallpaperDir = path
        }

        PathRow {
            label: "Downloads"
            value: Settings.wallpaperDownloadDir
            onPicked: path => Settings.wallpaperDownloadDir = path
        }

        Divider { Layout.fillWidth: true }

        SectionLabel { text: "Fit" }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            Repeater {
                model: ["no", "crop", "fit", "stretch"]

                Button {
                    required property string modelData

                    Layout.fillWidth: true
                    label: modelData
                    variant: Button.Outlined
                    active: Settings.wallpaperResizeMode === modelData
                    onClicked: Settings.wallpaperResizeMode = modelData
                }
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: Wallpapers.backend ? `Using ${Wallpapers.backend}.` : "Install swww, awww or swaybg to set wallpapers."
            font.pixelSize: Theme.fontSmall
            color: Wallpapers.backend ? Theme.textMuted : Theme.warning
        }
    }

    component MonitoringTab: Page {
        SectionLabel { text: "Prometheus hosts" }

        StyledText {
            Layout.fillWidth: true
            text: "Each host needs Prometheus scraping a node_exporter. See docs/monitoring-servers.md."
            font.pixelSize: Theme.fontSmall
            color: Theme.textMuted
            wrapMode: Text.Wrap
        }

        Repeater {
            model: Settings.monitorServers

            ListRow {
                required property var modelData
                required property int index

                Layout.fillWidth: true
                interactive: false
                icon: Icons.server
                title: modelData.name
                subtitle: `${modelData.host}:${modelData.port}`

                IconButton {
                    icon: Icons.trash
                    size: Theme.controlHeight
                    onClicked: Settings.monitorServers = Settings.monitorServers.filter((_, i) => i !== index)
                }
            }
        }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            TextField {
                id: serverName
                Layout.fillWidth: true
                placeholder: "Name"
            }

            TextField {
                id: serverHost
                Layout.fillWidth: true
                placeholder: "Host"
            }

            TextField {
                id: serverPort
                Layout.preferredWidth: 70
                placeholder: "9090"
            }

            Button {
                label: "Add"
                variant: Button.Filled
                enabled: serverName.text !== "" && serverHost.text !== ""
                onClicked: {
                    Settings.monitorServers = Settings.monitorServers.concat([{
                        name: serverName.text,
                        host: serverHost.text,
                        port: serverPort.text || "9090"
                    }]);
                    serverName.text = serverHost.text = serverPort.text = "";
                }
            }
        }
    }

    component Page: Flickable {
        default property alias body: pageColumn.data

        contentHeight: pageColumn.implicitHeight
        clip: true
        boundsBehavior: Flickable.StopAtBounds

        ColumnLayout {
            id: pageColumn
            width: parent.width
            spacing: Theme.spacingSm
        }
    }

    component PathRow: RowLayout {
        id: pathRow

        property string label: ""
        property string value: ""

        signal picked(string path)

        Layout.fillWidth: true
        spacing: Theme.spacingSm

        SectionLabel {
            Layout.preferredWidth: 90
            text: pathRow.label
        }

        StyledText {
            Layout.fillWidth: true
            text: pathRow.value
            font.pixelSize: Theme.fontSmall
            color: Theme.textMuted
        }

        Button {
            label: "Change"
            variant: Button.Outlined
            enabled: Dialogs.available
            onClicked: Dialogs.pickDirectory(pathRow.label, path => pathRow.picked(path))
        }
    }
}
