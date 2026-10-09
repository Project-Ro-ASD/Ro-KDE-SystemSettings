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
        text: i18nc("@title:group", "Renk Körlüğü Düzeltmesi")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: colorCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: colorCol
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
                        text: i18nc("@option:check", "Renk Körlüğü Filtresini Etkinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Ekranda ayırt etmekte zorlandığınız renk tonlarını uyarlar")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection
                    onToggled: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection = checked

                    KCM.SettingStateBinding {
                        configObject: kcm.colorblindnessCorrectionSettings
                        settingName: "ColorblindnessCorrection"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection
            }

            // Row 2: Sorunlu Renkler
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:listbox", "Sorun Yaşanan Renkler")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Renk algısı bozukluğu türüne uygun filtreyi seçin")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.ComboBox {
                    currentIndex: kcm.colorblindnessCorrectionSettings.mode
                    textRole: "text"
                    valueRole: "value"
                    model: [
                        { value: 0, text: i18nc("@option", "Kırmızı ve mor (Protanopi)") },
                        { value: 1, text: i18nc("@option", "Yeşil ve mor (Döteranopi)") },
                        { value: 2, text: i18nc("@option", "Sarı, yeşil ve mor (Tritanopi)") },
                        { value: 3, text: i18nc("@option", "Tümü (Gri tonlama modu)") },
                    ]
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 13

                    KCM.SettingStateBinding {
                        configObject: kcm.colorblindnessCorrectionSettings
                        settingName: "Mode"
                    }

                    onActivated: kcm.colorblindnessCorrectionSettings.mode = currentValue
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection
            }

            // Row 3: Yoğunluk
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label", "Düzeltme Yoğunluğu")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Renk dönüşümünün belirginlik seviyesi")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Slider {
                    id: intensitySlider
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 12
                    from: 0.05
                    to: 1.0
                    value: kcm.colorblindnessCorrectionSettings.intensity
                    onMoved: kcm.colorblindnessCorrectionSettings.intensity = value

                    background: Rectangle {
                        x: intensitySlider.leftPadding
                        y: Math.round(intensitySlider.topPadding + (intensitySlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: intensitySlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, intensitySlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: intensitySlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(intensitySlider.leftPadding + intensitySlider.visualPosition * (intensitySlider.availableWidth - width))
                        y: Math.round(intensitySlider.topPadding + (intensitySlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: intensitySlider.pressed ? "#007aff" : (intensitySlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: intensitySlider.pressed || intensitySlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: intensitySlider.pressed ? 0.25 : (intensitySlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: intensitySlider.pressed ? 1.08 : (intensitySlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }

                    KCM.SettingStateBinding {
                        configObject: kcm.colorblindnessCorrectionSettings
                        settingName: "Intensity"
                        extraEnabledConditions: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. Renk Önizlemesi
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Renk Önizlemesi")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: previewCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: kcm.colorblindnessCorrectionSettings.colorblindnessCorrection

        ColumnLayout {
            id: previewCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            RowLayout {
                id: previewArea
                Layout.fillWidth: true
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.largeSpacing

                Repeater {
                    model: [
                        { name: i18n("Kırmızılar"), colors: ["#ef4444", "#f97316", "#eab308"] },
                        { name: i18n("Yeşiller"), colors: ["#22c55e", "#10b981", "#14b8a6"] },
                        { name: i18n("Maviler"), colors: ["#3b82f6", "#06b6d4", "#6366f1"] },
                        { name: i18n("Morlar"), colors: ["#8b5cf6", "#a855f7", "#ec4899"] },
                    ]

                    delegate: ColumnLayout {
                        spacing: 6
                        Layout.alignment: Qt.AlignHCenter

                        QQC2.Label {
                            Layout.alignment: Qt.AlignHCenter
                            text: modelData.name
                            font.weight: Font.DemiBold
                        }

                        RowLayout {
                            spacing: 4
                            Repeater {
                                model: modelData.colors
                                delegate: Rectangle {
                                    width: 36
                                    height: 36
                                    radius: 6
                                    color: modelData
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
