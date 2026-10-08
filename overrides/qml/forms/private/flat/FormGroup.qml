/*
    SPDX-FileCopyrightText: 2026 Project Ro ASD
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import org.kde.kirigami.controls as KC
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT

FT.FormGroup {
    id: root

    Layout.fillWidth: true
    default property alias entries: innerLayout.data
    implicitWidth: layout.implicitWidth
    implicitHeight: layout.implicitHeight

    readonly property real __maxTextLabelWidth: 0
    property real __assignedWidthForLabels: 0

    ColumnLayout {
        id: layout
        anchors.fill: parent
        spacing: Platform.Units.smallSpacing

        // Başlık (Grup üst başlığı)
        KC.Heading {
            level: 4
            font.weight: Font.DemiBold
            visible: text.length > 0
            text: root.title
            leftPadding: 6
            bottomPadding: 2
        }

        // Modern Kart Gövdesi (Deepin 23 Stili)
        Rectangle {
            Layout.fillWidth: true
            implicitHeight: innerLayout.implicitHeight + Platform.Units.largeSpacing
            radius: 12
            color: Qt.rgba(Platform.Theme.backgroundColor.r, Platform.Theme.backgroundColor.g, Platform.Theme.backgroundColor.b, 0.75)
            border.color: Qt.rgba(Platform.Theme.textColor.r, Platform.Theme.textColor.g, Platform.Theme.textColor.b, 0.08)
            border.width: 1

            ColumnLayout {
                id: innerLayout
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Platform.Units.smallSpacing
                }
                spacing: 0
            }
        }
    }
}
