/*
    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls.impl as QQC2Impl
import org.kde.kirigami as Kirigami

T.ToolButton {
    id: controlRoot

    Kirigami.Theme.colorSet: flat ? Kirigami.Theme.Window : Kirigami.Theme.Button
    Kirigami.Theme.inherit: flat

    implicitWidth: Math.max((text && display !== T.AbstractButton.IconOnly ?
        implicitBackgroundWidth : implicitHeight) + leftInset + rightInset,
        implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding)

    baselineOffset: contentItem ? contentItem.y + contentItem.baselineOffset : 0

    padding: 6
    leftPadding: (controlRoot.display === T.AbstractButton.IconOnly) ? 8 : 14
    rightPadding: (controlRoot.display === T.AbstractButton.IconOnly) ? 8 : 14
    topPadding: 6
    bottomPadding: 6
    spacing: 6

    hoverEnabled: Qt.styleHints.useHoverEffects

    flat: true
    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.SecondaryControl
    Kirigami.MnemonicData.label: text

    Shortcut {
        enabled: !(RegExp(/\&[^\&]/).test(controlRoot.text))
        sequence: controlRoot.Kirigami.MnemonicData.sequence
        onActivated: {
            if (typeof controlRoot.animateClick === "function") {
                controlRoot.animateClick();
            } else {
                controlRoot.clicked();
            }
        }
    }

    contentItem: QQC2Impl.IconLabel {
        spacing: controlRoot.spacing
        mirrored: controlRoot.mirrored
        display: controlRoot.display

        icon: controlRoot.icon
        text: controlRoot.Kirigami.MnemonicData.mnemonicLabel
        font: controlRoot.font
        color: {
            if (!controlRoot.enabled) return Kirigami.Theme.disabledTextColor;
            if (controlRoot.highlighted) return Kirigami.Theme.highlightedTextColor;
            return Kirigami.Theme.textColor;
        }
        defaultIconColor: color
    }

    background: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        radius: height / 2

        color: {
            if (!controlRoot.enabled) return "transparent";
            if (controlRoot.down || controlRoot.checked) return "#e2e8f0";
            if (controlRoot.hovered) return "#f1f5f9";
            return "#ffffff";
        }

        border.color: {
            if (!controlRoot.enabled) return "transparent";
            if (controlRoot.visualFocus || controlRoot.activeFocus) {
                return Kirigami.Theme.highlightColor;
            }
            if (controlRoot.down || controlRoot.checked || controlRoot.hovered) {
                return Qt.rgba(0, 0, 0, 0.28);
            }
            return Qt.rgba(0, 0, 0, 0.16);
        }
        border.width: (controlRoot.visualFocus || controlRoot.activeFocus) ? 2 : 1

        Behavior on color { ColorAnimation { duration: 120 } }
        Behavior on border.color { ColorAnimation { duration: 120 } }
    }
}
