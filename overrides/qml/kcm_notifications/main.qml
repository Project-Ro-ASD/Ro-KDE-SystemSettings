/*
    SPDX-FileCopyrightText: 2019 Kai Uwe Broulik <kde@privat.broulik.de>
    SPDX-FileCopyrightText: 2025 Akseli Lahtinen <akselmo@akselmo.dev>
    SPDX-FileCopyrightText: 2026 Kayseri Design Modern Overrides

    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.kcmutils as KCM

import org.kde.notificationmanager as NotificationManager

KCM.SimpleKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 42

    readonly property string ourServerVendor: "KDE"
    readonly property string ourServerName: "Plasma"

    readonly property NotificationManager.ServerInfo currentOwnerInfo: NotificationManager.Server.currentOwner

    readonly property bool notificationsAvailable: currentOwnerInfo.status === NotificationManager.ServerInfo.Running
        && currentOwnerInfo.vendor === ourServerVendor && currentOwnerInfo.name === ourServerName

    function openSourcesSettings(args) {
        kcm.push("SourcesPage.qml", args);
    }

    function openSystemNotificationSettings() {
        const idx = kcm.sourcesModel.persistentIndexForNotifyRcName(kcm.plasmaWorkspaceNotifyRcName);
        root.openSourcesSettings({
            rootIndex: idx,
            showOnlyEventsConfig: true
        });
    }

    actions: [
        Kirigami.Action {
            text: i18nc("@action:button Plasma-specific notifications", "Configure for System…")
            icon.name: "plasma-symbolic"
            enabled: root.notificationsAvailable
            onTriggered: root.openSystemNotificationSettings()
        },
        Kirigami.Action {
            text: i18nc("@action:button Application-specific notifications", "Configure for Applications…")
            icon.name: "applications-all-symbolic"
            enabled: root.notificationsAvailable
            onTriggered: root.openSourcesSettings()
        }
    ]

    Connections {
        target: kcm
        function onNavigateToComponent(desktopEntry, notifyRcName, eventId) {
            while (kcm.depth > 1) {
                kcm.pop();
            }
            if (!desktopEntry && !notifyRcName) {
                return;
            }

            const showSystemNotifications = (notifyRcName === kcm.plasmaWorkspaceNotifyRcName
                && (!desktopEntry || (eventId && eventId !== "notification")));

            let idx = kcm.sourcesModel.persistentIndexForDesktopEntry(desktopEntry);
            if (showSystemNotifications || !idx.valid) {
                idx = kcm.sourcesModel.persistentIndexForNotifyRcName(notifyRcName);
            }

            root.openSourcesSettings({
                rootIndex: idx,
                showOnlyEventsConfig: showSystemNotifications,
                eventId: notifyRcName ? eventId : "",
            });
        }
    }

    headerPaddingEnabled: false
    header: ColumnLayout {
        spacing: 0

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Error
            text: i18n("Could not find a 'Notifications' widget, which is required for displaying notifications. Make sure that it is enabled either in your System Tray or as a standalone widget.");
            visible: currentOwnerInfo.status === NotificationManager.ServerInfo.NotRunning
        }

        Kirigami.InlineMessage {
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Information
            text: {
                if (currentOwnerInfo.vendor && currentOwnerInfo.name) {
                    return i18nc("Vendor and product name",
                                 "Notifications are currently provided by '%1 %2' instead of Plasma.",
                                 currentOwnerInfo.vendor, currentOwnerInfo.name);
                }
                return i18n("Notifications are currently not provided by Plasma.");
            }
            visible: root.currentOwnerInfo.status === NotificationManager.ServerInfo.Running
                && (currentOwnerInfo.vendor !== root.ourServerVendor || currentOwnerInfo.name !== root.ourServerName)
        }
    }

    PopupPositionDialog {
        id: popupPositionDialog
        parent: root
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // ==========================================
        // SECTION 1: Do Not Disturb Mode
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Do Not Disturb mode")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
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

                // Row 1: When screens are mirrored
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("Automatically enable Do Not Disturb mode when screens are mirrored", "When screens are mirrored")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.dndSettings.whenScreensMirrored
                        onClicked: kcm.dndSettings.whenScreensMirrored = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.dndSettings
                            settingName: "WhenScreensMirrored"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: Qt.platform.pluginName.includes("wayland")
                }

                // Row 2: During screen sharing
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: Qt.platform.pluginName.includes("wayland")

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("Automatically enable Do Not Disturb mode during screen sharing", "During screen sharing")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.dndSettings.whenScreenSharing
                        onClicked: kcm.dndSettings.whenScreenSharing = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.dndSettings
                            settingName: "WhenScreenSharing"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 3: When fullscreen app focused
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("Automatically enable Do Not Disturb mode while a fullscreen application is focused", "While a fullscreen application is focused")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.dndSettings.whenFullscreen
                        onClicked: kcm.dndSettings.whenFullscreen = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.dndSettings
                            settingName: "WhenFullscreen"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 4: Shortcut toggle
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("Keyboard shortcut to turn Do Not Disturb mode on and off", "Manually toggle with shortcut")
                            font.weight: Font.DemiBold
                        }
                    }

                    KQuickControls.KeySequenceItem {
                        enabled: root.notificationsAvailable
                        keySequence: kcm.toggleDoNotDisturbShortcut
                        onCaptureFinished: kcm.toggleDoNotDisturbShortcut = keySequence
                    }
                }
            }
        }

        // ==========================================
        // SECTION 2: Visibility Conditions
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Visibility conditions")
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
            implicitHeight: visCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: visCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Critical notifications
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18n("Critical notifications in Do Not Disturb mode")
                            font.weight: Font.DemiBold
                        }
                        QtControls.Label {
                            text: i18n("Always show high priority alerts even when silenced")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.notificationSettings.criticalInDndMode
                        onClicked: kcm.notificationSettings.criticalInDndMode = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.notificationSettings
                            settingName: "CriticalInDndMode"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Low priority notifications popup
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18n("Show low priority notification popups")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.notificationSettings.lowPriorityPopups
                        onClicked: kcm.notificationSettings.lowPriorityPopups = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.notificationSettings
                            settingName: "LowPriorityPopups"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 3: Low priority notifications in history
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18n("Show low priority notifications in history")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.notificationSettings.lowPriorityHistory
                        onClicked: kcm.notificationSettings.lowPriorityHistory = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.notificationSettings
                            settingName: "LowPriorityHistory"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECTION 3: Popups
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group As in: 'notification popups'", "Popups")
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
            implicitHeight: popCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: popCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Location
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("@label", "Popup location")
                            font.weight: Font.DemiBold
                        }
                    }

                    RowLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QtControls.ButtonGroup {
                            id: positionGroup
                            buttons: [positionCloseToWidget, positionCustomPosition]
                        }

                        QtControls.RadioButton {
                            id: positionCloseToWidget
                            text: i18nc("Popup position near notification plasmoid", "Near notification icon")
                            checked: kcm.notificationSettings.popupPosition === NotificationManager.Settings.CloseToWidget + kcm.currentIndex * 0
                            onClicked: kcm.notificationSettings.popupPosition = NotificationManager.Settings.CloseToWidget

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: 10
                                color: positionCloseToWidget.checked ? "#007aff" : "#ffffff"
                                border.color: positionCloseToWidget.checked ? "#007aff" : (positionCloseToWidget.hovered ? "#007aff" : "#cbd5e1")
                                border.width: positionCloseToWidget.checked ? 0 : 1.5

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: "#ffffff"
                                    opacity: positionCloseToWidget.checked ? 1.0 : 0.0
                                    scale: positionCloseToWidget.checked ? 1.0 : 0.3

                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                }
                            }

                            KCM.SettingStateBinding {
                                configObject: kcm.notificationSettings
                                settingName: "PopupPosition"
                                extraEnabledConditions: root.notificationsAvailable
                            }
                        }

                        QtControls.RadioButton {
                            id: positionCustomPosition
                            checked: kcm.notificationSettings.popupPosition !== NotificationManager.Settings.CloseToWidget + kcm.currentIndex * 0
                            text: i18nc("@action:button choose custom notification position", "Custom…")
                            onClicked: popupPositionDialog.open()

                            indicator: Rectangle {
                                implicitWidth: 20
                                implicitHeight: 20
                                radius: 10
                                color: positionCustomPosition.checked ? "#007aff" : "#ffffff"
                                border.color: positionCustomPosition.checked ? "#007aff" : (positionCustomPosition.hovered ? "#007aff" : "#cbd5e1")
                                border.width: positionCustomPosition.checked ? 0 : 1.5

                                Behavior on color { ColorAnimation { duration: 150 } }
                                Behavior on border.color { ColorAnimation { duration: 150 } }

                                Rectangle {
                                    anchors.centerIn: parent
                                    width: 8
                                    height: 8
                                    radius: 4
                                    color: "#ffffff"
                                    opacity: positionCustomPosition.checked ? 1.0 : 0.0
                                    scale: positionCustomPosition.checked ? 1.0 : 0.3

                                    Behavior on opacity { NumberAnimation { duration: 150 } }
                                    Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                                }
                            }

                            KCM.SettingStateBinding {
                                configObject: kcm.notificationSettings
                                settingName: "PopupPosition"
                                extraEnabledConditions: root.notificationsAvailable
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Hide after timeout
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("Part of a sentence like, 'Hide popup after n seconds'", "Hide popup after")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.SpinBox {
                        id: timeoutSpinner
                        from: 1000
                        to: 120000
                        stepSize: 1000
                        value: kcm.notificationSettings.popupTimeout
                        editable: true
                        valueFromText: function(text, locale) {
                            return parseInt(text) * 1000;
                        }
                        textFromValue: function(value, locale) {
                            return i18np("%1 second", "%1 seconds", Math.round(value / 1000));
                        }
                        onValueModified: kcm.notificationSettings.popupTimeout = value

                        KCM.SettingStateBinding {
                            configObject: kcm.notificationSettings
                            settingName: "PopupTimeout"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 3: Timeout indicator
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18nc("@option:check Show progress bar on notifications indicating when it will hide", "Show timeout indicator")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.notificationSettings.showPopupTimeout
                        onClicked: kcm.notificationSettings.showPopupTimeout = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.notificationSettings
                            settingName: "ShowPopupTimeout"
                            extraEnabledConditions: root.notificationsAvailable
                        }
                    }
                }
            }
        }

        // ==========================================
        // SECTION 4: Feedback & Badges
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Additional feedback")
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
            implicitHeight: feedCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: feedCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Application jobs in notifications
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18n("Show application jobs in notifications")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        id: applicationJobsEnabledCheck
                        checked: kcm.jobSettings.inNotifications
                        onClicked: kcm.jobSettings.inNotifications = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.jobSettings
                            settingName: "InNotifications"
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Row 2: Notification badges in task manager
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QtControls.Label {
                            text: i18n("Show notification badges in task manager")
                            font.weight: Font.DemiBold
                        }
                    }

                    QtControls.Switch {
                        checked: kcm.badgeSettings.inTaskManager
                        onClicked: kcm.badgeSettings.inTaskManager = checked

                        KCM.SettingStateBinding {
                            configObject: kcm.badgeSettings
                            settingName: "InTaskManager"
                        }
                    }
                }
            }
        }
    }
}
