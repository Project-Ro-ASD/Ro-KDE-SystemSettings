/*
 *   SPDX-FileCopyrightText: 2021 Jan Blackquill <uhhadd@gmail.com>
 *   SPDX-License-Identifier: LGPL-2.0-only
 */
import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.systemsettings

ItemDelegate {
    id: delegate

    property bool showArrow: false
    property bool selected: delegate.highlighted || delegate.pressed
    property bool isSearching: false
    property real leadingPadding: 0
    property bool showDefaultIndicator: false
    property QtObject auxiliaryAction: null

    width: ListView.view?.width ?? 0

    Accessible.name: text
    Accessible.onPressAction: clicked()

    contentItem: RowLayout {
        spacing: Kirigami.Units.smallSpacing

        Kirigami.IconTitleSubtitle {
            id: titleItem
            Layout.fillWidth: true
            Layout.leftMargin: delegate.leadingPadding
            icon: icon.fromControlsIcon(delegate.icon)
            title: delegate.text
            selected: delegate.selected
        }

        Kirigami.Badge {
            Layout.alignment: Qt.AlignVCenter
            Layout.preferredWidth: Kirigami.Units.largeSpacing
            Layout.preferredHeight: Kirigami.Units.largeSpacing

            visible: delegate.showDefaultIndicator && systemsettings.defaultsIndicatorsVisible
            type: Kirigami.Badge.Type.Warning
        }

        Component {
            id: auxiliaryButtonActionComponent

            ToolButton {
                implicitWidth: height
                implicitHeight: titleItem.height
                icon.color: delegate.selected || pressed || visualFocus ? palette.highlight : palette.buttonText

                display: AbstractButton.IconOnly
                text: delegate.auxiliaryAction ? delegate.auxiliaryAction.text : ""
                icon.name: delegate.auxiliaryAction ? systemsettings.actionIconName(delegate.auxiliaryAction) : ""
                onClicked: {
                    if (delegate.auxiliaryAction) delegate.auxiliaryAction.trigger();
                }

                ToolTip.text: delegate.auxiliaryAction ? (delegate.auxiliaryAction.tooltip || delegate.auxiliaryAction.text) : ""
                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.visible: ToolTip.text !== "" && (Kirigami.Settings.tabletMode ? pressed : hovered)
            }
        }

        Component {
            id: auxiliarySwitchActionComponent

            Switch {
                Accessible.name: delegate.auxiliaryAction ? delegate.auxiliaryAction.text : ""
                checked: delegate.auxiliaryAction ? delegate.auxiliaryAction.checked : false
                onToggled: {
                    if (delegate.auxiliaryAction) delegate.auxiliaryAction.trigger();
                }

                ToolTip.text: delegate.auxiliaryAction ? (delegate.auxiliaryAction.tooltip || delegate.auxiliaryAction.text) : ""
                ToolTip.delay: Kirigami.Units.toolTipDelay
                ToolTip.visible: ToolTip.text !== "" && (Kirigami.Settings.tabletMode ? pressed : hovered)
            }
        }

        Loader {
            Layout.fillHeight: true
            Layout.topMargin: -delegate.topPadding + delegate.topInset
            Layout.bottomMargin: -delegate.bottomPadding + delegate.bottomInset
            Layout.rightMargin: -delegate.rightPadding + delegate.rightInset

            enabled: delegate.auxiliaryAction?.enabled ?? false
            visible: status === Loader.Ready
            sourceComponent: {
                const action = delegate.auxiliaryAction;
                if (action && action.visible) {
                    if (action.checkable) {
                        return auxiliarySwitchActionComponent;
                    } else {
                        return auxiliaryButtonActionComponent;
                    }
                }
                return null;
            }
        }

        Text {
            Layout.alignment: Qt.AlignVCenter
            Layout.rightMargin: Kirigami.Units.smallSpacing
            visible: delegate.showArrow && (!delegate.auxiliaryAction || !delegate.auxiliaryAction.visible)
            text: ">"
            font.pixelSize: 13
            font.bold: true
            color: delegate.selected ? palette.highlightedText : palette.text
            opacity: delegate.selected ? 0.85 : 0.4
        }
    }
}
