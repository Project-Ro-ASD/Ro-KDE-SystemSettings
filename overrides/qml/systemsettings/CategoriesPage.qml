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
    id: mainColumn
    readonly property bool searchMode: searchField.text.length > 0

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    header: Kirigami.AbstractApplicationHeader {
        id: pageHeader

        height: Math.round((sizeHelper.implicitHeight + Kirigami.Units.smallSpacing * 2) * systemsettings.devicePixelRatio) / systemsettings.devicePixelRatio

        QQC2.ToolButton {
            id: sizeHelper
            visible: false
            icon.name: "go-previous"
        }

        contentItem: RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            Keys.onDownPressed: event => {
                categoryView.currentIndex = 0;
                event.accepted = false;
            }

            // Modern < and > navigation buttons
            NavButton {
                symbol: "<"
                enabled: false
                tooltip: i18n("Geri")
            }

            NavButton {
                symbol: ">"
                enabled: SettingsNav.maxReachedLevel > 0
                tooltip: i18n("İleri")
                onClicked: {
                    SettingsNav.goForward();
                }
            }

            Kirigami.SearchField {
                id: searchField

                focus: !Kirigami.InputMethod.willShowOnActive
                Layout.fillWidth: true
                onTextChanged: {
                    systemsettings.searchModel.filterRegExp = text;
                }

                KeyNavigation.right: hamburgerMenuButton
                KeyNavigation.down: categoryView
                KeyNavigation.backtab: KeyNavigation.left
                KeyNavigation.tab: KeyNavigation.right

                Keys.onDownPressed: event => rowLayout.Keys.downPressed(event)
                onActiveFocusChanged: {
                    if (activeFocus) {
                        systemsettings.giveFocus();
                    }
                }
            }

            HamburgerMenuButton {
                id: hamburgerMenuButton

                KeyNavigation.left: searchField
                KeyNavigation.down: categoryView
                KeyNavigation.backtab: KeyNavigation.left
                KeyNavigation.tab: KeyNavigation.down

                Keys.onDownPressed: event => rowLayout.Keys.downPressed(event)
            }
        }
    }

    property Item __placeholder: Loader {
        parent: mainColumn
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.gridUnit * 4)
        opacity: categoryView.count === 0 ? 1 : 0
        active: opacity > 0
        visible: active
        Behavior on opacity {
            NumberAnimation {
                duration: Kirigami.Units.longDuration
                easing.type: Easing.InOutQuad
            }
        }
        sourceComponent: Kirigami.PlaceholderMessage {
            width: parent.width
            icon.name: "edit-none"
            text: i18nc("A search yielded no results", "No items matching your search")
        }
    }

    Binding {
        target: categoryView
        property: "currentIndex"
        value: mainColumn.searchMode
            ? systemsettings.activeSearchRow
            : systemsettings.activeCategoryRow
    }

    ListView {
        id: categoryView

        model: mainColumn.searchMode ? systemsettings.searchModel : systemsettings.categoryModel

        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List

        KeyNavigation.up: searchField
        KeyNavigation.backtab: hamburgerMenuButton
        Keys.onUpPressed: event => {
            if (categoryView.currentIndex === 0) {
                categoryView.currentIndex = -1;
            }
            event.accepted = false;
        }
        Keys.onTabPressed: {
            systemsettings.focusNext();
        }

        section {
            property: "categoryDisplayRole"
            delegate: Kirigami.ListSectionHeader {
                required property string section

                width: ListView.view.width
                label: section
            }
        }

        delegate: CategoryItem {
            id: delegate

            required property int index
            required property var model
            required property bool isCategory
            required property int depth
            required property bool isKCM
            required property string iconName

            text: model.display
            icon.name: iconName

            showArrow: {
                if (!isCategory) {
                    return false;
                }
                const modelIndex = delegate.ListView.view.model.index(index, 0)
                return delegate.ListView.view.model.rowCount(modelIndex) > 1
            }

            leadingPadding: (depth > 1 && searchField.text.length > 0) ? (( depth - 1 ) * Kirigami.Units.iconSizes.smallMedium) + Kirigami.Units.largeSpacing : 0

            hoverEnabled: !isCategory || !mainColumn.searchMode
            enabled: !isCategory || !mainColumn.searchMode

            highlighted: ListView.isCurrentItem

            onClicked: {
                if (!enabled) { return; }
                if (isKCM || mainColumn.searchMode || systemsettings.activeCategoryRow !== index) {
                    systemsettings.loadModule(categoryView.model.index(index, 0));
                }
                if (!mainColumn.searchMode && showArrow) {
                    SettingsNav.level1Title = model.display;
                    SettingsNav.activeCategoryIndex = index;
                    SettingsNav.goToLevel(1);
                }
            }
            onFocusChanged: {
                if (isCategory && mainColumn.searchMode) {
                    return;
                }
                if (focus) {
                    categoryView.positionViewAtIndex(index, ListView.Contain);
                }
            }
            Keys.onEnterPressed: clicked();
            Keys.onReturnPressed: clicked();

            Keys.onLeftPressed: {
                if (LayoutMirroring.enabled) {
                    clicked();
                }
            }
            Keys.onRightPressed: {
                if (!LayoutMirroring.enabled) {
                    clicked();
                }
            }
        }
    }
}
