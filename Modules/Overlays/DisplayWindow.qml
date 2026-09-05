import QtQuick
import QtQuick.Layouts
import qs.Config
import qs.Services
import qs.Widgets

OverlayWindow {
    id: root

    property string selected: ""

    readonly property var current: Displays.draft.find(o => o.name === root.selected) ?? Displays.draft[0] ?? null

    open: Overlays.displays
    onCloseRequested: Overlays.displays = false
    onOpenChanged: if (open) Displays.refresh()

    contentWidth: 780
    contentHeight: 620

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        PanelHeader {
            Layout.fillWidth: true
            icon: Icons.display
            title: "Displays"
            closable: true
            onCloseRequested: root.closeRequested()

            StyledText {
                text: Compositor.displayName
                font.pixelSize: Theme.fontSmall
                color: Theme.textMuted
            }
        }

        StyledText {
            Layout.fillWidth: true
            text: Displays.error
            color: Theme.error
            font.pixelSize: Theme.fontSmall
            visible: Displays.error !== ""
        }

        LayoutPreview {
            Layout.fillWidth: true
            Layout.preferredHeight: 200
        }

        RowLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            spacing: Theme.spacingMd

            ScrollList {
                Layout.preferredWidth: 220
                Layout.fillHeight: true
                model: Displays.draft

                delegate: ListRow {
                    required property var modelData

                    width: ListView.view.width
                    icon: Icons.display
                    title: modelData.name
                    subtitle: modelData.enabled ? `${modelData.width}×${modelData.height}` : "Off"
                    active: modelData.name === root.current?.name
                    onClicked: root.selected = modelData.name

                    Toggle {
                        checked: modelData.enabled
                        onToggled: checked => Displays.edit(modelData.name, { enabled: checked })
                    }
                }
            }

            ColumnLayout {
                Layout.fillWidth: true
                Layout.fillHeight: true
                spacing: Theme.spacingSm
                visible: root.current !== null

                SectionLabel { text: root.current?.description ?? "" }

                Field {
                    label: "Mode"
                    options: [...new Set((root.current?.modes ?? []).map(m => `${m.width}x${m.height}@${m.refresh}`))]
                    value: root.current ? `${root.current.width}x${root.current.height}@${root.current.refresh}` : ""
                    onPicked: option => {
                        const [size, refresh] = option.split("@");
                        const [width, height] = size.split("x");
                        Displays.edit(root.current.name, { width: +width, height: +height, refresh: +refresh });
                    }
                }

                Field {
                    label: "Scale"
                    options: ["1", "1.25", "1.5", "1.75", "2"]
                    value: String(root.current?.scale ?? 1)
                    onPicked: option => Displays.edit(root.current.name, { scale: +option })
                }

                Field {
                    label: "Rotation"
                    options: Compositor.transforms
                    value: root.current?.transform ?? "normal"
                    onPicked: option => Displays.edit(root.current.name, { transform: option })
                }

                Field {
                    label: "Mirror"
                    options: ["none"].concat(Displays.draft.filter(o => o.name !== root.current?.name).map(o => o.name))
                    value: root.current?.mirror || "none"
                    onPicked: option => Displays.edit(root.current.name, { mirror: option === "none" ? "" : option })
                }

                Item { Layout.fillHeight: true }

                Button {
                    Layout.fillWidth: true
                    label: "Arrange side by side"
                    variant: Button.Outlined
                    onClicked: Displays.arrangeHorizontally()
                }
            }
        }

        Divider { Layout.fillWidth: true }

        RowLayout {
            Layout.fillWidth: true
            spacing: Theme.spacingSm

            ColumnLayout {
                Layout.fillWidth: true
                spacing: 0

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Theme.spacingXs

                    StyledText {
                        Layout.fillWidth: true
                        text: Displays.configPath ? `Saves to ${Displays.configPath}` : "No config file set for this compositor"
                        font.pixelSize: Theme.fontSmall
                        color: Displays.configPath ? Theme.textMuted : Theme.warning
                        elide: Text.ElideMiddle
                    }

                    IconButton {
                        icon: Icons.folder
                        size: Theme.controlHeightSmall
                        enabled: Dialogs.available
                        onClicked: Dialogs.pickFile("Output config file", path => Settings.outputConfigPath = path)
                    }
                }

                StyledText {
                    Layout.fillWidth: true
                    text: Compositor.outputConfigHint
                    font.pixelSize: Theme.fontSmall
                    color: Theme.textMuted
                    wrapMode: Text.Wrap
                }
            }

            Button {
                label: "Save to config"
                variant: Button.Outlined
                enabled: Displays.configPath !== ""
                onClicked: Displays.persist()
            }

            Button {
                label: "Discard"
                variant: Button.Outlined
                enabled: Displays.hasChanges
                onClicked: Displays.discard()
            }

            Button {
                label: "Apply"
                variant: Button.Filled
                enabled: Displays.hasChanges
                onClicked: Displays.apply()
            }
        }
    }

    component LayoutPreview: Rectangle {
        id: preview

        readonly property var enabled_: Displays.draft.filter(o => o.enabled)
        readonly property real span: Math.max(1, ...enabled_.map(o => o.x + o.width / o.scale), ...enabled_.map(o => o.y + o.height / o.scale))
        readonly property real factor: Math.min(width, height) / (span * 1.15)

        color: Theme.surface
        radius: Theme.radiusPanel
        border.width: 1
        border.color: Theme.borderSubtle
        clip: true

        Repeater {
            model: preview.enabled_

            Surface {
                id: box

                required property var modelData

                x: modelData.x * preview.factor + Theme.spacingSm
                y: modelData.y * preview.factor + Theme.spacingSm
                width: modelData.width / modelData.scale * preview.factor
                height: modelData.height / modelData.scale * preview.factor

                interactive: false
                radius: Theme.radiusPanel
                baseColor: modelData.name === root.current?.name ? Theme.primaryMuted : Theme.surfaceAlt
                border.width: 1
                border.color: modelData.name === root.current?.name ? Theme.primary : Theme.border

                StyledText {
                    anchors.centerIn: parent
                    text: box.modelData.name
                    font.pixelSize: Theme.fontNormal
                    horizontalAlignment: Text.AlignHCenter
                }

                MouseArea {
                    anchors.fill: parent
                    drag.target: box
                    cursorShape: Qt.SizeAllCursor

                    onPressed: root.selected = box.modelData.name
                    onReleased: Displays.edit(box.modelData.name, {
                        x: Math.round((box.x - Theme.spacingSm) / preview.factor),
                        y: Math.round((box.y - Theme.spacingSm) / preview.factor)
                    })
                }
            }
        }
    }

    component Field: RowLayout {
        id: field

        property string label: ""
        property var options: []
        property string value: ""

        signal picked(string option)

        Layout.fillWidth: true
        spacing: Theme.spacingSm

        SectionLabel {
            Layout.preferredWidth: 70
            text: field.label
        }

        Button {
            Layout.fillWidth: true
            variant: Button.Outlined
            label: field.value
            enabled: field.options.length > 1
            onClicked: {
                const at = field.options.indexOf(field.value);
                field.picked(field.options[(at + 1) % field.options.length]);
            }
        }
    }
}
