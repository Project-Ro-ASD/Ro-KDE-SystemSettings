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

    property var screenReaderInstalled: null

    Component.onCompleted: {
        screenReaderInstalled = kcm.orcaInstalled()
    }

    Kirigami.PlaceholderMessage {
        Layout.fillWidth: true
        icon.name: "preferences-desktop-text-to-speech"
        text: i18nc("@info Placeholder message title", "Orca Ekran Okuyucusu Kurulu Değil")
        explanation: i18nc("@info Placeholder message explanation", "Lütfen paket yöneticinizden 'orca' paketini kurun ve bu pencereyi yeniden açın.")
        visible: !screenReaderInstalled
    }

    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Ekran Okuyucusu (Orca)")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: screenReaderInstalled
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: readerCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: screenReaderInstalled

        ColumnLayout {
            id: readerCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Ekran Okuyucusunu Etkinleştir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Ekran Okuyucusunu Etkinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Ekranda odaklanan metinleri ve öğeleri sesli olarak okur")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.screenReaderSettings.enabled
                    onToggled: kcm.screenReaderSettings.enabled = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.screenReaderSettings
                        settingName: "Enabled"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.screenReaderSettings.enabled
            }

            // Row 2: Orca Yapılandırmasını Başlat
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.screenReaderSettings.enabled

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@action:button", "Orca Ekran Okuyucu Ayarları")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Ses sentezleyici, hız, perde ve tuş atamalarını yapılandırın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Button {
                    text: i18nc("@action:button", "Ayarları Başlat…")
                    icon.name: "preferences-desktop-text-to-speech"
                    enabled: !kcm.screenReaderSettings.isImmutable("Enabled")
                    onClicked: kcm.launchOrcaConfiguration()
                }
            }
        }
    }
}
