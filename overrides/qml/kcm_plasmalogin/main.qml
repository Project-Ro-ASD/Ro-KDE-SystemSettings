/*
    SPDX-FileCopyrightText: 2020 David Redondo <kde@david-redondo.de>
    SPDX-FileCopyrightText: 2024 Kristen McWilliam <kmcwilliampublic@gmail.com>
    SPDX-FileCopyrightText: 2024 Jakob Petsovits <jpetso@petsovits.com>
    SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
    SPDX-FileCopyrightText: 2026 Kayseri Design Modern Overrides

    SPDX-License-Identifier: GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels as ItemModels

import org.kde.private.kcms.plasmalogin

KCM.SimpleKCM {
    id: root

    implicitHeight: Kirigami.Units.gridUnit * 45
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

    actions: [
        Kirigami.Action {
            text: i18nc("@action:button", "Apply Plasma Settings…")
            icon.name: "plasma"
            onTriggered: syncSheet.open()
        },
        Kirigami.Action {
            text: i18nc("@action:button", "Configure Appearance…")
            icon.name: "edit-image-symbolic"
            onTriggered: kcm.push("Appearance.qml")
        }
    ]

    header: Kirigami.InlineMessage {
        id: errorMessage
        position: Kirigami.InlineMessage.Position.Header
        type: Kirigami.MessageType.Error
        showCloseButton: true
        Connections {
            target: kcm

            function onErrorOccurred(untranslatedMessage) {
                errorMessage.text = i18n(untranslatedMessage);
                errorMessage.visible = untranslatedMessage.length > 0
            }

            function onSyncAttempted() {
                syncSheet.close()
            }
        }
    }

    Kirigami.PromptDialog {
        id: syncSheet

        padding: Kirigami.Units.largeSpacing
        standardButtons: Kirigami.Dialog.Cancel

        title: i18nc("@title:window", "Apply Plasma Settings")
        subtitle: i18n("This will make the Plasma login screen reflect your customizations to the following Plasma settings:") +
                xi18nc("@info", "<para><list><item>Color scheme</item><item>Cursor theme and size</item><item>Font and font rendering</item><item>NumLock preference</item><item>Plasma theme</item><item>Scaling DPI</item><item>Screen configuration</item><item>Keyboard layouts</item></list></para>") +
                i18n("Please note that theme files must be installed globally to be reflected on the Plasma login screen.")

        customFooterActions: [
            Kirigami.Action {
                text: i18nc("@action:button", "Apply")
                icon.name: "dialog-ok-apply"
                onTriggered: kcm.synchronizeSettings()
            },
            Kirigami.Action {
                text: i18nc("@action:button", "Reset to Default Settings")
                icon.name: "edit-undo"
                onTriggered: kcm.resetSynchronizedSettings()
            }
        ]
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // ==========================================
        // SECTION 1: Otomatik Oturum Aç
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Auto-login")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: autoCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: autoCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Enable switch
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:check", "Automatically log in")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Log in to session automatically without prompting for password")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    QQC2.Switch {
                        id: autologinBox
                        checked: kcm.settings.user != ""
                        KCM.SettingHighlighter {
                            highlight: (kcm.settings.user != "" && kcm.settings.defaultUser == "") ||
                                        (kcm.settings.user == "" && kcm.settings.defaultUser != "")
                        }
                        onToggled: {
                            if (checked) {
                                kcm.settings.user = autologinUser.currentText
                                kcm.settings.session = autologinSession.valueAt(0)
                            } else {
                                kcm.settings.user = ""
                                kcm.settings.session = ""
                            }
                            if (checked && kcm.KDEWalletAvailable()) {
                                autologinMessage.visible = true;
                            }
                        }
                    }
                }

                // Row 2: User selector
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: autologinBox.checked
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: autologinBox.checked

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@label:listbox, the following combobox selects the user to log in automatically", "User")
                            font.weight: Font.DemiBold
                        }
                    }

                    QQC2.ComboBox {
                        id: autologinUser
                        implicitWidth: Kirigami.Units.gridUnit * 14
                        model: kcm.userModel
                        textRole: "display"
                        valueRole: "name"
                        onActivated: kcm.settings.user = currentValue
                        KCM.SettingStateBinding {
                            visible: autologinBox.checked
                            configObject: kcm.settings
                            settingName: "User"
                            extraEnabledConditions: autologinBox.checked
                        }
                        Component.onCompleted: updateSelectedUser()
                        function setUserFromEditText() {
                            kcm.settings.user = editText;
                        }
                        function updateSelectedUser() {
                            currentIndex = indexOfValue(kcm.settings.user);
                        }
                        Connections {
                            target: kcm.settings
                            function onUserChanged() { autologinUser.updateSelectedUser(); }
                        }
                    }
                }

                // Row 3: Session selector
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: autologinBox.checked
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: autologinBox.checked

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@label:listbox, the following combobox selects the session that is started automatically", "Session")
                            font.weight: Font.DemiBold
                        }
                    }

                    QQC2.ComboBox {
                        id: autologinSession
                        implicitWidth: Kirigami.Units.gridUnit * 14
                        model: kcm.sessionModel
                        textRole: "display"
                        valueRole: "fileName"
                        onActivated: kcm.settings.session = currentValue
                        KCM.SettingStateBinding {
                            visible: autologinBox.checked
                            configObject: kcm.settings
                            settingName: "Session"
                            extraEnabledConditions: autologinBox.checked
                        }
                        Component.onCompleted: updateCurrentIndex()
                        function updateCurrentIndex() {
                            currentIndex = indexOfValue(kcm.settings.session);
                        }
                        Connections {
                            target: kcm.settings
                            function onSessionChanged() { autologinSession.updateCurrentIndex(); }
                        }
                    }
                }

                // Row 4: Relogin immediately
                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                    visible: autologinBox.checked
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing
                    visible: autologinBox.checked

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@option:check", "Log in again immediately after logging off")
                            font.weight: Font.DemiBold
                        }
                    }

                    QQC2.Switch {
                        checked: kcm.settings.relogin
                        onToggled: kcm.settings.relogin = checked
                        KCM.SettingStateBinding {
                            configObject: kcm.settings
                            settingName: "Relogin"
                            extraEnabledConditions: autologinBox.checked
                        }
                    }
                }

                Kirigami.InlineMessage {
                    id: autologinMessage
                    Layout.fillWidth: true
                    type: Kirigami.MessageType.Warning
                    text: xi18nc("@info", "Auto-login does not support unlocking your KDE Wallet automatically, so it will ask you to unlock it every time you log in.\n\nTo avoid this, you can change the wallet to have a blank password.")
                    actions: Kirigami.Action {
                        text: i18n("Open KDE Wallet Settings")
                        icon.name: "kwalletmanager"
                        onTriggered: kcm.openKDEWallet();
                    }
                }
            }
        }

        // ==========================================
        // SECTION 2: Varsayılanlar
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("@title:group", "Defaults")
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
            implicitHeight: defCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: defCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Group 1: Default User
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@label", "Default user")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("User selected by default on login screen")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.ButtonGroup {
                            id: preselectedUserGroup
                        }

                        ModernRadio {
                            QQC2.ButtonGroup.group: preselectedUserGroup
                            autoExclusive: false
                            text: i18nc("@option:radio", "Last logged-in user")
                            checked: kcm.settings.preselectedUser == ""
                            onToggled: { if (checked) kcm.settings.preselectedUser = ""; }
                            KCM.SettingHighlighter {
                                highlight: kcm.settings.preselectedUser != kcm.settings.defaultPreselectedUser
                            }
                        }

                        RowLayout {
                            spacing: Kirigami.Units.smallSpacing

                            ModernRadio {
                                id: customPreselectedUserRadioButton
                                QQC2.ButtonGroup.group: preselectedUserGroup
                                autoExclusive: false
                                checked: kcm.settings.preselectedUser != ""
                                onToggled: {
                                    if (checked) {
                                        kcm.settings.preselectedUser = customPreselectedUserComboBox.currentText
                                    }
                                }
                                KCM.SettingHighlighter {
                                    highlight: kcm.settings.preselectedUser != kcm.settings.defaultPreselectedUser
                                }
                            }

                            QQC2.ComboBox {
                                id: customPreselectedUserComboBox
                                implicitWidth: Kirigami.Units.gridUnit * 13
                                model: kcm.userModel
                                textRole: "display"
                                valueRole: "name"
                                editable: true
                                onActivated: kcm.settings.preselectedUser = currentText
                                onEditTextChanged: kcm.settings.preselectedUser = editText;

                                Component.onCompleted: updateSelectedUser()
                                Connections {
                                    target: kcm.settings
                                    function onPreselectedUserChanged() { customPreselectedUserComboBox.updateSelectedUser(); }
                                }

                                function updateSelectedUser() {
                                    const index = find(kcm.settings.preselectedUser);
                                    if (index != -1) {
                                        currentIndex = index;
                                    }
                                    editText = kcm.settings.preselectedUser;
                                }

                                KCM.SettingStateBinding {
                                    visible: customPreselectedUserRadioButton.checked
                                    configObject: kcm.settings
                                    settingName: "PreselectedUser"
                                    extraEnabledConditions: customPreselectedUserRadioButton.checked
                                }
                            }
                        }
                    }
                }

                Rectangle {
                    Layout.fillWidth: true
                    height: 1
                    color: Qt.rgba(0, 0, 0, 0.06)
                }

                // Group 2: Default Session
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2
                        QQC2.Label {
                            text: i18nc("@label", "Default session")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Desktop environment session selected by default")
                            color: Kirigami.Theme.disabledTextColor
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }

                    ColumnLayout {
                        spacing: Kirigami.Units.smallSpacing

                        QQC2.ButtonGroup {
                            id: preselectedSessionGroup
                        }

                        ModernRadio {
                            QQC2.ButtonGroup.group: preselectedSessionGroup
                            autoExclusive: false
                            text: i18nc("@option:radio", "Last logged-in session")
                            checked: kcm.settings.preselectedSession == ""
                            onToggled: { if (checked) kcm.settings.preselectedSession = ""; }
                            KCM.SettingHighlighter {
                                highlight: kcm.settings.preselectedSession != kcm.settings.defaultPreselectedSession
                            }
                        }

                        RowLayout {
                            spacing: Kirigami.Units.smallSpacing

                            ModernRadio {
                                id: customPreselectedSessionRadioButton
                                QQC2.ButtonGroup.group: preselectedSessionGroup
                                autoExclusive: false
                                checked: kcm.settings.preselectedSession != ""
                                onToggled: {
                                    if (checked) {
                                        kcm.settings.preselectedSession = customPreselectedSessionComboBox.valueAt(0);
                                    }
                                }
                                KCM.SettingHighlighter {
                                    highlight: kcm.settings.preselectedSession != kcm.settings.defaultPreselectedSession
                                }
                            }

                            QQC2.ComboBox {
                                id: customPreselectedSessionComboBox
                                implicitWidth: Kirigami.Units.gridUnit * 13
                                model: kcm.sessionModel
                                textRole: "display"
                                valueRole: "fileName"
                                onActivated: kcm.settings.preselectedSession = currentValue

                                Component.onCompleted: updateCurrentIndex()
                                Connections {
                                    target: kcm.settings
                                    function onPreselectedSessionChanged() { customPreselectedSessionComboBox.updateCurrentIndex(); }
                                }

                                function updateCurrentIndex() {
                                    currentIndex = indexOfValue(kcm.settings.preselectedSession);
                                }

                                KCM.SettingStateBinding {
                                    visible: customPreselectedSessionRadioButton.checked
                                    configObject: kcm.settings
                                    settingName: "PreselectedSession"
                                    extraEnabledConditions: customPreselectedSessionRadioButton.checked
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
