/*
    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.desktop.private as Private

T.RadioButton {
    id: controlRoot

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            implicitIndicatorWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)
    baselineOffset: contentItem ? contentItem.y + contentItem.baselineOffset : 0

    spacing: Kirigami.Units.smallSpacing

    hoverEnabled: true

    indicator: Item {
        id: indicatorItem
        implicitWidth: 20
        implicitHeight: 20
        width: 20
        height: 20

        x: if (controlRoot.contentItem !== null && controlRoot.contentItem.width > 0) {
            return controlRoot.mirrored ?
                controlRoot.width - width - controlRoot.rightPadding : controlRoot.leftPadding
        } else {
            return controlRoot.leftPadding + (controlRoot.availableWidth - width) / 2
        }
        y: if (controlRoot.contentItem !== null
            && (controlRoot.contentItem instanceof Text || controlRoot.contentItem instanceof TextEdit)
            && controlRoot.contentItem.lineCount > 1) {
            return controlRoot.topPadding
        } else {
            return controlRoot.topPadding + Math.round((controlRoot.availableHeight - height) / 2)
        }

        Rectangle {
            id: outerCircle
            anchors.centerIn: parent
            width: 20
            height: 20
            radius: 10
            color: controlRoot.checked ? "#007aff" : "#ffffff"
            border.color: controlRoot.checked ? "#007aff" : (controlRoot.hovered ? "#007aff" : "#c4cdd5")
            border.width: controlRoot.checked ? 0 : 1.5

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            // İç beyaz nokta (Modern saf beyaz nokta - siyah nokta kaldırıldı)
            Rectangle {
                id: innerDot
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 4
                color: "#ffffff"
                opacity: controlRoot.checked ? 1.0 : 0.0
                scale: controlRoot.checked ? 1.0 : 0.3

                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            }
        }
    }

    Kirigami.MnemonicData.enabled: enabled && visible
    Kirigami.MnemonicData.controlType: Kirigami.MnemonicData.ActionElement
    Kirigami.MnemonicData.label: text
    Shortcut {
        enabled: !(RegExp(/\&[^\&]/).test(controlRoot.text))
        sequence: controlRoot.Kirigami.MnemonicData.sequence
        onActivated: {
            if (typeof controlRoot.animateClick === "function") {
                controlRoot.animateClick();
            } else {
                controlRoot.checked = true;
            }
        }
    }

    contentItem: Label {
        id: contentLabel

        Accessible.ignored: true

        readonly property int indicatorEffectiveWidth: controlRoot.indicator ? controlRoot.indicator.width + controlRoot.spacing : 0

        property FontMetrics fontMetrics: FontMetrics {}
        topPadding: Math.max(0, (controlRoot.implicitIndicatorHeight - fontMetrics.height) / 2)
        bottomPadding: topPadding
        leftPadding: controlRoot.indicator && !controlRoot.mirrored ? indicatorEffectiveWidth : 0
        rightPadding: controlRoot.indicator && controlRoot.mirrored ? indicatorEffectiveWidth : 0
        opacity: controlRoot.enabled ? 1 : 0.6
        text: controlRoot.Kirigami.MnemonicData.richTextLabel
        font: controlRoot.font
        elide: Text.ElideRight
        visible: controlRoot.text
        horizontalAlignment: Text.AlignLeft
        verticalAlignment: Text.AlignVCenter

        Private.FocusRect {
            control: controlRoot

            anchors {
                top: parent.top
                left: parent.left
                bottom: parent.bottom
                topMargin: contentLabel.topPadding - 1
                bottomMargin: contentLabel.bottomPadding - 1
            }

            width: contentLabel.implicitWidth + 2
        }
    }
}
