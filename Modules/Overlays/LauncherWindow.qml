import QtQuick
import QtQuick.Layouts
import Quickshell
import qs.Config
import qs.Widgets

OverlayWindow {
    id: root

    property string filter: ""
    property int selected: 0

    readonly property var matches: {
        const needle = filter.trim().toLowerCase();
        const entries = DesktopEntries.applications.values.filter(e => !e.noDisplay);
        if (!needle)
            return entries.sort((a, b) => a.name.localeCompare(b.name));

        return entries
            .map(entry => {
                const haystacks = [entry.name, entry.genericName ?? "", ...(entry.keywords ?? [])].map(s => s.toLowerCase());
                if (haystacks.some(h => h.startsWith(needle)))
                    return { entry, rank: 0 };
                if (haystacks.some(h => h.includes(needle)))
                    return { entry, rank: 1 };
                return null;
            })
            .filter(m => m)
            .sort((a, b) => a.rank - b.rank || a.entry.name.localeCompare(b.entry.name))
            .map(m => m.entry);
    }

    open: Overlays.launcher
    onCloseRequested: Overlays.launcher = false

    contentWidth: 520
    contentHeight: 540

    onOpenChanged: {
        filter = "";
        selected = 0;
        if (open)
            search.forceFocus();
    }

    onMatchesChanged: selected = 0

    function launch(entry: DesktopEntry): void {
        Overlays.launcher = false;
        entry.execute();
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: Theme.spacingMd

        TextField {
            id: search
            Layout.fillWidth: true
            Layout.preferredHeight: 36
            icon: Icons.search
            placeholder: "Search applications"
            text: root.filter

            inputItem.onTextChanged: root.filter = inputItem.text

            Keys.onDownPressed: root.selected = Math.min(root.selected + 1, root.matches.length - 1)
            Keys.onUpPressed: root.selected = Math.max(root.selected - 1, 0)
            Keys.onReturnPressed: {
                if (root.matches[root.selected])
                    root.launch(root.matches[root.selected]);
            }
        }

        ScrollList {
            id: list
            Layout.fillWidth: true
            Layout.fillHeight: true
            model: root.matches
            currentIndex: root.selected
            highlightMoveDuration: Theme.animFast
            preferredHighlightBegin: 0
            preferredHighlightEnd: height
            highlightRangeMode: ListView.ApplyRange

            delegate: ListRow {
                required property DesktopEntry modelData
                required property int index

                width: ListView.view.width
                iconSource: Quickshell.iconPath(modelData.icon, true)
                title: modelData.name
                subtitle: modelData.genericName || modelData.comment
                active: index === root.selected
                onClicked: root.launch(modelData)
            }
        }

        EmptyState {
            Layout.fillWidth: true
            Layout.fillHeight: true
            icon: Icons.search
            title: "No matching applications"
            visible: root.matches.length === 0
        }
    }
}
