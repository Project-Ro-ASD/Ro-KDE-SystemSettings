/*
    SPDX-FileCopyrightText: 2026 Project Ro ASD
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.forms.private.templates as FT

FT.FormSeparator {
    id: root
    Layout.fillWidth: true
    implicitHeight: Platform.Units.largeSpacing * 2

    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            verticalCenter: parent.verticalCenter
            leftMargin: Platform.Units.smallSpacing
            rightMargin: Platform.Units.smallSpacing
        }
        height: 1
        color: Platform.Theme.textColor
        opacity: 0.08
    }
}
