/*
   SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
   SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
   SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick
import org.kde.kirigami as Kirigami
import org.kde.systemsettings.nav 1.0

Kirigami.ApplicationItem {
    id: root

    // Strictly single-column sidebar layout - absolutely no side-by-side multiple panels
    implicitWidth: Math.round(Kirigami.Units.gridUnit * 17)
    wideScreen: false

    pageStack.initialPage: mainColumn
    pageStack.defaultColumnWidth: root.width

    property alias searchMode: mainColumn.searchMode
    readonly property real headerHeight: mainColumn.header ? mainColumn.header.height : 48

    CategoriesPage {
        id: mainColumn
        focus: true
    }

    SubCategoryPage {
        id: subCategoryColumn
        enabled: pageStack.visibleItems.includes(subCategoryColumn)
    }

    SubSubCategoryPage {
        id: subSubCategoryColumn
        enabled: pageStack.visibleItems.includes(subSubCategoryColumn)
    }

    Component.onCompleted: {
        SettingsNav.navLevel = 0;
        SettingsNav.maxReachedLevel = 0;
    }

    Connections {
        target: SettingsNav

        function onRequestGoToLevel(lvl) {
            if (lvl === 0) {
                pageStack.currentIndex = 0;
            } else if (lvl === 1) {
                if (pageStack.depth < 2) {
                    pageStack.push(subCategoryColumn);
                }
                pageStack.currentIndex = 1;
            } else if (lvl === 2) {
                if (pageStack.depth < 2) {
                    pageStack.push(subCategoryColumn);
                }
                if (pageStack.depth < 3) {
                    pageStack.push(subSubCategoryColumn);
                }
                pageStack.currentIndex = 2;
            }
        }
    }
}
