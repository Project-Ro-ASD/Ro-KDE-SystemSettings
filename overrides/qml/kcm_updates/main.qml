/*
 *   SPDX-FileCopyrightText: 2020 Aleix Pol Gonzalez <aleixpol@kde.org>
 *   SPDX-FileCopyrightText: 2026 Ro-KDE Team
 *   SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils

SimpleKCM {
    id: root

    ConfigModule.buttons: ConfigModule.Default | ConfigModule.Apply

    implicitWidth: Kirigami.Units.gridUnit * 40
    implicitHeight: Kirigami.Units.gridUnit * 30

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.largeSpacing * 1.5

        // ==========================================
        // CARD 1: Yazılım Güncelleme Tercihleri
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.035)
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
            border.width: 1
            implicitHeight: cardCol1.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: cardCol1
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.largeSpacing

                // Header
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: "system-software-update"
                        implicitWidth: 22
                        implicitHeight: 22
                    }
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Yazılım Güncelleme Tercihleri")
                        font.weight: Font.DemiBold
                    }
                }

                // Row 1: Otomatik Güncelleme
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        QQC2.Label {
                            text: i18n("Güncellemeleri Otomatik Olarak İndir")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Güncellemeler çıktığında arka planda otomatik hazırlanır")
                            font: Kirigami.Theme.smallFont
                            opacity: 0.7
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    QQC2.Switch {
                        id: autoSwitch
                        checked: kcm.updatesSettings.useUnattendedUpdates
                        onToggled: kcm.updatesSettings.useUnattendedUpdates = checked

                        SettingStateBinding {
                            configObject: kcm.updatesSettings
                            settingName: "useUnattendedUpdates"
                            target: autoSwitch
                        }
                    }
                }

                Kirigami.Separator {
                    Layout.fillWidth: true
                }

                // Row 2: Sıklık Seçimi
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        QQC2.Label {
                            text: autoSwitch.checked ? i18n("Güncelleme Denetleme Sıklığı") : i18n("Bildirim Gönderme Sıklığı")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Sistemin yeni yazılım sürümlerini kontrol etme aralığı")
                            font: Kirigami.Theme.smallFont
                            opacity: 0.7
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    QQC2.ComboBox {
                        id: freqCombo
                        Layout.preferredWidth: Kirigami.Units.gridUnit * 10

                        readonly property var updatesFrequencyModel: [
                            i18nc("@item:inlistbox", "Daily"),
                            i18nc("@item:inlistbox", "Weekly"),
                            i18nc("@item:inlistbox", "Monthly"),
                            i18nc("@item:inlistbox", "Never")
                        ]

                        readonly property var unattendedUpdatesFrequencyModel: [
                            updatesFrequencyModel[0],
                            updatesFrequencyModel[1],
                            updatesFrequencyModel[2],
                        ]

                        model: autoSwitch.checked ? unattendedUpdatesFrequencyModel : updatesFrequencyModel

                        readonly property var options: [
                            60 * 60 * 24,
                            60 * 60 * 24 * 7,
                            60 * 60 * 24 * 30,
                            -1
                        ]

                        currentIndex: {
                            let index = -1
                            for (const i in options) {
                                if (options[i] === kcm.updatesSettings.requiredNotificationInterval) {
                                    index = i
                                }
                            }
                            return index
                        }
                        onActivated: index => {
                            kcm.updatesSettings.requiredNotificationInterval = options[index]
                        }

                        SettingStateProxy {
                            id: settingState
                            configObject: kcm.updatesSettings
                            settingName: "requiredNotificationInterval"
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 2: Sistem Güncellemelerini Uygulama
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.035)
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
            border.width: 1
            implicitHeight: cardCol2.implicitHeight + Kirigami.Units.largeSpacing * 2
            visible: !kcm.mandatoryRebootAfterUpdate

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
                        source: "tools-report-bug"
                        implicitWidth: 22
                        implicitHeight: 22
                    }
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Sistem Güncellemelerini Uygula")
                        font.weight: Font.DemiBold
                    }
                }

                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    ColumnLayout {
                        Layout.fillWidth: true
                        spacing: 2

                        QQC2.Label {
                            text: i18n("Yeniden Başlatırken Uygula (Çevrimdışı)")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Sistem kararlılığını en üst düzeye çıkarmak için önerilir")
                            font: Kirigami.Theme.smallFont
                            opacity: 0.7
                            wrapMode: Text.Wrap
                            Layout.fillWidth: true
                        }
                    }

                    QQC2.Switch {
                        id: offlineSwitch
                        enabled: !kcm.discoverSettings.isUseOfflineUpdatesImmutable
                        checked: kcm.discoverSettings.useOfflineUpdates
                        onToggled: kcm.discoverSettings.useOfflineUpdates = checked

                        SettingStateBinding {
                            configObject: kcm.discoverSettings
                            settingName: "useOfflineUpdates"
                            target: offlineSwitch
                        }
                    }
                }
            }
        }
    }
}
