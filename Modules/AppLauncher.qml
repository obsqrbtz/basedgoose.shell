import Quickshell
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import "../Services" as Services
import "../Commons" as Commons

Commons.PopupWindow {
    id: appLauncher
    
    ipcTarget: "launcher"
    initialScale: 0.92
    transformOriginX: 0.5
    transformOriginY: 0.0
    closeOnClickOutside: true
    
    implicitWidth: 420
    implicitHeight: 200
    
    Rectangle {
        id: contentRect
        anchors.fill: parent
        color: Services.Theme.background
        radius: Services.Theme.radius
        border.color: Services.Theme.border
        border.width: 1
        
        Component {
            id: processComponent
            Process {
                property var cmd: []
                running: true
                command: cmd
            }
        }
        
        ListModel {
            id: appModel
        }
        
        ListModel {
            id: filteredModel
        }
        
        Process {
            id: appListProc
            running: true
            command: ["sh", "-c", "find /usr/share/applications ~/.local/share/applications -name '*.desktop' 2>/dev/null | while read f; do echo \"$(grep '^Name=' \"$f\" | cut -d'=' -f2 | head -1)|||$(grep '^Exec=' \"$f\" | cut -d'=' -f2- | head -1 | sed 's/%[uUfF]//g' | sed 's/  */ /g')\"; done"]
            
            stdout: StdioCollector {
                onStreamFinished: {
                    var output = text.trim();
                    var lines = output.split('\n');
                    appModel.clear();
                    
                    for (var i = 0; i < lines.length; i++) {
                        var parts = lines[i].split('|||');
                        if (parts.length === 2 && parts[0] && parts[1]) {
                            var name = parts[0].trim();
                            var execStr = parts[1].trim();
                            if (execStr.length > 0) {
                                appModel.append({
                                    name: name,
                                    exec: execStr
                                });
                            }
                        }
                    }
                    filterApps();
                }
            }
        }
        
        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8
            
            Rectangle {
                Layout.fillWidth: true
                Layout.preferredHeight: 36
                color: Services.Theme.surfaceBase
                radius: 6
                border.color: searchInput.activeFocus ? Services.Theme.primaryMuted : "transparent"
                border.width: 1
                
                    TextInput {
                    id: searchInput
                    anchors.fill: parent
                    anchors.margins: 8
                        color: Services.Theme.foreground
                        font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize }
                    selectByMouse: true
                    focus: true
                    activeFocusOnPress: true
                    onTextChanged: {
                        filterApps();
                    }
                    Keys.onEscapePressed: {
                        appLauncher.shouldShow = false;
                    }
                    Keys.onReturnPressed: {
                        if (appList.currentIndex >= 0) {
                            var item = filteredModel.get(appList.currentIndex);
                            if (item) {
                                appLauncher.shouldShow = false;
                                var command = item.exec.trim().split(/\s+/).filter(function(cmd) { return cmd.length > 0; });
                                var proc = processComponent.createObject(appLauncher, {  cmd: ["sh", "-c", command.join(" ") + " &"]  });
                            }
                        }
                    }
                    Keys.onDownPressed: {
                        appList.incrementCurrentIndex();
                    }
                    Keys.onUpPressed: {
                        appList.decrementCurrentIndex();
                    }
                    
                    Text {
                        anchors.fill: parent
                        text: "Search applications..."
                        color: Services.Theme.foregroundMuted
                        font: searchInput.font
                        visible: !searchInput.text && !searchInput.activeFocus
                    }
                }
            }
            
            ListView {
                id: appList
                Layout.fillWidth: true
                Layout.fillHeight: true
                model: filteredModel
                spacing: 4
                currentIndex: 0
                clip: true
                
                onCurrentIndexChanged: {
                    if (currentIndex >= 0) {
                        positionViewAtIndex(currentIndex, ListView.Contain);
                    }
                }
                    
                    delegate: Rectangle {
                        required property string name
                        required property string exec
                        required property int index
                        
                        width: appList.width
                        height: 40
                        color: (appMa.containsMouse || appList.currentIndex === index) ? Services.Theme.surfaceBase : "transparent"
                        radius: 6
                        
                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 12
                            
                            Text {
                                text: name
                                color: Services.Theme.foreground
                                font { family: Services.Theme.font; pixelSize: Services.Theme.fontSize }
                            }
                            
                            Item { Layout.fillWidth: true }
                        }
                        
                        MouseArea {
                            id: appMa
                            anchors.fill: parent
                            hoverEnabled: true
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                appLauncher.shouldShow = false;
                                var command = exec.trim().split(/\s+/).filter(function(cmd) { return cmd.length > 0; });
                                var proc = processComponent.createObject(appLauncher, {  cmd: ["sh", "-c", command.join(" ") + " &"]  });
                            }
                        }
                    }
                }
        }
        
        Connections {
            target: bar
            function onShowAppLauncher() {
                appLauncher.toggle();
            }
        }
    }
    
    function filterApps() {
        filteredModel.clear();
        var searchText = searchInput.text.toLowerCase();
        if (searchText === "") {
            for (var i = 0; i < appModel.count; i++) {
                var item = appModel.get(i);
                filteredModel.append({ name: item.name, exec: item.exec });
            }
        } else {
            for (var i = 0; i < appModel.count; i++) {
                var item = appModel.get(i);
                if (item.name.toLowerCase().includes(searchText)) {
                    filteredModel.append({ name: item.name, exec: item.exec });
                }
            }
        }
        if (filteredModel.count > 0) {
            appList.currentIndex = 0;
        } else {
            appList.currentIndex = -1;
        }
    }
    
    Component.onCompleted: {
        filterApps();
    }
}