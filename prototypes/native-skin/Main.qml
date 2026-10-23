// SPDX-FileCopyrightText: 2026 Ro-ASD contributors
// SPDX-License-Identifier: GPL-3.0-only
// Original visual layer. All module discovery, filtering and loading remain in KDE.
pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami

Rectangle {
    id: root
    objectName: "roNativeSidebar"
    implicitWidth: Kirigami.Units.gridUnit * 19
    implicitHeight: Kirigami.Units.gridUnit * 32
    readonly property real headerHeight: header.implicitHeight
    readonly property bool searching: search.text.length > 0
    property int expandedRow: systemsettings.activeCategoryRow
    color: Kirigami.Theme.backgroundColor
    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: Kirigami.Units.largeSpacing
        spacing: Kirigami.Units.largeSpacing

        ColumnLayout {
            id: header
            Layout.fillWidth: true
            RowLayout {
                Layout.fillWidth: true
                Kirigami.Heading {
                    text: "Ro"
                    level: 1
                    Layout.fillWidth: true
                }
                QQC2.ToolButton {
                    objectName: "roActionMenu"
                    icon.name: "application-menu"
                    text: i18nd("ro-systemsettings-native-skin", "Show menu")
                    display: QQC2.AbstractButton.IconOnly
                    Accessible.name: text
                    onClicked: systemsettings.showActionMenu(mapToGlobal(width / 2, height))
                    QQC2.ToolTip.visible: hovered
                    QQC2.ToolTip.text: text
                }
            }
            Kirigami.SearchField {
                id: search
                objectName: "roSearchField"
                Layout.fillWidth: true
                placeholderText: i18nd("ro-systemsettings-native-skin", "Search settings")
                Accessible.name: placeholderText
                onTextChanged: systemsettings.searchModel.filterRegExp = text
                onActiveFocusChanged: if (activeFocus) systemsettings.giveFocus()
                Keys.onDownPressed: {
                    categories.currentIndex = 0;
                    categories.forceActiveFocus();
                }
            }
        }

        QQC2.ScrollView {
            Layout.fillWidth: true
            Layout.fillHeight: true
            clip: true
            ListView {
                id: categories
                objectName: "roCategoryList"
                spacing: Kirigami.Units.smallSpacing
                model: root.searching ? systemsettings.searchModel : systemsettings.categoryModel
                currentIndex: root.searching ? systemsettings.activeSearchRow : systemsettings.activeCategoryRow
                activeFocusOnTab: true
                keyNavigationWraps: true
                Accessible.role: Accessible.List
                Keys.onTabPressed: systemsettings.focusNext()
                Keys.onEscapePressed: search.forceActiveFocus()

                delegate: Column {
                    id: category
                    required property int index
                    required property var model
                    width: ListView.view.width
                    spacing: Kirigami.Units.smallSpacing
                    readonly property bool expanded: !root.searching && root.expandedRow === index
                    readonly property bool selected: ListView.isCurrentItem
                    function activate() {
                        if (root.searching && model.isCategory) return;
                        const wasExpanded = expanded;
                        systemsettings.loadModule(categories.model.index(index, 0));
                        if (!root.searching && systemsettings.activeCategoryRow === index) {
                            root.expandedRow = wasExpanded ? -1 : index;
                        }
                    }
                    QQC2.ItemDelegate {
                        id: card
                        objectName: "roCategory_" + category.index
                        width: parent.width
                        implicitHeight: Kirigami.Units.gridUnit * 3
                        text: category.model.display
                        Accessible.name: text
                        enabled: !root.searching || !category.model.isCategory
                        highlighted: category.selected
                        onClicked: category.activate()
                        Keys.onReturnPressed: category.activate()
                        Keys.onEnterPressed: category.activate()
                        background: Rectangle {
                            radius: Kirigami.Units.cornerRadius
                            color: card.highlighted || card.hovered
                                ? Qt.alpha(Kirigami.Theme.highlightColor, 0.18)
                                : Kirigami.Theme.alternateBackgroundColor
                            border.color: card.activeFocus ? Kirigami.Theme.highlightColor : "transparent"
                        }
                        contentItem: RowLayout {
                            Kirigami.Icon {
                                source: category.model.iconName
                                Layout.preferredWidth: Kirigami.Units.iconSizes.smallMedium
                                Layout.preferredHeight: width
                            }
                            QQC2.Label {
                                text: card.text
                                Layout.fillWidth: true
                                elide: Text.ElideRight
                                textFormat: Text.PlainText
                                font.bold: category.selected
                            }
                            Kirigami.Icon {
                                visible: !root.searching && category.model.isCategory
                                source: category.expanded ? "arrow-down" : "arrow-right"
                                Layout.preferredWidth: Kirigami.Units.iconSizes.small
                                Layout.preferredHeight: width
                            }
                            Kirigami.Badge {
                                visible: category.model.showDefaultIndicator && systemsettings.defaultsIndicatorsVisible
                                type: Kirigami.Badge.Type.Warning
                            }
                            QQC2.ToolButton {
                                readonly property var nativeAction: category.model.auxiliaryAction
                                visible: nativeAction?.visible ?? false
                                enabled: nativeAction?.enabled ?? false
                                text: nativeAction?.text ?? ""
                                icon.name: nativeAction ? systemsettings.actionIconName(nativeAction) : ""
                                display: QQC2.AbstractButton.IconOnly
                                Accessible.name: text
                                onClicked: nativeAction.trigger()
                            }
                        }
                    }
                    Loader {
                        width: parent.width
                        active: category.expanded && systemsettings.activeCategoryRow === category.index
                        sourceComponent: Column {
                            width: parent.width
                            Repeater {
                                model: systemsettings.subCategoryModel
                                delegate: QQC2.ItemDelegate {
                                    id: subcategory
                                    required property int index
                                    required property var model
                                    objectName: "roSubcategory_" + index
                                    width: parent.width
                                    leftPadding: Kirigami.Units.largeSpacing * 2
                                    text: model.display
                                    icon.name: model.iconName
                                    highlighted: systemsettings.activeSubCategoryRow === index
                                    Accessible.name: text
                                    background: Rectangle {
                                        radius: Kirigami.Units.cornerRadius
                                        color: subcategory.highlighted || subcategory.hovered
                                            ? Qt.alpha(Kirigami.Theme.highlightColor, 0.12) : "transparent"
                                        border.color: subcategory.activeFocus ? Kirigami.Theme.highlightColor : "transparent"
                                    }
                                    onClicked: systemsettings.loadModule(systemsettings.subCategoryModel.index(index, 0))
                                    Keys.onEscapePressed: {
                                        root.expandedRow = -1;
                                        card.forceActiveFocus();
                                    }
                                }
                            }
                        }
                    }
                }
                QQC2.Label {
                    anchors.centerIn: parent
                    width: parent.width
                    visible: categories.count === 0
                    text: i18nd("ro-systemsettings-native-skin", "No matching settings")
                    wrapMode: Text.Wrap
                    horizontalAlignment: Text.AlignHCenter
                }
                Keys.onReturnPressed: {
                    const item = itemAtIndex(currentIndex);
                    if (item) item.activate();
                }
            }
        }
    }
    Connections {
        target: systemsettings
        function onActiveCategoryRowChanged() { root.expandedRow = systemsettings.activeCategoryRow; }
    }
}
