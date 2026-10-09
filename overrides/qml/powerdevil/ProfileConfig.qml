/*
 *  SPDX-FileCopyrightText: 2022, 2023 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.powerdevil as PD

ColumnLayout {
    id: root

    required property string profileId
    required property string profileLabel
    readonly property var profileSettings: kcm.settings["profile" + profileId]

    function formatPercentageText(value) {
        return i18nc(
            "Percentage value example, used for formatting brightness levels in the power management settings",
            "10%"
        ).replace("10", value);
    }

    Connections {
        target: root.profileSettings
        function onAutoSuspendIdleTimeoutSecChanged() {
            suspendComplianceWarning.showIfNeeded();
        }
        function onAutoSuspendActionChanged() {
            suspendComplianceWarning.showIfNeeded();
        }
    }


    // ==========================================
    // CARD 1: Oturumu Askıya Al
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        implicitHeight: cardCol1.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: true

        ColumnLayout {
            id: cardCol1
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "system-suspend"
                    implicitWidth: 20
                    implicitHeight: 20
                }
                Kirigami.Heading {
                    level: 4
                    text: i18nc("@title:group", "Suspend Session")
                    font.weight: Font.DemiBold
                }
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true
            //
            // Suspend Session
        
            
        
            Kirigami.InlineMessage {
                Kirigami.FormData.isSection: true
                visible: autoSuspendActionCombo.visible && !autoSuspendActionCombo.isConfiguredValueSupported
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18nc("@info:status", "The action you had previously configured to happen when inactive is now unsupported on your system. Please select a different one.")
            }
        
            RowLayout {
                id: autoSuspendActionRow
                Kirigami.FormData.label: i18nc(
                    "@label:combobox Suspend action such as sleep/hibernate to perform when the system is idle",
                    "When &inactive:"
                )
                Kirigami.FormData.buddyFor: autoSuspendActionCombo
                visible: kcm.supportedActions["SuspendSession"] === true
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
        
                ComboBoxWithIcon {
                    id: autoSuspendActionCombo
                    Accessible.name: i18nc("@accessible:name:combobox", "Action to perform when the system is idle")
        
                    Layout.fillWidth: true
                    implicitContentWidthPolicy: QQC2.ComboBox.WidestTextWhenCompleted
        
                    model: kcm.autoSuspendActionModel
                    textRole: "name"
                    valueRole: "value"
        
                    readonly property bool isConfiguredValueSupported: currentValue === profileSettings.autoSuspendAction
        
                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "AutoSuspendAction"
                    }
                    Component.onCompleted: {
                        // indexOfValue() is invalid before onCompleted, so wait until here to bind currentIndex.
                        currentIndex = Qt.binding(() => indexOfValue(profileSettings.autoSuspendAction));
                    }
                    onActivated: {
                        profileSettings.autoSuspendAction = currentValue;
                    }
                }
        
                TimeDurationComboBox {
                    id: autoSuspendIdleTimeoutCombo
                    durationPromptLabel: autoSuspendActionRow.Kirigami.FormData.label
                    durationPromptAcceptsUnits: [DurationPromptDialog.Unit.Seconds, DurationPromptDialog.Unit.Minutes]
        
                    function translateSeconds(n, formatUnit = DurationPromptDialog.Unit.Seconds) {
                        return formatUnit == DurationPromptDialog.Unit.Minutes
                            ? translateMinutes(n / 60) : i18ncp("@option:combobox", "After %1 second", "After %1 seconds", n);
                    }
                    function translateMinutes(n) { return i18ncp("@option:combobox", "After %1 minute", "After %1 minutes", n); }
        
                    valueRole: "seconds"
                    textRole: "text"
                    unitOfValueRole: DurationPromptDialog.Unit.Seconds
                    durationPromptFromValue: 60
                    presetOptions: [
                        { seconds: 1 * 60, text: translateMinutes(1), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 2 * 60, text: translateMinutes(2), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 5 * 60, text: translateMinutes(5), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 10 * 60, text: translateMinutes(10), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 15 * 60, text: translateMinutes(15), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 30 * 60, text: translateMinutes(30), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: -1, text: i18nc("@option:combobox Choose a custom value outside the list of preset values", "Custom…") },
                    ]
                    customRequesterValue: -1
                    configuredValue: profileSettings.autoSuspendIdleTimeoutSec
                    configuredDisplayUnit: model[indexOfValue(configuredValue)]?.unit ?? DurationPromptDialog.Unit.Minutes
        
                    onRegularValueActivated: {
                        profileSettings.autoSuspendIdleTimeoutSec = currentValue;
                    }
                    onCustomDurationAccepted: {
                        profileSettings.autoSuspendIdleTimeoutSec = valueToUnit(
                            customDuration.value, customDuration.unit, DurationPromptDialog.Unit.Seconds);
                    }
        
                    onConfiguredValueOptionMissing: {
                        const unit = configuredValue % 60 === 0
                            ? customDuration?.unit ?? DurationPromptDialog.Unit.Minutes
                            : DurationPromptDialog.Unit.Seconds;
        
                        customOptions = [{
                            seconds: configuredValue,
                            text: translateSeconds(configuredValue, unit),
                            unit: unit,
                        }];
                        customDuration = null;
                    }
        
                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "AutoSuspendIdleTimeoutSec"
                        extraEnabledConditions: autoSuspendActionCombo.currentValue !== PD.PowerDevil.PowerButtonAction.NoAction
                    }
                }
            }
        
            // EU Regulation 2023/826 requires automatic suspend after max. 20 minutes and a warning
            // if the user disables auto suspend.
            Kirigami.InlineMessage {
                id: suspendComplianceWarning
                Layout.fillWidth: true
                Kirigami.FormData.isSection: true
                type: Kirigami.MessageType.Warning
                visible: text !== ""
        
                function showIfNeeded() {
                    if (profileSettings.autoSuspendAction === PD.PowerDevil.PowerButtonAction.NoAction) {
                        text = i18nc("@info:status", "Disabling automatic suspend will result in higher energy consumption.");
                    } else if (profileSettings.autoSuspendIdleTimeoutSec > 20 * 60) {
                        text = i18nc("@info:status A long duration until suspend/shutdown", "A long duration will result in higher energy consumption.");
                    } else {
                        text = "";
                    }
                }
            }
        
            Kirigami.InlineMessage {
                Kirigami.FormData.isSection: true
                visible: powerButtonActionCombo.visible && !powerButtonActionCombo.isConfiguredValueSupported
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18nc("@info:status", "The action you had previously configured for when the power button is pressed is now unsupported on your system. Please select a different one.")
            }
        
            ComboBoxWithIcon {
                id: powerButtonActionCombo
                Kirigami.FormData.label: i18nc(
                    "@label:combobox Suspend action such as sleep/hibernate to perform when the power button is pressed",
                    "When &power button pressed:"
                )
                Accessible.name: i18nc("@accessible:name:combobox", "Action to perform when the power button is pressed")
        
                visible: kcm.supportedActions["HandleButtonEvents"] === true && kcm.isPowerButtonPresent
                Layout.fillWidth: true
                implicitContentWidthPolicy: QQC2.ComboBox.WidestTextWhenCompleted
        
                model: kcm.powerButtonActionModel
                textRole: "name"
                valueRole: "value"
        
                readonly property bool isConfiguredValueSupported: currentValue === profileSettings.powerButtonAction
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "PowerButtonAction"
                }
                Component.onCompleted: {
                    // indexOfValue() is invalid before onCompleted, so wait until here to bind currentIndex.
                    currentIndex = Qt.binding(() => indexOfValue(profileSettings.powerButtonAction));
                }
                onActivated: {
                    profileSettings.powerButtonAction = currentValue;
                }
            }
        
            Kirigami.InlineMessage {
                Kirigami.FormData.isSection: true
                visible: lidActionCombo.visible && !lidActionCombo.isConfiguredValueSupported
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18nc("@info:status", "The action you had previously configured for when the lid is closed is now unsupported on your system. Please select a different one.")
            }
        
            ComboBoxWithIcon {
                id: lidActionCombo
                Kirigami.FormData.label: i18nc(
                    "@label:combobox Suspend action such as sleep/hibernate to perform when the power button is pressed",
                    "When laptop &lid closed:"
                )
                Accessible.name: i18nc("@accessible:name:combobox", "Action to perform when the laptop lid is closed")
        
                visible: kcm.supportedActions["HandleButtonEvents"] === true && kcm.isLidPresent
                Layout.fillWidth: true
                implicitContentWidthPolicy: QQC2.ComboBox.WidestTextWhenCompleted
        
                model: kcm.lidActionModel
                textRole: "name"
                valueRole: "value"
        
                readonly property bool isConfiguredValueSupported: currentValue === profileSettings.lidAction
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "LidAction"
                }
                Component.onCompleted: {
                    // indexOfValue() is invalid before onCompleted, so wait until here to bind currentIndex.
                    currentIndex = Qt.binding(() => indexOfValue(profileSettings.lidAction));
                }
                onActivated: {
                    profileSettings.lidAction = currentValue;
                }
            }
        
            QQC2.CheckBox {
                id: triggersLidActionWhenExternalMonitorPresentCheck
                text: i18nc(
                    "@text:checkbox Trigger laptop lid action even when an external monitor is connected",
                    "Even when an external monitor is connected"
                )
                Accessible.name: i18n("Perform laptop lid action even when an external monitor is connected")
        
                visible: lidActionCombo.visible
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "InhibitLidActionWhenExternalMonitorPresent"
                    extraEnabledConditions: lidActionCombo.currentValue !== PD.PowerDevil.PowerButtonAction.NoAction
                }
                checked: !profileSettings.inhibitLidActionWhenExternalMonitorPresent
                onToggled: { profileSettings.inhibitLidActionWhenExternalMonitorPresent = !checked; }
            }
        
            Kirigami.InlineMessage {
                Kirigami.FormData.isSection: true
                visible: sleepModeCombo.visible && sleepModeCombo.enabled && !sleepModeCombo.isConfiguredValueSupported
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18nc("@info:status", "The sleep mode you had previously configured is now unsupported on your system. Please select a different one.")
            }
        
            QQC2.ComboBox {
                id: sleepModeCombo
                Kirigami.FormData.label: i18nc(
                    "@label:combobox Sleep mode selection - suspend to memory, disk or both",
                    "When sleeping, enter:"
                )
                Accessible.name: i18nc("@accessible:name:combobox", "When sleeping, enter this power-save mode")
        
                visible: count > 1 && (kcm.supportedActions["SuspendSession"] === true || kcm.supportedActions["HandleButtonEvents"] === true)
                Layout.fillWidth: true
                implicitContentWidthPolicy: QQC2.ComboBox.WidestTextWhenCompleted
        
                model: kcm.sleepModeModel
                textRole: "name"
                valueRole: "value"
        
                delegate: Kirigami.SubtitleDelegate {
                    required property string index
        
                    // model roles from roleNames(), expose these in your QAbstractItemModel if you haven't already
                    required property string name
                    required property string subtext
        
                    text: name
                    subtitle: subtext
                    icon.width: 0
                    width: sleepModeCombo.popup.width
                    highlighted: index === sleepModeCombo.currentIndex
                }
        
                readonly property bool isConfiguredValueSupported: currentValue === profileSettings.sleepMode
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "SleepMode"
                    extraEnabledConditions: (
                        autoSuspendActionCombo.currentValue === PD.PowerDevil.PowerButtonAction.Sleep
                        || powerButtonActionCombo.currentValue === PD.PowerDevil.PowerButtonAction.Sleep
                        || lidActionCombo.currentValue === PD.PowerDevil.PowerButtonAction.Sleep
                    )
                }
                Component.onCompleted: {
                    // indexOfValue() is invalid before onCompleted, so wait until here to bind currentIndex.
                    currentIndex = Qt.binding(() => indexOfValue(profileSettings.sleepMode));
                }
                onActivated: {
                    profileSettings.sleepMode = currentValue;
                }
            }
        

            }
        }
    }

    // ==========================================
    // CARD 2: Görüntü ve Parlaklık
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        implicitHeight: cardCol2.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: true

        ColumnLayout {
            id: cardCol2
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "video-display"
                    implicitWidth: 20
                    implicitHeight: 20
                }
                Kirigami.Heading {
                    level: 4
                    text: i18nc("@title:group", "Display and Brightness")
                    font.weight: Font.DemiBold
                }
            }

            // Display Brightness (Full Card Width)
            ColumnLayout {
                visible: kcm.supportedActions["ScreenBrightnessControl"] === true
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.CheckBox {
                        id: displayBrightnessCheck
                        text: i18nc("@option:check", "Change screen brightness")
                        font.weight: Font.DemiBold

                        KCM.SettingStateBinding {
                            configObject: profileSettings
                            settingName: "UseProfileSpecificDisplayBrightness"
                        }
                        checked: profileSettings.useProfileSpecificDisplayBrightness
                        onToggled: { profileSettings.useProfileSpecificDisplayBrightness = checked; }
                    }

                    Item { Layout.fillWidth: true }

                    QQC2.Label {
                        enabled: displayBrightnessCheck.checked
                        text: formatPercentageText(displayBrightnessSlider.value)
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.highlightColor
                        Layout.preferredWidth: displayBrightnessPercentageMetrics.width
                    }
                    TextMetrics {
                        id: displayBrightnessPercentageMetrics
                        text: formatPercentageText(100)
                    }
                }

                QQC2.Slider {
                    id: displayBrightnessSlider
                    Layout.fillWidth: true
                    from: 1
                    to: 100
                    stepSize: 1
                    enabled: displayBrightnessCheck.checked

                    background: Rectangle {
                        x: displayBrightnessSlider.leftPadding
                        y: Math.round(displayBrightnessSlider.topPadding + (displayBrightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: displayBrightnessSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, displayBrightnessSlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: displayBrightnessSlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(displayBrightnessSlider.leftPadding + displayBrightnessSlider.visualPosition * (displayBrightnessSlider.availableWidth - width))
                        y: Math.round(displayBrightnessSlider.topPadding + (displayBrightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: displayBrightnessSlider.pressed ? "#007aff" : (displayBrightnessSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: displayBrightnessSlider.pressed || displayBrightnessSlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: displayBrightnessSlider.pressed ? 0.25 : (displayBrightnessSlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: displayBrightnessSlider.pressed ? 1.08 : (displayBrightnessSlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "DisplayBrightness"
                        extraEnabledConditions: displayBrightnessCheck.checked
                    }
                    value: profileSettings.displayBrightness
                    onMoved: { profileSettings.displayBrightness = value; }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.supportedActions["ScreenBrightnessControl"] === true
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true
        
            TimeDurationComboBox {
                id: dimDisplayIdleTimeoutCombo
                visible: kcm.supportedActions["DimDisplay"] === true
                Layout.fillWidth: true
                Kirigami.FormData.label: i18nc("@label:combobox Dim screen after X minutes", "Di&m automatically:")
        
                durationPromptLabel: i18nc("@label:spinbox Dim screen after X minutes", "Di&m automatically after:")
                durationPromptAcceptsUnits: [DurationPromptDialog.Unit.Seconds, DurationPromptDialog.Unit.Minutes]
        
                function translateSeconds(n, formatUnit = DurationPromptDialog.Unit.Seconds) {
                    return formatUnit == DurationPromptDialog.Unit.Minutes
                        ? translateMinutes(n / 60) : i18ncp("@option:combobox", "%1 second", "%1 seconds", n);
                }
                function translateMinutes(n) { return i18ncp("@option:combobox", "%1 minute", "%1 minutes", n); }
        
                valueRole: "seconds"
                textRole: "text"
                unitOfValueRole: DurationPromptDialog.Unit.Seconds
                durationPromptFromValue: 10
                presetOptions: [
                    { seconds: -1, text: i18nc("@option:combobox Dim screen automatically", "Never") },
                    { seconds: 30, text: translateSeconds(30), unit: DurationPromptDialog.Unit.Seconds },
                    { seconds: 1 * 60, text: translateMinutes(1), unit: DurationPromptDialog.Unit.Minutes },
                    { seconds: 2 * 60, text: translateMinutes(2), unit: DurationPromptDialog.Unit.Minutes },
                    { seconds: 5 * 60, text: translateMinutes(5), unit: DurationPromptDialog.Unit.Minutes },
                    { seconds: 10 * 60, text: translateMinutes(10), unit: DurationPromptDialog.Unit.Minutes },
                    { seconds: 15 * 60, text: translateMinutes(15), unit: DurationPromptDialog.Unit.Minutes },
                    { seconds: -2, text: i18nc("@option:combobox Choose a custom value outside the list of preset values", "Custom…") },
                ]
                customRequesterValue: -2
                configuredValue: profileSettings.dimDisplayWhenIdle ? profileSettings.dimDisplayIdleTimeoutSec : -1
                configuredDisplayUnit: model[indexOfValue(configuredValue)]?.unit ?? DurationPromptDialog.Unit.Minutes
        
                onRegularValueActivated: {
                    profileSettings.dimDisplayIdleTimeoutSec = currentValue;
                    profileSettings.dimDisplayWhenIdle = currentValue > 0;
                }
                onCustomDurationAccepted: {
                    profileSettings.dimDisplayIdleTimeoutSec = valueToUnit(
                        customDuration.value, customDuration.unit, DurationPromptDialog.Unit.Seconds);
                    profileSettings.dimDisplayWhenIdle = customDuration.value > 0;
                }
        
                onConfiguredValueOptionMissing: {
                    const unit = configuredValue % 60 === 0
                        ? customDuration?.unit ?? DurationPromptDialog.Unit.Minutes
                        : DurationPromptDialog.Unit.Seconds;
        
                    customOptions = [{
                        seconds: configuredValue,
                        text: translateSeconds(configuredValue, unit),
                        unit: unit,
                    }];
                    customDuration = null;
                }
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "DimDisplayIdleTimeoutSec"
                }
            }
        
            Kirigami.InlineMessage {
                Kirigami.FormData.isSection: true
                visible: (
                    dimDisplayIdleTimeoutCombo.visible
                    && profileSettings.dimDisplayWhenIdle && profileSettings.turnOffDisplayWhenIdle
                    && profileSettings.dimDisplayIdleTimeoutSec >= profileSettings.turnOffDisplayIdleTimeoutSec
                    && profileSettings.dimDisplayIdleTimeoutSec >= profileSettings.turnOffDisplayIdleTimeoutWhenLockedSec
                )
                Layout.fillWidth: true
                type: Kirigami.MessageType.Warning
                text: i18nc("@info:status", "The screen will not be dimmed because it is configured to turn off sooner.")
            }
        
            RowLayout {
                id: turnOffDisplayRow
                Kirigami.FormData.label: i18nc("@label:combobox After X minutes", "&Turn off screen:")
                Kirigami.FormData.buddyFor: turnOffDisplayIdleTimeoutCombo
        
                visible: kcm.supportedActions["DPMSControl"] === true
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
        
                TimeDurationComboBox {
                    id: turnOffDisplayIdleTimeoutCombo
                    Layout.fillWidth: true
        
                    durationPromptAcceptsUnits: [DurationPromptDialog.Unit.Seconds, DurationPromptDialog.Unit.Minutes]
                    durationPromptLabel: i18nc("@label:spinbox After X minutes", "Turn off screen after:")
        
                    function translateSeconds(n, formatUnit = DurationPromptDialog.Unit.Seconds) {
                        return formatUnit == DurationPromptDialog.Unit.Minutes
                            ? translateMinutes(n / 60) : i18ncp("@option:combobox Turn off screen (caution: watch for string length)", "%1 second", "%1 seconds", n);
                    }
                    function translateMinutes(n) { return i18ncp("@option:combobox Turn off screen (caution: watch for string length)", "%1 minute", "%1 minutes", n); }
        
                    valueRole: "seconds"
                    textRole: "text"
                    unitOfValueRole: DurationPromptDialog.Unit.Seconds
                    durationPromptFromValue: 30
                    presetOptions: [
                        { seconds: -1, text: i18nc("@option:combobox Turn off screen (caution: watch for string length)", "Never") },
                        { seconds: 1 * 60, text: translateMinutes(1), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 2 * 60, text: translateMinutes(2), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 5 * 60, text: translateMinutes(5), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 10 * 60, text: translateMinutes(10), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 15 * 60, text: translateMinutes(15), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 30 * 60, text: translateMinutes(30), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: -2, text: i18nc("@option:combobox Choose a custom value outside the list of preset values (caution: watch for string length)", "Custom…") },
                    ]
                    customRequesterValue: -2
                    configuredValue: profileSettings.turnOffDisplayWhenIdle ? profileSettings.turnOffDisplayIdleTimeoutSec : -1
                    configuredDisplayUnit: model[indexOfValue(configuredValue)]?.unit ?? DurationPromptDialog.Unit.Minutes
        
                    onRegularValueActivated: {
                        profileSettings.turnOffDisplayIdleTimeoutSec = currentValue;
                        profileSettings.turnOffDisplayWhenIdle = currentValue > 0;
                    }
                    onCustomDurationAccepted: {
                        profileSettings.turnOffDisplayIdleTimeoutSec = valueToUnit(
                            customDuration.value, customDuration.unit, DurationPromptDialog.Unit.Seconds);
                        profileSettings.turnOffDisplayWhenIdle = customDuration.value > 0;
                    }
        
                    onConfiguredValueOptionMissing: {
                        const unit = configuredValue % 60 === 0
                            ? customDuration?.unit ?? DurationPromptDialog.Unit.Minutes
                            : DurationPromptDialog.Unit.Seconds;
        
                        customOptions = [{
                            seconds: configuredValue,
                            text: translateSeconds(configuredValue, unit),
                            unit: unit,
                        }];
                        customDuration = null;
                    }
        
                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "TurnOffDisplayIdleTimeoutSec"
                    }
                }
        
                TimeDurationComboBox {
                    id: turnOffDisplayIdleTimeoutWhenLockedCombo
        
                    durationPromptAcceptsUnits: [DurationPromptDialog.Unit.Seconds, DurationPromptDialog.Unit.Minutes]
                    durationPromptLabel: i18nc("@label:spinbox After X minutes", "When locked, turn off screen after:")
        
                    function translateSeconds(n, formatUnit = DurationPromptDialog.Unit.Seconds) {
                        return formatUnit == DurationPromptDialog.Unit.Minutes
                            ? translateMinutes(n / 60) : i18ncp("@option:combobox Turn off screen (caution: watch for string length)", "When locked: %1 second", "When locked: %1 seconds", n);
                    }
                    function translateMinutes(n) { return i18ncp("@option:combobox Turn off screen (caution: watch for string length)", "When locked: %1 minute", "When locked: %1 minutes", n); }
        
                    valueRole: "seconds"
                    textRole: "text"
                    unitOfValueRole: DurationPromptDialog.Unit.Seconds
                    durationPromptFromValue: 10
                    presetOptions: [
                        { seconds: -2, text: i18nc("@option:combobox Turn off screen after X minutes regardless of lock screen (caution: watch for string length)", "When locked and unlocked")  },
                        // -1 would be "Never", same as for the unlocked timeout, if we want that option
                        { seconds: 0, text: i18nc("@option:combobox Turn off screen (caution: watch for string length)", "When locked: Immediately") },
                        { seconds: 20, text: translateSeconds(20), unit: DurationPromptDialog.Unit.Seconds },
                        { seconds: 1 * 60, text: translateMinutes(1), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 2 * 60, text: translateMinutes(2), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 5 * 60, text: translateMinutes(5), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: -3, text: i18nc("@option:combobox Choose a custom value outside the list of preset values", "Custom…") },
                    ]
                    customRequesterValue: -3
                    configuredValue: profileSettings.turnOffDisplayIdleTimeoutWhenLockedSec
                    configuredDisplayUnit: model[indexOfValue(configuredValue)]?.unit ?? DurationPromptDialog.Unit.Seconds
        
                    onRegularValueActivated: { profileSettings.turnOffDisplayIdleTimeoutWhenLockedSec = currentValue; }
                    onCustomDurationAccepted: {
                        profileSettings.turnOffDisplayIdleTimeoutWhenLockedSec = valueToUnit(
                            customDuration.value, customDuration.unit, DurationPromptDialog.Unit.Seconds);
                    }
        
                    onConfiguredValueOptionMissing: {
                        const unit = configuredValue % 60 === 0
                            ? customDuration?.unit ?? DurationPromptDialog.Unit.Minutes
                            : DurationPromptDialog.Unit.Seconds;
        
                        customOptions = [{
                            seconds: configuredValue,
                            text: translateSeconds(configuredValue, unit),
                            unit: unit,
                        }];
                        customDuration = null;
                    }
        
                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "TurnOffDisplayIdleTimeoutWhenLockedSec"
                        extraEnabledConditions: profileSettings.turnOffDisplayWhenIdle
                    }
                }
            }
        }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.supportedActions["KeyboardBrightnessControl"] === true
            }

            ColumnLayout {
                visible: kcm.supportedActions["KeyboardBrightnessControl"] === true
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.CheckBox {
                        id: keyboardBrightnessCheck
                        text: i18nc("@option:check", "Change keyboard brightness")
                        font.weight: Font.DemiBold

                        KCM.SettingStateBinding {
                            configObject: profileSettings
                            settingName: "UseProfileSpecificKeyboardBrightness"
                        }
                        checked: profileSettings.useProfileSpecificKeyboardBrightness
                        onToggled: { profileSettings.useProfileSpecificKeyboardBrightness = checked; }
                    }

                    Item { Layout.fillWidth: true }

                    QQC2.Label {
                        enabled: keyboardBrightnessCheck.checked
                        text: formatPercentageText(keyboardBrightnessSlider.value)
                        font.weight: Font.DemiBold
                        color: Kirigami.Theme.highlightColor
                        Layout.preferredWidth: keyboardBrightnessPercentageMetrics.width
                    }
                    TextMetrics {
                        id: keyboardBrightnessPercentageMetrics
                        text: formatPercentageText(100)
                    }
                }

                QQC2.Slider {
                    id: keyboardBrightnessSlider
                    Layout.fillWidth: true
                    from: 0
                    to: 100
                    stepSize: 1
                    enabled: keyboardBrightnessCheck.checked

                    background: Rectangle {
                        x: keyboardBrightnessSlider.leftPadding
                        y: Math.round(keyboardBrightnessSlider.topPadding + (keyboardBrightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: keyboardBrightnessSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, keyboardBrightnessSlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: keyboardBrightnessSlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(keyboardBrightnessSlider.leftPadding + keyboardBrightnessSlider.visualPosition * (keyboardBrightnessSlider.availableWidth - width))
                        y: Math.round(keyboardBrightnessSlider.topPadding + (keyboardBrightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: keyboardBrightnessSlider.pressed ? "#007aff" : (keyboardBrightnessSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: keyboardBrightnessSlider.pressed || keyboardBrightnessSlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: keyboardBrightnessSlider.pressed ? 0.25 : (keyboardBrightnessSlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: keyboardBrightnessSlider.pressed ? 1.08 : (keyboardBrightnessSlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    KCM.SettingStateBinding {
                        configObject: profileSettings
                        settingName: "KeyboardBrightness"
                        extraEnabledConditions: keyboardBrightnessCheck.checked
                    }
                    value: profileSettings.keyboardBrightness
                    onMoved: { profileSettings.keyboardBrightness = value; }
                }
            }
        }
    }

    // ==========================================
    // CARD 3: Diğer Ayarlar
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
        border.width: 1
        implicitHeight: cardCol3.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: true

        ColumnLayout {
            id: cardCol3
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                spacing: Kirigami.Units.smallSpacing
                Kirigami.Icon {
                    source: "preferences-other"
                    implicitWidth: 20
                    implicitHeight: 20
                }
                Kirigami.Heading {
                    level: 4
                    text: i18nc("@title:group", "Other Settings")
                    font.weight: Font.DemiBold
                }
            }

            Kirigami.FormLayout {
                Layout.fillWidth: true
        
            ComboBoxWithIcon {
                id: powerProfileCombo
                Kirigami.FormData.label: i18nc(
                    "@label:combobox Power Save, Balanced or Performance profile - same options as in the Battery applet",
                    "Switch to po&wer profile:"
                )
                Accessible.name: i18nc(
                    "@accessible:name:combobox Power Save, Balanced or Performance profile - same options as in the Battery applet",
                    "Switch to power profile"
                )
        
                visible: kcm.supportedActions["PowerProfile"] === true && count > 1
                Layout.fillWidth: true
                implicitContentWidthPolicy: QQC2.ComboBox.WidestTextWhenCompleted
        
                model: kcm.powerProfileModel
                textRole: "name"
                valueRole: "value"
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "PowerProfile"
                }
                Component.onCompleted: {
                    // indexOfValue() is invalid before onCompleted, so wait until here to bind currentIndex.
                    // Also observe count - PowerProfileModel has delayed initialization due to a D-Bus call.
                    currentIndex = Qt.binding(() => count ? indexOfValue(profileSettings.powerProfile) : -1);
                }
                onActivated: {
                    profileSettings.powerProfile = currentValue;
                }
            }
        
            QQC2.Button {
                id: addScriptCommandButton
                Kirigami.FormData.label: i18nc("@label:button", "Run command or script:")
        
                visible: (kcm.supportedActions["RunScript"] === true
                    // If power states aren't switchable, only show the idleTimeoutCommand field
                    // because profile load and unload fields are not useful, just confusing.
                    && kcm.supportsBatteryProfiles
                )
                icon.name: "settings-configure"
                text: i18nc(
                    "@text:button Determine what will trigger a command or script to run in this power state",
                    "Choose run conditions"
                )
                Accessible.name: i18nc("@accessible:name:button", "Choose run conditions for command or script")
                Accessible.role: Accessible.ButtonMenu
        
                onClicked: {
                    if (addScriptCommandMenu.opened) {
                        addScriptCommandMenu.close(); // closePolicy: Popup.CloseOnPressOutside does not seem to work?
                    } else {
                        addScriptCommandMenu.open();
                    }
                }
        
                QQC2.Menu {
                    id: addScriptCommandMenu
                    title: addScriptCommandButton.text
                    y: addScriptCommandButton.height
        
                    Kirigami.Action {
                        id: profileLoadCommandEditAction
                        text: i18nc(
                            "@text:action:menu Command or script to run for power state (On AC Power, On Battery, ...)",
                            "When entering \"%1\" state", root.profileLabel
                        )
                        checkable: true
                        Component.onCompleted: {
                            profileLoadCommandEditAction.checked = profileSettings.profileLoadCommand !== "";
                        }
                        onToggled: {
                            if (checked) {
                                profileLoadCommandEdit.forceActiveFocus();
                            } else {
                                profileSettings.profileLoadCommand = "";
                            }
                        }
                    }
                    Kirigami.Action {
                        id: profileUnloadCommandEditAction
                        text: i18nc(
                            "@text:action:menu Command or script to run for power state (On AC Power, On Battery, ...)",
                            "When exiting \"%1\" state", root.profileLabel
                        )
                        checkable: true
                        Component.onCompleted: {
                            profileUnloadCommandEditAction.checked = profileSettings.profileUnloadCommand !== "";
                        }
                        onToggled: {
                            if (checked) {
                                profileUnloadCommandEdit.forceActiveFocus();
                            } else {
                                profileSettings.profileUnloadCommand = "";
                            }
                        }
                    }
                    Kirigami.Action {
                        id: idleTimeoutCommandEditAction
                        text: i18nc(
                            "@text:action:menu Command or script to run",
                            "When inactive"
                        )
                        checkable: true
                        Component.onCompleted: {
                            idleTimeoutCommandEditAction.checked = (profileSettings.idleTimeoutCommand !== ""
                                // Always show field, regardless of addScriptCommandButton.visible.
                                || (kcm.supportedActions["RunScript"] === true && !kcm.supportsBatteryProfiles));
                        }
                        onToggled: {
                            if (checked) {
                                idleTimeoutCommandEdit.forceActiveFocus();
                            } else {
                                profileSettings.idleTimeoutCommand = "";
                            }
                        }
                    }
                }
            }
        
            RunScriptEdit {
                id: profileLoadCommandEdit
                Kirigami.FormData.label: i18nc(
                    "@label:textfield Command or script to run for power state (On AC Power, On Battery, ...)",
                    "When e&ntering \"%1\" state:", root.profileLabel
                )
                Accessible.name: i18nc(
                    "@label:textfield for power state (On AC Power, On Battery, ...)",
                    "Command or script when entering \"%1\" state", root.profileLabel
                )
                visible: profileLoadCommandEditAction.checked
                Layout.fillWidth: true
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "ProfileLoadCommand"
                }
                command: profileSettings.profileLoadCommand
                onCommandChanged: {
                    profileSettings.profileLoadCommand = command;
                }
                function resetToProfileSettings() {
                    command = profileSettings.profileLoadCommand;
                    profileLoadCommandEditAction.checked |= profileSettings.profileLoadCommand !== "";
                }
                Connections {
                    target: root
                    function onProfileSettingsChanged() { profileLoadCommandEdit.resetToProfileSettings(); }
                }
                Connections {
                    target: profileSettings
                    function onProfileLoadCommandChanged() { profileLoadCommandEdit.resetToProfileSettings(); }
                }
            }
        
            RunScriptEdit {
                id: profileUnloadCommandEdit
                Kirigami.FormData.label: i18nc(
                    "@label:textfield Command or script to run for power state (On AC Power, On Battery, ...)",
                    "When e&xiting \"%1\" state:", root.profileLabel
                )
                Accessible.name: i18nc(
                    "@label:textfield for power state (On AC Power, On Battery, ...)",
                    "Command or script when exiting \"%1\" state", root.profileLabel
                )
                visible: profileUnloadCommandEditAction.checked
                Layout.fillWidth: true
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "ProfileUnloadCommand"
                }
                command: profileSettings.profileUnloadCommand
                onCommandChanged: {
                    profileSettings.profileUnloadCommand = command;
                }
                function resetToProfileSettings() {
                    command = profileSettings.profileUnloadCommand;
                    profileUnloadCommandEditAction.checked |= profileSettings.profileUnloadCommand !== "";
                }
                Connections {
                    target: root
                    function onProfileSettingsChanged() { profileUnloadCommandEdit.resetToProfileSettings(); }
                }
                Connections {
                    target: profileSettings
                    function onProfileUnloadCommandChanged() { profileUnloadCommandEdit.resetToProfileSettings(); }
                }
            }
        
            TimeDurationComboBox {
                id: idleTimeoutCommandTimeDelayCombo
                Accessible.name: i18nc("@accessible:name:spinbox", "Duration of inactivity before the command or script runs")
                Layout.fillWidth: true
                visible: idleTimeoutCommandEdit.visible
        
                Kirigami.FormData.label: i18nc(
                    "@label:textfield Command or script to run",
                    "When i&nactive:"
                )
                
                durationPromptLabel: i18nc("@label:spinbox After X minutes", "Run command or script after:")
                durationPromptAcceptsUnits: [DurationPromptDialog.Unit.Seconds, DurationPromptDialog.Unit.Minutes]
        
                function translateSeconds(n, formatUnit = DurationPromptDialog.Unit.Seconds) {
                    return formatUnit == DurationPromptDialog.Unit.Minutes
                        ? translateMinutes(n / 60) : i18ncp("@option:combobox", "Run after %1 second", "Run after %1 seconds", n);
                }
                function translateMinutes(n) { return i18ncp("@option:combobox", "Run after %1 minute", "Run after %1 minutes", n); }
        
                valueRole: "seconds"
                textRole: "text"
                unitOfValueRole: DurationPromptDialog.Unit.Seconds
                durationPromptFromValue: 10
                presetOptions: [
                        { seconds: 1 * 60, text: translateMinutes(1), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 2 * 60, text: translateMinutes(2), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 5 * 60, text: translateMinutes(5), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 10 * 60, text: translateMinutes(10), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 15 * 60, text: translateMinutes(15), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: 30 * 60, text: translateMinutes(30), unit: DurationPromptDialog.Unit.Minutes },
                        { seconds: -1, text: i18nc("@option:combobox Choose a custom value outside the list of preset values", "Custom…") },
                ]
                customRequesterValue: -1
                configuredValue: profileSettings.runScriptIdleTimeoutSec
                configuredDisplayUnit: model[indexOfValue(configuredValue)]?.unit ?? DurationPromptDialog.Unit.Minutes
        
                onRegularValueActivated: { profileSettings.runScriptIdleTimeoutSec = currentValue; }
                onCustomDurationAccepted: {
                    profileSettings.runScriptIdleTimeoutSec = valueToUnit(
                        customDuration.value, customDuration.unit, DurationPromptDialog.Unit.Seconds);
                }
        
                onConfiguredValueOptionMissing: {
                    const unit = configuredValue % 60 === 0
                        ? customDuration?.unit ?? DurationPromptDialog.Unit.Minutes
                        : DurationPromptDialog.Unit.Seconds;
        
                    customOptions = [{
                        seconds: configuredValue,
                        text: translateSeconds(configuredValue, unit),
                        unit: unit,
                    }];
                    customDuration = null;
                }
            }
        
            RunScriptEdit {
                id: idleTimeoutCommandEdit
                
                Accessible.name: i18nc("@accessible:name:textfield", "Command or script when inactive")
        
                visible: idleTimeoutCommandEditAction.checked
                Layout.fillWidth: true
        
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "IdleTimeoutCommand"
                }
                command: profileSettings.idleTimeoutCommand
                onCommandChanged: {
                    profileSettings.idleTimeoutCommand = command;
                }
                function resetToProfileSettings() {
                    command = profileSettings.idleTimeoutCommand;
                    idleTimeoutCommandEditAction.checked |= profileSettings.idleTimeoutCommand !== "";
                }
                Connections {
                    target: root
                    function onProfileSettingsChanged() { idleTimeoutCommandEdit.resetToProfileSettings(); }
                }
                Connections {
                    target: profileSettings
                    function onIdleTimeoutCommandChanged() { idleTimeoutCommandEdit.resetToProfileSettings(); }
                }
                
                KCM.SettingStateBinding {
                    configObject: profileSettings
                    settingName: "RunScriptIdleTimeoutSec"
                }
            }
            }
        }
    }
}

