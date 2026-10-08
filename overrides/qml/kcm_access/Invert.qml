/*
    SPDX-FileCopyrightText: 2026 Project Ro KDE
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Renkleri Tersine Çevir")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: invertCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: invertCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Renkleri Tersine Çevir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Ekran Renklerini Tersine Çevir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Göz yorgunluğunu azaltmak veya okunabilirliği artırmak için ekran renklerini tersine çevirir")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.invertSettings.invert
                    onToggled: kcm.invertSettings.invert = checked

                    KCM.SettingStateBinding {
                        configObject: kcm.invertSettings
                        settingName: "Invert"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.invertSettings.invert
            }

            // Row 2: Kısayol Yapılandır
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.invertSettings.invert

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@action:button", "Tersine Çevirme Kısayolu")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Renkleri anında tersine çevirmek için özel bir kısayol tuşu yapılandırın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Button {
                    text: i18nc("@action:button", "Kısayolları Yapılandır…")
                    icon.name: "preferences-desktop-keyboard-shortcut"
                    onClicked: kcm.configureInvertShortcuts()
                }
            }
        }
    }
}
