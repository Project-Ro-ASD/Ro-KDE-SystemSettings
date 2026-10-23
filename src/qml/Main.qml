// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-or-later
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

Pane {
    id: root
    objectName: "roCatalog"
    padding: 0
    property string selectedCategory: ""
    property string expandedCategory: ""
    readonly property int filteredCount: shell.modules.filter(m => root.matches(m)).length
    readonly property bool catalog: shell.currentId === ""
    function text(en, tr) { return shell.turkish ? tr : en }
    function matches(module) {
        const query = search.text.toLocaleLowerCase()
        return (selectedCategory === "" || module.ancestorCategories.includes(selectedCategory))
            && (module.name + " " + module.description + " " + module.keywords + " " + module.id + " " + module.path).toLocaleLowerCase().includes(query)
    }
    function topCategories() {
        const ids = [...new Set(shell.modules.map(m => m.topCategory))]
        return shell.categories.filter(c => ids.includes(c.id))
    }
    RowLayout {
        anchors.fill: parent
        spacing: 0
        Pane {
            id: sidebar
            objectName: "roSidebar"
            Layout.preferredWidth: 250
            Layout.fillHeight: true
            Layout.fillWidth: !root.catalog
            padding: 16
            background: Rectangle { color: root.palette.alternateBase }
            ColumnLayout {
                anchors.fill: parent
                spacing: 12
                RowLayout {
                    Rectangle {
                        color: root.palette.highlight
                        width: 42; height: 42; radius: 12
                        Label { anchors.centerIn: parent; text: "Ro"; color: root.palette.highlightedText; font.pixelSize: 23; font.bold: true }
                    }
                    Label { text: root.text("System\nSettings", "Sistem\nAyarları"); font.bold: true; font.pixelSize: 18; Accessible.name: "Ro " + text }
                }
                TextField {
                    id: search
                    objectName: "settingsSearch"
                    Layout.fillWidth: true
                    placeholderText: root.text("Search settings…", "Ayarlarda ara…")
                    Accessible.name: placeholderText
                    onTextChanged: root.selectedCategory = ""
                    onAccepted: {
                        const result = shell.modules.find(m => root.matches(m))
                        if (result) shell.open(result.id)
                    }
                }
                RowLayout {
                    ToolButton { text: "←"; Accessible.name: root.text("Back", "Geri"); enabled: shell.canBack && !shell.busy; onClicked: shell.back() }
                    ToolButton { text: "→"; Accessible.name: root.text("Forward", "İleri"); enabled: shell.canForward && !shell.busy; onClicked: shell.forward() }
                    Button {
                        text: root.text("All settings", "Tüm ayarlar")
                        Layout.fillWidth: true
                        flat: true
                        enabled: !shell.busy
                        onClicked: { root.selectedCategory = ""; search.clear(); shell.home() }
                    }
                }
                ScrollView {
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    ColumnLayout {
                        width: parent.width
                        spacing: 4
                        Repeater {
                            model: root.topCategories()
                            delegate: ColumnLayout {
                                id: category
                                required property var modelData
                                Layout.fillWidth: true
                                Button {
                                    objectName: "categoryToggle_" + category.modelData.id
                                    Layout.fillWidth: true
                                    text: (root.expandedCategory === category.modelData.id ? "▾  " : "▸  ") + category.modelData.name
                                    Accessible.name: category.modelData.name
                                    Accessible.description: root.text("Expand category", "Kategoriyi genişlet")
                                    highlighted: root.selectedCategory === category.modelData.id
                                    flat: true
                                    enabled: !shell.busy
                                    onClicked: {
                                        root.expandedCategory = root.expandedCategory === category.modelData.id ? "" : category.modelData.id
                                        root.selectedCategory = category.modelData.id
                                        shell.home()
                                    }
                                }
                                Repeater {
                                    model: root.expandedCategory === category.modelData.id ? shell.categories.filter(c => c.parent === category.modelData.id) : []
                                    delegate: ItemDelegate {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        objectName: "subcategory_" + modelData.id
                                        text: modelData.name
                                        highlighted: root.selectedCategory === modelData.id
                                        enabled: !shell.busy
                                        onClicked: { root.selectedCategory = modelData.id; shell.home() }
                                    }
                                }
                                Repeater {
                                    model: root.expandedCategory === category.modelData.id ? shell.modules.filter(m => m.topCategory === category.modelData.id && root.matches(m)) : []
                                    delegate: ItemDelegate {
                                        required property var modelData
                                        Layout.fillWidth: true
                                        objectName: "categoryModule_" + modelData.id
                                        text: modelData.name
                                        highlighted: shell.currentId === modelData.id
                                        enabled: !shell.busy
                                        Accessible.description: modelData.path
                                        onClicked: shell.open(modelData.id)
                                    }
                                }
                            }
                        }
                        Repeater {
                            model: !root.catalog && search.text.length > 0 ? shell.modules.filter(m => root.matches(m)) : []
                            delegate: ItemDelegate {
                                required property var modelData
                                Layout.fillWidth: true
                                text: modelData.name
                                enabled: !shell.busy
                                onClicked: shell.open(modelData.id)
                            }
                        }
                    }
                }
                Label { text: shell.error; visible: !root.catalog && text.length > 0; wrapMode: Text.WordWrap; Layout.fillWidth: true; Accessible.role: Accessible.AlertMessage }
                Button {
                    text: root.text("Open KDE settings", "KDE ayarlarını aç")
                    Layout.fillWidth: true
                    flat: true
                    onClicked: shell.stock()
                }
            }
        }
        Pane {
            visible: root.catalog
            Layout.fillWidth: true
            Layout.fillHeight: true
            padding: 24
            ColumnLayout {
                anchors.fill: parent
                spacing: 16
                Label { text: root.text("Make it yours", "Kendinize göre ayarlayın"); font.pixelSize: 25; font.bold: true; Layout.fillWidth: true; wrapMode: Text.WordWrap }
                Label { text: root.filteredCount + root.text(" settings available", " ayar kullanılabilir"); opacity: 0.7 }
                Label { text: shell.error; visible: text.length > 0; wrapMode: Text.WordWrap; Layout.fillWidth: true; Accessible.role: Accessible.AlertMessage }
                ScrollView {
                    id: cards
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    GridLayout {
                        width: cards.availableWidth
                        columns: width > 600 ? 2 : 1
                        columnSpacing: 12
                        rowSpacing: 12
                        Repeater {
                            model: shell.modules.filter(m => root.matches(m))
                            delegate: Button {
                                id: card
                                objectName: "moduleCard_" + modelData.id
                                required property var modelData
                                Layout.fillWidth: true
                                Layout.minimumWidth: 210
                                Layout.preferredHeight: 145
                                padding: 18
                                Accessible.name: modelData.name
                                Accessible.description: modelData.description + ". " + modelData.path
                                enabled: !shell.busy
                                onClicked: shell.open(modelData.id)
                                background: Rectangle {
                                    radius: 12
                                    color: card.hovered || card.activeFocus ? root.palette.alternateBase : root.palette.base
                                    border.width: 1
                                    border.color: card.activeFocus ? root.palette.highlight : root.palette.mid
                                }
                                contentItem: ColumnLayout {
                                    spacing: 8
                                    Label { text: card.modelData.name; font.bold: true; font.pixelSize: 17; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Label { text: card.modelData.path; elide: Text.ElideRight; Layout.fillWidth: true; opacity: 0.65 }
                                    Label { text: card.modelData.description; wrapMode: Text.WordWrap; maximumLineCount: 2; elide: Text.ElideRight; Layout.fillWidth: true }
                                    Item { Layout.fillHeight: true }
                                }
                            }
                        }
                        Label { visible: root.filteredCount === 0; text: root.text("No matching modules", "Eşleşen modül yok"); Layout.fillWidth: true }
                    }
                }
            }
        }
    }
    Shortcut { sequence: "Ctrl+F"; onActivated: search.forceActiveFocus() }
}
