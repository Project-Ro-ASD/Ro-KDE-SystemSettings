/*
    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as QQC2Impl
import org.kde.kirigami as Kirigami
import org.kde.desktop as Desktop

T.ComboBox {
    id: controlRoot

    Kirigami.Theme.colorSet: editable ? Kirigami.Theme.View : Kirigami.Theme.Button
    Kirigami.Theme.inherit: false

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            140)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             32)

    baselineOffset: contentItem ? contentItem.y + contentItem.baselineOffset : 0

    hoverEnabled: true
    wheelEnabled: true

    padding: 5
    leftPadding: mirrored ? 32 : 14
    rightPadding: mirrored ? 14 : 32
    topPadding: 5
    bottomPadding: 5

    delegate: Desktop.MenuItem {
        required property var model
        required property int index
        text: model[controlRoot.textRole]
        highlighted: controlRoot.highlightedIndex === index
    }

    indicator: Kirigami.Icon {
        x: controlRoot.mirrored ? 10 : controlRoot.width - width - 10
        y: controlRoot.topPadding + (controlRoot.availableHeight - height) / 2
        width: 14
        height: 14
        source: "go-down-symbolic"
        color: controlRoot.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
    }

    contentItem: T.TextField {
        leftPadding: 0
        rightPadding: 0
        topPadding: 0
        bottomPadding: 0

        text: controlRoot.editable ? controlRoot.editText : controlRoot.displayText
        font: controlRoot.font
        color: controlRoot.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
        verticalAlignment: Text.AlignVCenter
        elide: Text.ElideRight

        enabled: controlRoot.editable
        autoScroll: controlRoot.editable
        readOnly: !controlRoot.editable || controlRoot.down
        inputMethodHints: controlRoot.inputMethodHints
        validator: controlRoot.validator
        selectByMouse: controlRoot.editable

        background: null
    }

    background: Rectangle {
        implicitWidth: 140
        implicitHeight: 32
        radius: height / 2

        color: {
            if (!controlRoot.enabled) return Qt.rgba(0, 0, 0, 0.04);
            if (controlRoot.down || controlRoot.popup.visible) return "#f1f5f9";
            if (controlRoot.hovered) return "#f8fafc";
            return "#ffffff";
        }

        border.color: {
            if (!controlRoot.enabled) return Qt.rgba(0, 0, 0, 0.08);
            if (controlRoot.visualFocus || controlRoot.activeFocus || controlRoot.popup.visible) {
                return Kirigami.Theme.highlightColor;
            }
            if (controlRoot.hovered) {
                return Qt.rgba(0, 0, 0, 0.28);
            }
            return Qt.rgba(0, 0, 0, 0.16);
        }
        border.width: (controlRoot.visualFocus || controlRoot.activeFocus || controlRoot.popup.visible) ? 2 : 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }

    popup: Desktop.Menu {
        y: controlRoot.height + 4
        implicitWidth: Math.max(controlRoot.width, 160)
        Repeater {
            id: repeater
            model: controlRoot.delegateModel
        }
    }
}
