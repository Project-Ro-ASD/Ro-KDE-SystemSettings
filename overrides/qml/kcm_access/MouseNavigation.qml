/*
    SPDX-FileCopyrightText: 2026 Project Ro KDE
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCMUtils
import org.kde.kirigami as Kirigami
import org.kde.plasma.access.kcm

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Fare Dolaşımı (Numpad Tuşları)")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: mouseCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: mouseCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Sayısal tuş takımı ile imleci taşı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Sayısal Tuş Takımı ile Fareyi Taşı")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Numpad 5 tuşu tıklama, diğer yön tuşları fare hareketini sağlar")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.mouseSettings.mouseKeys
                    onToggled: kcm.mouseSettings.mouseKeys = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.mouseSettings
                        settingName: "MouseKeys"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.mouseSettings.mouseKeys
            }

            // Row 2: İvmelenme gecikmesi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.mouseSettings.mouseKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "İvmelenme Gecikmesi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Tuşa basıldıktan sonra hızlanmanın başlaması için geçen süre (ms)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    id: accelerationDelay
                    from: 1
                    to: 490
                    value: kcm.mouseSettings.accelerationDelay
                    onValueChanged: kcm.mouseSettings.accelerationDelay = value
                    textFromValue: val => val + " ms"

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.mouseSettings
                        settingName: "AccelerationDelay"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.mouseSettings.mouseKeys
            }

            // Row 3: Yineleme aralığı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.mouseSettings.mouseKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Yineleme Aralığı")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("İmleç adımları arasındaki süre aralığı (ms)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    id: repeatInterval
                    from: 1
                    to: 130
                    value: kcm.mouseSettings.repetitionInterval
                    onValueChanged: kcm.mouseSettings.repetitionInterval = value
                    textFromValue: val => val + " ms"

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.mouseSettings
                        settingName: "RepetitionInterval"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.mouseSettings.mouseKeys
            }

            // Row 4: Maksimum Hız
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.mouseSettings.mouseKeys

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Maksimum Hız")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.SpinBox {
                    from: 1
                    to: 100
                    value: kcm.mouseSettings.maxSpeed
                    onValueChanged: kcm.mouseSettings.maxSpeed = value

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.mouseSettings
                        settingName: "MaxSpeed"
                    }
                }
            }
        }
    }
}
