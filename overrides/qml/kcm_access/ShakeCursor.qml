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

    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "İşaretçiyi Salla Efekti")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: shakeCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: shakeCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Etkinleştir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Bulmak İçin İşaretçiyi Salla")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Fareyi hızlıca salladığınızda işaretçiyi anlık olarak büyüterek bulmanızı kolaylaştırır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.shakeCursorSettings.shakeCursor
                    onToggled: kcm.shakeCursorSettings.shakeCursor = checked

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.shakeCursorSettings
                        settingName: "ShakeCursor"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.shakeCursorSettings.shakeCursor
            }

            // Row 2: Büyütme Oranı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.shakeCursorSettings.shakeCursor

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label", "Büyütme Düzeyi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Sallama anında imlecin ulaşacağı maksimum büyüklük")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Slider {
                    id: magnificationSlider
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                    from: 2
                    to: 10
                    stepSize: 1
                    snapMode: QQC2.Slider.SnapAlways
                    value: kcm.shakeCursorSettings.shakeCursorMagnification
                    onMoved: kcm.shakeCursorSettings.shakeCursorMagnification = value

                    background: Rectangle {
                        x: magnificationSlider.leftPadding
                        y: Math.round(magnificationSlider.topPadding + (magnificationSlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: magnificationSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, magnificationSlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: magnificationSlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(magnificationSlider.leftPadding + magnificationSlider.visualPosition * (magnificationSlider.availableWidth - width))
                        y: Math.round(magnificationSlider.topPadding + (magnificationSlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: magnificationSlider.pressed ? "#007aff" : (magnificationSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: magnificationSlider.pressed || magnificationSlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: magnificationSlider.pressed ? 0.25 : (magnificationSlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: magnificationSlider.pressed ? 1.08 : (magnificationSlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    KCMUtils.SettingStateBinding {
                        configObject: kcm.shakeCursorSettings
                        settingName: "ShakeCursorMagnification"
                        extraEnabledConditions: kcm.shakeCursorSettings.shakeCursor
                    }
                }

                QQC2.Label {
                    text: magnificationSlider.value + "x"
                    font.weight: Font.DemiBold
                    Layout.minimumWidth: Kirigami.Units.gridUnit * 2
                }
            }
        }
    }
}
