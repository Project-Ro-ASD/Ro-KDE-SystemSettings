/*
   SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
   SPDX-FileCopyrightText: 2023 ivan tkachenko <me@ratijas.tk>
   SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick
import org.kde.kirigami as Kirigami

Item {
    id: root

    readonly property real headerHeight: sideBar.headerHeight

    implicitHeight: sideBar.implicitHeight
    implicitWidth: sideBar.implicitWidth + separator.implicitWidth

    LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
    LayoutMirroring.childrenInherit: true

    Rectangle {
        anchors {
            top: parent.top
            right: parent.right
        }
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
        color: Kirigami.Theme.backgroundColor
        width: separator.width
        height: sideBar.pageStack.currentItem?.header ? sideBar.pageStack.currentItem.header.height : 48
    }

    SideBarItem {
        id: sideBar

        anchors.fill: parent
        anchors.rightMargin: separator.width
    }

    Kirigami.Separator {
        z: 1
        anchors {
            top: parent.top
            topMargin: Kirigami.Units.largeSpacing
            right: parent.right
        }
        height: (sideBar.pageStack.currentItem?.header ? sideBar.pageStack.currentItem.header.height : 48) - Kirigami.Units.largeSpacing * 2
        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
    }

    Kirigami.Separator {
        id: separator
        z: 1
        anchors {
            top: parent.top
            topMargin: (sideBar.pageStack.currentItem?.header ? sideBar.pageStack.currentItem.header.height : 48) - Math.round(separator.width * (systemsettings.devicePixelRatio || 1)) / (systemsettings.devicePixelRatio || 1)
            right: parent.right
            bottom: parent.bottom
        }

        Kirigami.Theme.inherit: false
        Kirigami.Theme.colorSet: Kirigami.Theme.Header
    }
}
