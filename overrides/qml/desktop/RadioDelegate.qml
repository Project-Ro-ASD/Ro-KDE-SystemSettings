/*
    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami
import org.kde.desktop.private as Private

T.RadioDelegate {
    id: controlRoot

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    hoverEnabled: true

    spacing: Kirigami.Units.mediumSpacing
    padding: Kirigami.Units.mediumSpacing + Kirigami.Units.smallSpacing
    bottomPadding: Kirigami.Units.smallSpacing
    leftPadding: !mirrored ? horizontalPadding + (indicator ? (controlRoot.display === T.AbstractButton.TextUnderIcon ? 0 : implicitIndicatorWidth) + spacing : 0) : horizontalPadding
    rightPadding: mirrored ? horizontalPadding + (indicator ? (controlRoot.display === T.AbstractButton.TextUnderIcon ? 0 : implicitIndicatorWidth) + spacing : 0) : horizontalPadding

    readonly property int __iconSize: controlRoot.display === T.AbstractButton.TextUnderIcon ? Kirigami.Units.iconSizes.medium : Kirigami.Units.iconSizes.smallMedium
    icon.width: __iconSize
    icon.height: __iconSize

    T.ToolTip.visible: (Kirigami.Settings.tabletMode ? down : hovered) && (contentItem.truncated ?? false)
    T.ToolTip.text: action instanceof Kirigami.Action ? action.tooltip : text
    T.ToolTip.delay: Kirigami.Settings.tabletMode ? Qt.styleHints.mousePressAndHoldInterval : Kirigami.Units.toolTipDelay

    leftInset: TableView.view ? 0 : Math.max(0, padding - Kirigami.Units.smallSpacing)
    rightInset: TableView.view ? 0 : Math.max(0, padding - Kirigami.Units.smallSpacing)
    topInset: TableView.view ? 0 : Math.max(0, topPadding - Kirigami.Units.smallSpacing)
    bottomInset: TableView.view ? 0 : Math.max(0, bottomPadding - Kirigami.Units.smallSpacing)

    contentItem: GridLayout {
        LayoutMirroring.enabled: controlRoot.mirrored
        rows: controlRoot.display === T.AbstractButton.TextUnderIcon ? 2 : 1
        columns: controlRoot.display === T.AbstractButton.TextBesideIcon ? 2 : 1
        rowSpacing: controlRoot.spacing
        columnSpacing: controlRoot.spacing

        property alias truncated: textLabel.truncated

        Kirigami.Icon {
            Layout.preferredHeight: controlRoot.icon.height
            Layout.preferredWidth: controlRoot.icon.width
            Layout.alignment: Qt.AlignVCenter | Qt.AlignHCenter
            visible: controlRoot.display !== T.AbstractButton.TextOnly
                && (controlRoot.icon.name !== "" || controlRoot.icon.source.toString() !== "")
            source: controlRoot.icon.name !== "" ? controlRoot.icon.name : controlRoot.icon.source
        }

        Label {
            id: textLabel

            Layout.fillWidth: true
            Layout.fillHeight: true

            Accessible.ignored: true

            text: controlRoot.text
            font: controlRoot.font
            color: (controlRoot.pressed && !controlRoot.checked && !controlRoot.sectionDelegate) ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
            elide: Text.ElideRight
            visible: controlRoot.display !== T.AbstractButton.IconOnly && controlRoot.text
            wrapMode: controlRoot.display === T.AbstractButton.TextUnderIcon ? Text.Wrap : Text.NoWrap
            horizontalAlignment: controlRoot.display === T.AbstractButton.TextUnderIcon ? Text.AlignHCenter : Text.AlignLeft
            verticalAlignment: controlRoot.display === T.AbstractButton.TextUnderIcon ? Text.AlignTop : Text.AlignVCenter
        }
    }

    indicator: Item {
        id: indicatorItem
        implicitWidth: 20
        implicitHeight: 20
        width: 20
        height: 20
        x: !controlRoot.mirrored ? controlRoot.horizontalPadding : controlRoot.width - width - controlRoot.horizontalPadding
        y: controlRoot.topPadding + (controlRoot.display === T.AbstractButton.TextUnderIcon ? 0 : ((controlRoot.availableHeight - height) / 2) )

        Rectangle {
            anchors.centerIn: parent
            width: 20
            height: 20
            radius: 10
            color: controlRoot.checked ? "#007aff" : "#ffffff"
            border.color: controlRoot.checked ? "#007aff" : (controlRoot.hovered ? "#007aff" : "#c4cdd5")
            border.width: controlRoot.checked ? 0 : 1.5

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
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

    background: Private.DefaultListItemBackground {
        control: controlRoot
    }
}
