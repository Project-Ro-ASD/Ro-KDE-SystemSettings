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
    // 1. Etkinleştirme Kısayolları
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Etkinleştirme Kısayolları")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: actCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: actCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Kısayolları Aç
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Klavye Jestlerini ve Kısayolları Etkinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Shift'e 5 kez basarak Yapışkan Tuşları, 8 saniye basılı tutarak Yavaş Tuşları açın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.activationGesturesSettings.gestures
                    onToggled: kcm.activationGesturesSettings.gestures = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "Gestures"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.activationGesturesSettings.gestures
            }

            // Row 2: Zaman aşımı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.activationGesturesSettings.gestures

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Hareketsizlik Sonrası Otomatik Kapat")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Belirtilen süre boyunca kullanılmadığında özellikleri kapat")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.CheckBox {
                    id: timeoutCheck
                    checked: kcm.activationGesturesSettings.accessXTimeout
                    onToggled: kcm.activationGesturesSettings.accessXTimeout = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "AccessXTimeout"
                    }
                }

                QQC2.SpinBox {
                    enabled: timeoutCheck.checked
                    from: 1
                    to: 30
                    value: kcm.activationGesturesSettings.accessXTimeoutDelay
                    onValueChanged: kcm.activationGesturesSettings.accessXTimeoutDelay = value
                    textFromValue: val => val + " dk"

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "AccessXTimeoutDelay"
                        extraEnabledConditions: kcm.activationGesturesSettings.accessXTimeout
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. Kısayol Kullanıldığında
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Kısayol Tetiklendiğinde")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: kcm.activationGesturesSettings.gestures
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: triggerCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: kcm.activationGesturesSettings.gestures

        ColumnLayout {
            id: triggerCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Onay kutusu
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Onay İletişim Kutusu Göster")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.activationGesturesSettings.gestureConfirmation
                    onToggled: kcm.activationGesturesSettings.gestureConfirmation = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "GestureConfirmation"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 2: Sistem zili
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Sistem Zilini Çal")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.activationGesturesSettings.accessXBeep
                    onToggled: kcm.activationGesturesSettings.accessXBeep = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "AccessXBeep"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 3: Bildirim göster
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Masaüstü Bildirimi Göster")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Switch {
                    checked: kcm.activationGesturesSettings.keyboardNotifyAccess
                    onToggled: kcm.activationGesturesSettings.keyboardNotifyAccess = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.activationGesturesSettings
                        settingName: "KeyboardNotifyAccess"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 4: Bildirimleri yapılandır
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@action:button", "Bildirim Olaylarını Yapılandır")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Button {
                    text: i18nc("@action:button", "Yapılandır…")
                    icon.name: "preferences-desktop-notification"
                    onClicked: kcm.configureKNotify()
                }
            }
        }
    }
}
