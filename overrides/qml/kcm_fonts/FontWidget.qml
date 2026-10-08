/*
    SPDX-FileCopyrightText: 2015 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2026 Ro-KDE Team
    SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils

Item {
    id: root
    property string label
    property alias tooltipText: tooltip.text
    property string category
    property font font

    Layout.fillWidth: true
    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, 48)

    RowLayout {
        anchors {
            fill: parent
            leftMargin: Kirigami.Units.smallSpacing
            rightMargin: Kirigami.Units.smallSpacing
        }
        spacing: Kirigami.Units.largeSpacing

        QtControls.Label {
            text: root.label.replace(/:\s*$/, "")
            font.weight: Font.DemiBold
            color: Kirigami.Theme.textColor
            Layout.preferredWidth: 200
        }

        Item { Layout.fillWidth: true }

        Rectangle {
            implicitHeight: 34
            implicitWidth: fontRow.implicitWidth + 24
            radius: 8
            color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.05)
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.1)
            border.width: 1

            RowLayout {
                id: fontRow
                anchors.centerIn: parent
                spacing: 8

                QtControls.Label {
                    text: i18nc("%1 is the name of a font type, %2 is the size in points", "%1 %2 pt", root.font.family, root.font.pointSize)
                    font: root.font
                    color: Kirigami.Theme.textColor
                }

                Kirigami.Icon {
                    source: "document-edit"
                    implicitWidth: 14
                    implicitHeight: 14
                    color: Kirigami.Theme.disabledTextColor
                }
            }

            MouseArea {
                anchors.fill: parent
                cursorShape: Qt.PointingHandCursor
                onClicked: kcm.adjustFont(root.font, root.category)
            }
        }
    }

    QtControls.ToolTip {
        id: tooltip
    }
}
