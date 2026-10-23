// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
Pane {
    id: root
    objectName: "roModuleHeader"
    function text(en, tr) { return shell.turkish ? tr : en }
    ColumnLayout {
        anchors.fill: parent
        Label { text: shell.title; font.pixelSize: 22; font.bold: true; Layout.fillWidth: true; elide: Text.ElideRight }
        TabBar {
            id: historyTabs
            objectName: "roHistoryTabs"
            currentIndex: shell.tabs.findIndex(t => t.id === shell.currentId)
            Layout.fillWidth: true
            Repeater {
                model: shell.tabs
                delegate: TabButton {
                    required property var modelData
                    objectName: "historyTab_" + modelData.id
                    text: modelData.name
                    enabled: !shell.busy
                    onClicked: { shell.open(modelData.id); historyTabs.setCurrentIndex(shell.tabs.findIndex(t => t.id === shell.currentId)) }
                }
            }
        }
        RowLayout {
            Layout.fillWidth: true
            Button { text: root.text("Defaults", "Varsayılanlar"); enabled: shell.canDefault; onClicked: shell.defaults() }
            Item { Layout.fillWidth: true }
            BusyIndicator { running: shell.busy; visible: running; Layout.preferredHeight: 28; Layout.preferredWidth: 28 }
            Button { text: root.text("Reset", "Geri al"); enabled: shell.dirty && !shell.busy; onClicked: shell.reset() }
            Button { text: root.text("Apply", "Uygula"); enabled: shell.canApply; highlighted: enabled; onClicked: shell.apply() }
        }
    }
}
