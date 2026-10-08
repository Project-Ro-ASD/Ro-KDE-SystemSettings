/*
    SPDX-FileCopyrightText: 2026 Project Ro KDE
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs as Dialogs
import org.kde.kcmutils as KCMUtils
import org.kde.kquickcontrols as KQuickAddons
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    Dialogs.FileDialog {
        id: fileDialog
        title: i18nc("@title:window dialog", "Lütfen bir ses dosyası seçin")
        nameFilters: ["Ses dosyaları (*.ogg *.oga *.wav)"]
        onAccepted: {
            kcm.bellSettings.customBellFile = fileDialog.selectedFile
        }
    }

    QQC2.ButtonGroup {
        id: visualBellGroup
    }

    // ==========================================
    // 1. Sesli Sistem Zili
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Sesli Sistem Zili")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: audibleCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: audibleCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Sesli Zil Aç/Kapat
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Sesli Zil")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Uyarı ve bildirimlerde sistem sesini çal")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.bellSettings.systemBell
                    onToggled: kcm.bellSettings.systemBell = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "SystemBell"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.bellSettings.systemBell
            }

            // Row 2: Özel Ses Dosyası
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.bellSettings.systemBell

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Özel Zil Sesi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Varsayılan bip yerine özel bir ses dosyası kullan")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.CheckBox {
                    id: customBellCheck
                    checked: kcm.bellSettings.customBell
                    onToggled: kcm.bellSettings.customBell = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "CustomBell"
                        extraEnabledConditions: kcm.bellSettings.systemBell
                    }
                }

                QQC2.TextField {
                    id: bellFileText
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                    enabled: customBellCheck.checked
                    text: kcm.bellSettings.customBellFile
                    onEditingFinished: kcm.bellSettings.customBellFile = text

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "CustomBellFile"
                        extraEnabledConditions: kcm.bellSettings.customBell
                    }
                }

                QQC2.Button {
                    icon.name: "folder"
                    enabled: customBellCheck.checked
                    onClicked: fileDialog.open()
                }
            }
        }
    }

    // ==========================================
    // 2. Görsel Sistem Zili
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Görsel Sistem Zili")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: visualCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: visualCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Görsel Zil Aç/Kapat
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Görsel Zil")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Sistem sesi çaldığında ekranı görsel efektle uyar")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.bellSettings.visibleBell
                    onToggled: kcm.bellSettings.visibleBell = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "VisibleBell"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.bellSettings.visibleBell
            }

            // Row 2: Ekranı Tersine Çevir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.bellSettings.visibleBell

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:radio", "Ekran Renklerini Tersine Çevir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Zil çaldığında tüm ekranın renklerini anlık olarak tersine çevirir")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.RadioButton {
                    QQC2.ButtonGroup.group: visualBellGroup
                    checked: kcm.bellSettings.invertScreen
                    onToggled: kcm.bellSettings.invertScreen = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "InvertScreen"
                        extraEnabledConditions: kcm.bellSettings.visibleBell
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.bellSettings.visibleBell
            }

            // Row 3: Ekranı Yanıp Söndür
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.bellSettings.visibleBell

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:radio", "Ekranı Yanıp Söndür")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Zil çaldığında ekranı seçilen renkle parlatır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                KQuickAddons.ColorButton {
                    color: kcm.bellSettings.visibleBellColor
                    onAccepted: col => kcm.bellSettings.visibleBellColor = col

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "VisibleBellColor"
                    }
                }

                QQC2.RadioButton {
                    QQC2.ButtonGroup.group: visualBellGroup
                    checked: !kcm.bellSettings.invertScreen
                    onToggled: kcm.bellSettings.invertScreen = !checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "InvertScreen"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.bellSettings.visibleBell
            }

            // Row 4: Efekt Süresi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.bellSettings.visibleBell

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Görsel Uyarı Süresi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Efektin ekranda kalma süresini belirler (ms)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    from: 100
                    to: 2000
                    stepSize: 50
                    value: kcm.bellSettings.visibleBellPause
                    textFromValue: val => val + " ms"
                    onValueModified: kcm.bellSettings.visibleBellPause = value

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.bellSettings
                        settingName: "VisibleBellPause"
                        extraEnabledConditions: kcm.bellSettings.visibleBell
                    }
                }
            }
        }
    }
}
