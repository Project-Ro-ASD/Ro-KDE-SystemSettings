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

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(Math.max(parent ? parent.width - Kirigami.Units.gridUnit * 2 : 720, 300), 720)
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            spacing: Kirigami.Units.largeSpacing * 1.5

            // ==========================================
            // KART 1: Yazılım Güncelleme Tercihleri
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    text: i18n("Yazılım Güncelleme Tercihleri")
                    font.weight: Font.DemiBold
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
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
                        spacing: 0

                        // Row 1: Otomatik Güncelleme
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowAuto.implicitHeight + 12)

                            RowLayout {
                                id: rowAuto
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    QQC2.Label {
                                        text: i18n("Güncellemeleri Otomatik Olarak İndir")
                                        font.weight: Font.DemiBold
                                        color: Kirigami.Theme.textColor
                                    }
                                    QQC2.Label {
                                        text: i18n("Güncellemeler çıktığında arka planda otomatik hazırlanır")
                                        font: Kirigami.Theme.smallFont
                                        color: Kirigami.Theme.disabledTextColor
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                    }
                                }

                                Item { Layout.fillWidth: true }

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
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Row 2: Sıklık Seçimi
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowFreq.implicitHeight + 12)

                            RowLayout {
                                id: rowFreq
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    QQC2.Label {
                                        text: autoSwitch.checked ? i18n("Güncelleme Denetleme Sıklığı") : i18n("Bildirim Gönderme Sıklığı")
                                        font.weight: Font.DemiBold
                                        color: Kirigami.Theme.textColor
                                    }
                                    QQC2.Label {
                                        text: i18n("Sistemin yeni yazılım sürümlerini kontrol etme aralığı")
                                        font: Kirigami.Theme.smallFont
                                        color: Kirigami.Theme.disabledTextColor
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                    }
                                }

                                Item { Layout.fillWidth: true }

                                QQC2.ComboBox {
                                    id: freqCombo
                                    implicitWidth: 220

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
                }
            }

            // ==========================================
            // KART 2: Sistem Güncellemelerini Uygulama
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: !kcm.mandatoryRebootAfterUpdate

                Kirigami.Heading {
                    level: 4
                    text: i18n("Sistem Güncellemelerini Uygula")
                    font.weight: Font.DemiBold
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1
                    implicitHeight: cardCol2.implicitHeight + Kirigami.Units.largeSpacing * 2

                    ColumnLayout {
                        id: cardCol2
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowOffline.implicitHeight + 12)

                            RowLayout {
                                id: rowOffline
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2

                                    QQC2.Label {
                                        text: i18n("Yeniden Başlatırken Uygula (Çevrimdışı)")
                                        font.weight: Font.DemiBold
                                        color: Kirigami.Theme.textColor
                                    }
                                    QQC2.Label {
                                        text: i18n("Sistem kararlılığını en üst düzeye çıkarmak için önerilir")
                                        font: Kirigami.Theme.smallFont
                                        color: Kirigami.Theme.disabledTextColor
                                        wrapMode: Text.Wrap
                                        Layout.fillWidth: true
                                    }
                                }

                                Item { Layout.fillWidth: true }

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

            Item {
                Layout.fillWidth: true
                implicitHeight: Kirigami.Units.largeSpacing
            }
        }
    }
}
