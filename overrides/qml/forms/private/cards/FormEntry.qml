/*
    SPDX-FileCopyrightText: 2026 Project Ro ASD
    SPDX-License-Identifier: LGPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC
import QtQuick.Templates as T
import org.kde.kirigami.platform as Platform
import org.kde.kirigami.primitives as Primitives
import org.kde.kirigami.layouts as KirigamiLayouts
import org.kde.kirigami.forms.private.templates as FT

FT.FormEntry {
    id: root

    implicitWidth: mainRow.implicitWidth + Platform.Units.largeSpacing * 2
    implicitHeight: Math.max(Platform.Units.gridUnit * 2.8, mainRow.implicitHeight + Platform.Units.largeSpacing)

    Layout.fillWidth: true

    hovered: mouseArea.containsMouse

    readonly property real __textLabelWidth: 0
    readonly property bool isLastItem: {
        if (!root.parent) return true;
        let visibleCount = 0;
        let myIndex = -1;
        for (let i = 0; i < root.parent.children.length; ++i) {
            let child = root.parent.children[i];
            if (child.visible) {
                if (child === root) myIndex = visibleCount;
                visibleCount++;
            }
        }
        return myIndex === visibleCount - 1;
    }

    // Tıklama ve fare alanı
    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        acceptedButtons: Qt.LeftButton
        onClicked: {
            if (!root.clickEnabled) return;
            const buddy = root.contentItem?.KirigamiLayouts.FormData.buddyFor;
            if (buddy instanceof T.AbstractButton) {
                buddy.animateClick();
            } else if (buddy instanceof T.ComboBox) {
                buddy.popup.open();
            }
            root.clicked();
        }
    }

    // Hover Arka Planı
    Rectangle {
        anchors.fill: parent
        color: Platform.Theme.textColor
        opacity: root.clickEnabled && mouseArea.containsMouse ? (mouseArea.pressed ? 0.08 : 0.04) : 0
        radius: 8
        Behavior on opacity {
            NumberAnimation { duration: 150 }
        }
    }

    // Ana İçerik Satırı (Deepin 23 Satır Düzeni)
    RowLayout {
        id: mainRow
        anchors {
            fill: parent
            leftMargin: Platform.Units.largeSpacing
            rightMargin: Platform.Units.largeSpacing
        }
        spacing: Platform.Units.largeSpacing

        // Öncü Öğeler (Simge vb.)
        RowLayout {
            id: leadingItemsRow
            visible: children.length > 0
            spacing: Platform.Units.smallSpacing
            children: root.leadingItems
        }

        // Sol Kolon: Başlık ve Açıklama Metni
        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2

            QQC.Label {
                id: titleText
                Layout.fillWidth: true
                font.weight: Font.DemiBold
                text: {
                    if (root.title && root.title.length > 0) return root.title;
                    if (root.contentItem && root.contentItem.KirigamiLayouts && root.contentItem.KirigamiLayouts.FormData.label) {
                        return root.contentItem.KirigamiLayouts.FormData.label;
                    }
                    if (root.contentItem instanceof QQC.CheckBox && root.contentItem.text) {
                        return root.contentItem.text;
                    }
                    return "";
                }
                visible: text.length > 0
                wrapMode: Text.WordWrap
            }

            QQC.Label {
                id: subtitleText
                Layout.fillWidth: true
                visible: text.length > 0
                color: Platform.Theme.disabledTextColor
                font.pointSize: Platform.Theme.defaultFont.pointSize * 0.9
                text: root.subtitle
                wrapMode: Text.WordWrap
            }
        }

        // Sağ Kolon: Kontrol Bileşeni (Açılır kutu, kaydırıcı, anahtar/switch)
        QQC.Control {
            id: contentItemWrapper
            Layout.alignment: Qt.AlignRight | Qt.AlignVCenter
            Layout.preferredWidth: contentItem ? Math.min(contentItem.implicitWidth, root.width * 0.5) : 0
            contentItem: root.contentItem
            visible: contentItem !== null
        }

        // Ardıl Öğeler (Bilgi butonu, yardım oku vb.)
        RowLayout {
            id: trailingItemsRow
            visible: children.length > 0
            spacing: Platform.Units.smallSpacing
            children: root.trailingItems
        }
    }

    // Satırlar Arası İnce Ayrım Çizgisi
    Rectangle {
        anchors {
            left: parent.left
            right: parent.right
            bottom: parent.bottom
            leftMargin: Platform.Units.largeSpacing
            rightMargin: Platform.Units.largeSpacing
        }
        height: 1
        color: Platform.Theme.textColor
        opacity: 0.06
        visible: !root.isLastItem
    }
}
