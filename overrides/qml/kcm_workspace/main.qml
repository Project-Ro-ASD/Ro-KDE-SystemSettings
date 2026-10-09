/*
    SPDX-FileCopyrightText: 2018 Furkan Tokac <furkantokac34@gmail.com>
    SPDX-FileCopyrightText: 2019 Nate Graham <nate@kde.org>
    SPDX-FileCopyrightText: 2026 Kayseri Design Modern Overrides

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.kwindowsystem

import org.kde.plasma.workspaceoptions.kcm

KCM.SimpleKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 42

    component ModernRadio: QQC2.RadioButton {
        id: radioCtrl
        indicator: Rectangle {
            implicitWidth: 20
            implicitHeight: 20
            radius: 10
            color: radioCtrl.checked ? "#007aff" : "#ffffff"
            border.color: radioCtrl.checked ? "#007aff" : (radioCtrl.hovered ? "#007aff" : "#cbd5e1")
            border.width: radioCtrl.checked ? 0 : 1.5

            Behavior on color { ColorAnimation { duration: 150 } }
            Behavior on border.color { ColorAnimation { duration: 150 } }

            Rectangle {
                anchors.centerIn: parent
                width: 8
                height: 8
                radius: 4
                color: "#ffffff"
                opacity: radioCtrl.checked ? 1.0 : 0.0
                scale: radioCtrl.checked ? 1.0 : 0.3

                Behavior on opacity { NumberAnimation { duration: 150 } }
                Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
            }
        }
    }

    headerPaddingEnabled: false
    header: Kirigami.InlineMessage {
        id: primarySelectionRebootMessage
        position: Kirigami.InlineMessage.Position.Header
        type: Kirigami.MessageType.Information
        text: i18nc("@info:status inlinemessage", "The system must be restarted before changes to the middle-click paste setting can take effect.")
        visible: false
        showCloseButton: true
        actions: [
            Kirigami.Action {
                icon.name: "system-reboot"
                text: i18nc("@action:button", "Restart")
                onTriggered: kcm.requestReboot();
            }
        ]
        Connections {
            target: kcm
            function onPrimarySelectionOptionSaved() {
                primarySelectionRebootMessage.visible = true;
            }
        }
    }

    QQC2.ButtonGroup { id: scrollHandleBehaviorGroup }
    QQC2.ButtonGroup { id: singleClickGroup }
    QQC2.ButtonGroup { id: dndBehaviorGroup }
    QQC2.ButtonGroup { id: tabletModeBehaviorGroup }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // ==========================================
        // SECTION 1: Plasma
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Plasma")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: plasmaCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: plasmaCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Tooltips
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("Part of the sentence 'Allow Plasma to show panel and widget tooltips'", "Panel and widget tooltips")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:tooltip", "Show descriptive tooltips when hovering over Plasma widgets and panel items")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    QQC2.Switch {
                        id: tooltipDisablerCheckbox
                        checked: kcm.plasmaSettings.delay > 0
                        onCheckedChanged: kcm.plasmaSettings.delay = (checked ? 0.7 : -1)

                        KCM.SettingStateBinding {
                            configObject: kcm.plasmaSettings
                            settingName: "delay"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: OSD popups
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("Part of the sentence 'Allow Plasma to show OSD popups for status changes'", "OSD popups for status changes")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:whatsthis contextualhelpbutton tooltip", "Show on-screen popups for volume, brightness, and audio changes")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    QQC2.Switch {
                        id: osdDisablerCheckbox
                        checked: kcm.plasmaSettings.osdEnabled
                        onCheckedChanged: kcm.plasmaSettings.osdEnabled = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.plasmaSettings
                            settingName: "osdEnabled"
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECTION 2: Scrolling
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Scrolling")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: scrollCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: scrollCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Click track location
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@radio part of a complete sentence: 'Clicking in scrollbar track scrolls to the clicked location'", "Scroll to clicked location")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@title:group prefix radiobutton group", "Clicking in scrollbar track scrolls directly to position")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        checked: !kcm.globalsSettings.scrollbarLeftClickNavigatesByPage
                        onToggled: kcm.globalsSettings.scrollbarLeftClickNavigatesByPage = false
                        QQC2.ButtonGroup.group: scrollHandleBehaviorGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "scrollbarLeftClickNavigatesByPage"
                            extraEnabledConditions: scrollbarLeftClickNavigatesByPage.enabled
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Click track by page
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@radio part of a complete sentence: 'Clicking in scrollbar track scrolls one page up or down'", "Scroll one page up or down")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:usagetip", "Middle-click to scroll to clicked location")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        id: scrollbarLeftClickNavigatesByPage
                        checked: kcm.globalsSettings.scrollbarLeftClickNavigatesByPage
                        onToggled: kcm.globalsSettings.scrollbarLeftClickNavigatesByPage = true
                        QQC2.ButtonGroup.group: scrollHandleBehaviorGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "scrollbarLeftClickNavigatesByPage"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 3: Smooth scrolling
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:check", "Prefer smooth scrolling")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:tooltip", "Enables animated transitions when scrolling with a wheel or keyboard")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    QQC2.Switch {
                        id: smoothScrollingCheckbox
                        checked: kcm.globalsSettings.smoothScroll
                        onToggled: kcm.globalsSettings.smoothScroll = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "smoothScroll"
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECTION 3: Clicking
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Clicking")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: clickCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: clickCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Click selects
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("part of a sentence: 'Clicking files or folders selects them'", "Clicking files or folders selects them")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:usagetip", "Open by double-clicking instead")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        id: doubleClick
                        checked: !kcm.globalsSettings.singleClick
                        onToggled: kcm.globalsSettings.singleClick = false
                        QQC2.ButtonGroup.group: singleClickGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "singleClick"
                            extraEnabledConditions: singleClick.enabled
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Click opens
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("part of a sentence: 'Clicking files or folders opens them'", "Clicking files or folders opens them")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:usagetip", "Select by clicking on item's selection marker")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        id: singleClick
                        checked: kcm.globalsSettings.singleClick
                        onToggled: kcm.globalsSettings.singleClick = true
                        QQC2.ButtonGroup.group: singleClickGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "singleClick"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: KWindowSystem.isPlatformWayland
                }

                // Row 3: Middle click paste
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: KWindowSystem.isPlatformWayland

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:check part of a complete sentence: 'Middle click pastes selected text'", "Middle click pastes selected text")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@label for checkbox, part of a complete sentence: 'Middle-click pastes selected text'", "Middle-click in text areas inserts clipboard selection")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    QQC2.Switch {
                        id: primarySelectionRadio
                        checked: kcm.kwinSettings.primarySelection
                        onToggled: kcm.kwinSettings.primarySelection = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.kwinSettings
                            settingName: "primarySelection"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 4: Double click interval
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@label:spinbox", "Double-click interval:")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("Test double-click speed", "Double-click the folder to test speed")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.SpinBox {
                            id: spinbox
                            from: 100
                            to: 2000
                            stepSize: 100

                            validator: IntValidator {
                                bottom: Math.min(spinbox.from, spinbox.to)
                                top: Math.max(spinbox.from, spinbox.to)
                            }

                            textFromValue: (value, locale) => i18ncp("short for millisecond(s)", "%1 ms", "%1 ms", value)
                            valueFromText: (text, locale) => Number.fromLocaleString(locale, text.replace(i18nc("short for millisecond(s)", "ms"), ""))

                            onValueModified: kcm.globalsSettings.doubleClickInterval = value
                            value: kcm.globalsSettings.doubleClickInterval

                            KCM.SettingStateBinding {
                                configObject: kcm.globalsSettings
                                settingName: "doubleClickInterval"
                            }
                        }

                        QQC2.Frame {
                            Layout.preferredWidth: Kirigami.Units.iconSizes.large
                            Layout.preferredHeight: Kirigami.Units.iconSizes.large
                            Kirigami.Theme.colorSet: Kirigami.Theme.View

                            Kirigami.Icon {
                                id: doubleClickTestIcon
                                property bool checked: false
                                anchors.fill: parent
                                source: checked ? "folder-open" : "folder"
                            }

                            MouseArea {
                                anchors.fill: parent
                                hoverEnabled: true
                                onPressed: {
                                    if (testDoubleClickTimer.running) {
                                        doubleClickTestIcon.checked = !doubleClickTestIcon.checked
                                        testDoubleClickTimer.stop()
                                    } else {
                                        testDoubleClickTimer.start()
                                    }
                                }
                                onExited: testDoubleClickTimer.stop()
                            }

                            Timer {
                                id: testDoubleClickTimer
                                interval: kcm.globalsSettings.doubleClickInterval
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECTION 4: Drag and Drop
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group prefix radiobutton group", "Drag and Drop")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: dndCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: dndCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Always ask
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:radio When dragging...", "Always ask what to do")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: xi18nc("@info", "Hold <shortcut>Shift</shortcut> to move, <shortcut>Ctrl</shortcut> to copy, and <shortcut>Shift+Ctrl</shortcut> to create a symlink")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            wrapMode: Text.WordWrap
                            Layout.fillWidth: true
                        }
                    }

                    ModernRadio {
                        id: dndBehaviorAsk
                        enabled: !kcm.globalsSettings.isImmutable("dndBehavior")
                        checked: kcm.globalsSettings.dndBehavior === WorkspaceOptionsGlobalsSettings.AlwaysAsk
                        onToggled: kcm.globalsSettings.dndBehavior = WorkspaceOptionsGlobalsSettings.AlwaysAsk
                        QQC2.ButtonGroup.group: dndBehaviorGroup
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Move if same device
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:radio When dragging…", "Move if on the same device")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: xi18nc("@info", "Hold <shortcut>Shift</shortcut> when dropping to show other options")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        id: dndBehaviorMove
                        enabled: !kcm.globalsSettings.isImmutable("dndBehavior")
                        checked: kcm.globalsSettings.dndBehavior === WorkspaceOptionsGlobalsSettings.MoveIfSameDevice
                        onToggled: kcm.globalsSettings.dndBehavior = WorkspaceOptionsGlobalsSettings.MoveIfSameDevice
                        QQC2.ButtonGroup.group: dndBehaviorGroup
                    }
                }
            }
        }

        // ==========================================
        // SECTION 5: Touch
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Touch")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: touchCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: touchCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Auto enable
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: KWindowSystem.isPlatformWayland ? i18nc("As in: 'Tablet Mode is automatically enabled as needed'", "Automatically enable as needed") : i18nc("As in: 'Tablet Mode is never enabled'", "Never enabled")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18nc("@info:whatsthis contextualhelpbutton tooltip", "Tablet Mode enabled when touchscreen detected without keyboard/mouse")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ModernRadio {
                        id: touchEnabledRadio
                        checked: kcm.kwinSettings.tabletMode === "auto"
                        onToggled: { if (checked) kcm.kwinSettings.tabletMode = "auto" }
                        QQC2.ButtonGroup.group: tabletModeBehaviorGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.kwinSettings
                            settingName: "tabletMode"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Always enabled
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("As in: 'Tablet Mode is always enabled'", "Always enabled")
                            font.weight: Font.DemiBold
                        }
                    }

                    ModernRadio {
                        checked: kcm.kwinSettings.tabletMode === "on"
                        onToggled: { if (checked) kcm.kwinSettings.tabletMode = "on" }
                        QQC2.ButtonGroup.group: tabletModeBehaviorGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.kwinSettings
                            settingName: "tabletMode"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: KWindowSystem.isPlatformWayland
                }

                // Row 3: Disabled
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: KWindowSystem.isPlatformWayland

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("As in: 'Tablet Mode is never enabled'", "Disabled")
                            font.weight: Font.DemiBold
                        }
                    }

                    ModernRadio {
                        id: touchModeAlwaysOffRadioButton
                        checked: kcm.kwinSettings.tabletMode === "off"
                        onToggled: { if (checked) kcm.kwinSettings.tabletMode = "off" }
                        QQC2.ButtonGroup.group: tabletModeBehaviorGroup

                        KCM.SettingStateBinding {
                            configObject: kcm.kwinSettings
                            settingName: "tabletMode"
                        }
                    }
                }
            }
        }
    }
}
