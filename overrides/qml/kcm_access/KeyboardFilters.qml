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
    // 1. Yavaş Tuşlar
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Yavaş Tuşlar")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: slowCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: slowCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Yavaş tuşlar aç/kapa
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Yavaş Tuşları Etkinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Tuşların algılanması için belirli bir süre basılı tutulması gerekir")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.slowKeys
                    onToggled: kcm.keyboardFiltersSettings.slowKeys = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "SlowKeys"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.slowKeys
            }

            // Row 2: Gecikme süresi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.slowKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Kabul Gecikmesi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Tuşun basılmış sayılması için gereken süre (ms)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    from: 100
                    to: 10000
                    stepSize: 50
                    value: kcm.keyboardFiltersSettings.slowKeysDelay
                    onValueModified: kcm.keyboardFiltersSettings.slowKeysDelay = value
                    textFromValue: val => val + " ms"

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "SlowKeysDelay"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.slowKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.slowKeys
            }

            // Row 3: Tuşa basıldığında ses
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.slowKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Tuşa Basıldığında Ses Çal")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.slowKeysPressBeep
                    onToggled: kcm.keyboardFiltersSettings.slowKeysPressBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "SlowKeysPressBeep"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.slowKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.slowKeys
            }

            // Row 4: Tuş kabul edildiğinde ses
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.slowKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Tuş Kabul Edildiğinde Ses Çal")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.slowKeysAcceptBeep
                    onToggled: kcm.keyboardFiltersSettings.slowKeysAcceptBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "SlowKeysAcceptBeep"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.slowKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.slowKeys
            }

            // Row 5: Tuş reddedildiğinde ses
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.slowKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Tuş Reddedildiğinde Ses Çal")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.slowKeysRejectBeep
                    onToggled: kcm.keyboardFiltersSettings.slowKeysRejectBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "SlowKeysRejectBeep"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.slowKeys
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. Sıçrama Tuşları
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Sıçrama Tuşları")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: bounceCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: bounceCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Sıçrama tuşları aç/kapa
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Sıçrama Tuşlarını Etkinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Hızlı ve istemsiz peş peşe aynı tuşa basılmaları engeller")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.bounceKeys
                    onToggled: kcm.keyboardFiltersSettings.bounceKeys = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "BounceKeys"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.bounceKeys
            }

            // Row 2: Gecikme süresi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.bounceKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Yoksayma Süresi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Aynı tuşa tekrar basılabilmesi için beklenmesi gereken süre (ms)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    from: 5
                    to: 10000
                    stepSize: 20
                    value: kcm.keyboardFiltersSettings.bounceKeysDelay
                    onValueModified: kcm.keyboardFiltersSettings.bounceKeysDelay = value
                    textFromValue: val => val + " ms"

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "BounceKeysDelay"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.bounceKeys
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.keyboardFiltersSettings.bounceKeys
            }

            // Row 3: Reddedildiğinde ses
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.keyboardFiltersSettings.bounceKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Reddedildiğinde Ses Çal")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.keyboardFiltersSettings.bounceKeysRejectBeep
                    onToggled: kcm.keyboardFiltersSettings.bounceKeysRejectBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.keyboardFiltersSettings
                        settingName: "BounceKeysRejectBeep"
                        extraEnabledConditions: kcm.keyboardFiltersSettings.bounceKeys
                    }
                }
            }
        }
    }
}
