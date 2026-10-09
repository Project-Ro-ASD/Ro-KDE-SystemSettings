/*
   SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
   SPDX-License-Identifier: LGPL-2.0-only
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.systemsettings
import org.kde.systemsettings.nav 1.0

Kirigami.ScrollablePage {
    id: subCategoryColumn
    title: systemsettings.subCategoryModel.title

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    header: Kirigami.AbstractApplicationHeader {
        id: pageHeader

        contentItem: RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Keys.onDownPressed: event => {
                subCategoryView.currentIndex = 0;
                event.accepted = false;
            }

            // Modern < and > navigation buttons
            NavButton {
                id: backNavBtn
                symbol: "<"
                enabled: true
                tooltip: i18n("Geri")
                onClicked: {
                    SettingsNav.goBack();
                }
            }

            NavButton {
                id: forwardNavBtn
                symbol: ">"
                enabled: SettingsNav.maxReachedLevel > 1
                tooltip: i18n("İleri")
                onClicked: {
                    SettingsNav.goForward();
                }
            }

            QQC2.Label {
                id: headerTitle
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: systemsettings.subCategoryModel.title !== "" ? systemsettings.subCategoryModel.title : SettingsNav.level1Title
                font.bold: true
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            HamburgerMenuButton {
                id: hamburgerMenuButton

                KeyNavigation.left: backNavBtn
                KeyNavigation.down: subCategoryView
                KeyNavigation.tab: KeyNavigation.down

                Keys.onDownPressed: event => {
                    rowLayout.Keys.downPressed(event);
                }
            }
        }
    }

    ListView {
        id: subCategoryView

        anchors.fill: parent
        model: systemsettings.subCategoryModel
        currentIndex: systemsettings.activeSubCategoryRow
        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List

        KeyNavigation.up: backNavBtn
        KeyNavigation.backtab: hamburgerMenuButton

        Keys.onUpPressed: event => {
            if (subCategoryView.currentIndex === 0) {
                subCategoryView.currentIndex = -1;
            }
            event.accepted = false;
        }
        Keys.onTabPressed: event => {
            systemsettings.focusNext();
        }

        Connections {
            target: systemsettings
            function onActiveSubCategoryRowChanged() {
                subCategoryView.currentIndex = systemsettings.activeSubCategoryRow;
                if (systemsettings.activeSubCategoryRow >= 0 && subCategoryView.count > 1) {
                    subCategoryView.forceActiveFocus();
                    SettingsNav.level1Title = systemsettings.subCategoryModel.title;
                    if (SettingsNav.navLevel === 0) {
                        SettingsNav.goToLevel(1);
                    }
                }
            }
        }

        delegate: CategoryItem {
            id: delegate

            required property int index
            required property var model
            required property int depth
            required property string iconName

            text: model.display
            icon.name: model.iconName

            leadingPadding: depth > 2 ? (( depth - 2 ) * Kirigami.Units.iconSizes.smallMedium) + Kirigami.Units.largeSpacing : 0

            // Check if this item has deep sub-pages (like Erişilebilirlik)
            showArrow: {
                const name = (model.display || "").toLowerCase();
                const ic = (model.iconName || "").toLowerCase();
                return name.indexOf("erişilebilirlik") !== -1 || name.indexOf("accessibility") !== -1 || ic.indexOf("accessibility") !== -1;
            }

            highlighted: ListView.isCurrentItem

            onClicked: {
                if (showArrow) {
                    SettingsNav.level2Title = model.display;
                    SettingsNav.activeSubCategoryIndex = index;
                    SettingsNav.goToLevel(2);
                } else {
                    SettingsNav.maxReachedLevel = 1;
                    SettingsNav.goToLevel(1);
                }
                systemsettings.loadModule(subCategoryView.model.index(index, 0));
            }
            onFocusChanged: {
                if (focus) {
                    onCurrentIndexChanged: subCategoryView.positionViewAtIndex(index, ListView.Contain);
                }
            }
            Keys.onEnterPressed: clicked();
            Keys.onReturnPressed: clicked();

            Keys.onEscapePressed: SettingsNav.goBack();

            Keys.onLeftPressed: {
                if (!LayoutMirroring.enabled) {
                    SettingsNav.goBack();
                }
            }
            Keys.onRightPressed: {
                if (LayoutMirroring.enabled) {
                    SettingsNav.goBack();
                }
            }
        }
    }
}
