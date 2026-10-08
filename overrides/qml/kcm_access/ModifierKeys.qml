/*
    SPDX-FileCopyrightText: 2026 Project Ro KDE
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    // ==========================================
    // 1. Yapışkan Tuşlar
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Yapışkan Tuşlar")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: stickyCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: stickyCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Yapışkan tuşları etkinleştir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Yapışkan Tuşlar")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Ctrl, Alt, Shift tuşlarını basılı tutmak yerine sırayla basarak kullanın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardSettings.stickyKeys
                    onToggled: kcm.keyboardSettings.stickyKeys = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardSettings
                        settingName: "StickyKeys"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardSettings.stickyKeys
            }

            // Row 2: Yapışkan tuşları kilitle
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardSettings.stickyKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Yapışkan Tuşları Kilitle")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Bir niteleyici tuşa iki kez art arda basıldığında kilitli kalır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardSettings.stickyKeysLatch
                    onToggled: kcm.keyboardSettings.stickyKeysLatch = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardSettings
                        settingName: "StickyKeysLatch"
                        extraEnabledConditions: kcm.keyboardSettings.stickyKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardSettings.stickyKeys
            }

            // Row 3: İki tuşa aynı anda basıldığında kapat
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardSettings.stickyKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "İki Tuşa Aynı Anda Basıldığında Kapat")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Aynı anda iki tuşa basıldığında yapışkan tuş modunu otomatik sonlandır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardSettings.stickyKeysAutoOff
                    onToggled: kcm.keyboardSettings.stickyKeysAutoOff = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardSettings
                        settingName: "StickyKeysAutoOff"
                        extraEnabledConditions: kcm.keyboardSettings.stickyKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardSettings.stickyKeys
            }

            // Row 4: Sesli uyarı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardSettings.stickyKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Niteleyici Tuşlarda Ses Çal")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Niteleyici bir tuşa basıldığında, kilitlendiğinde veya bırakıldığında ses çal")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardSettings.stickyKeysBeep
                    onToggled: kcm.keyboardSettings.stickyKeysBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardSettings
                        settingName: "StickyKeysBeep"
                        extraEnabledConditions: kcm.keyboardSettings.stickyKeys
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. Kilitleme Tuşları ve Geri Bildirim
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Kilitleme Tuşları ve Geri Bildirim")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: lockCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: lockCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Kilitleme tuşlarında ses çal
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Kilitleme Tuşlarında Ses Çal")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Caps Lock, Num Lock veya Scroll Lock tuşlarına basıldığında sesle uyar")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardSettings.toggleKeysBeep
                    onToggled: kcm.keyboardSettings.toggleKeysBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardSettings
                        settingName: "ToggleKeysBeep"
                    }
                }
            }
        }
    }
}
