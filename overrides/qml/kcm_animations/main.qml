/*
    SPDX-FileCopyrightText: 2025 Oliver Beard <olib141@outlook.com>
    SPDX-FileCopyrightText: 2026 Ro-KDE Team
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

import org.kde.plasma.kcm.animations

KCM.SimpleKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 40

    QQC2.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(Math.max(parent ? parent.width - Kirigami.Units.gridUnit * 2 : 720, 300), 720)
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            spacing: Kirigami.Units.largeSpacing * 1.5

            // ==========================================
            // KART 1: Genel Canlandırma Hızı
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    text: i18n("Genel Canlandırma Hızı")
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

                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, 48)

                            RowLayout {
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                QQC2.Label {
                                    text: i18n("Canlandırma Hızı")
                                    font.weight: Font.DemiBold
                                    color: Kirigami.Theme.textColor
                                    Layout.preferredWidth: 200
                                }

                                Item { Layout.fillWidth: true }

                                RowLayout {
                                    spacing: 8

                                    QQC2.Label {
                                        text: i18nc("Animation speed", "Yavaş")
                                        font: Kirigami.Theme.smallFont
                                        color: Kirigami.Theme.disabledTextColor
                                    }

                                    QQC2.Slider {
                                        id: animationSpeedSlider
                                        implicitWidth: 160

                                        property var valueMapping: [
                                            4,
                                            2,
                                            1.5,
                                            1,
                                            0.75,
                                            0.5,
                                            0,
                                        ]

                                        from: 0
                                        to: valueMapping.length - 1
                                        stepSize: 1
                                        Kirigami.StyleHints.tickMarkStepSize: stepSize
                                        snapMode: QQC2.Slider.SnapAlways
                                        onMoved: kcm.globalsSettings.animationDurationFactor = valueMapping[value]
                                        value: {
                                            let factor = kcm.globalsSettings.animationDurationFactor
                                            let index = valueMapping.findIndex(item => item <= factor)
                                            return index >= 0 ? index : valueMapping.length - 1
                                        }

                                        KCM.SettingStateBinding {
                                            configObject: kcm.globalsSettings
                                            settingName: "animationDurationFactor"
                                        }
                                    }

                                    QQC2.Label {
                                        text: i18nc("Animation speed", "Anında")
                                        font: Kirigami.Theme.smallFont
                                        color: Kirigami.Theme.disabledTextColor
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // KART 2: Masaüstü ve Pencere Canlandırmaları
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    text: i18n("Masaüstü ve Pencere Canlandırmaları")
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

                        Repeater {
                            model: [
                                {"animationsModel": kcm.windowOpenCloseAnimations,  "label": i18n("Pencere Açma/Kapatma")        },
                                {"animationsModel": kcm.windowMaximizeAnimations,   "label": i18n("Pencere Ekranı Kaplama")     },
                                {"animationsModel": kcm.windowMinimizeAnimations,   "label": i18n("Pencere Simge Durumuna")     },
                                {"animationsModel": kcm.windowFullscreenAnimations, "label": i18n("Tam Ekran Geçişi")           },
                                {"animationsModel": kcm.peekDesktopAnimations,      "label": i18n("Masaüstüne Göz Atma")         },
                                {"animationsModel": kcm.virtualDesktopAnimations,   "label": i18n("Sanal Masaüstü Değiştirme")   }
                            ]
                            delegate: ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, 48)
                                    enabled: kcm.globalsSettings.animationDurationFactor != 0

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: Kirigami.Units.smallSpacing
                                            rightMargin: Kirigami.Units.smallSpacing
                                        }
                                        spacing: Kirigami.Units.largeSpacing

                                        QQC2.Label {
                                            text: modelData.label
                                            font.weight: Font.DemiBold
                                            color: Kirigami.Theme.textColor
                                            Layout.preferredWidth: 200
                                        }

                                        Item { Layout.fillWidth: true }

                                        RowLayout {
                                            spacing: 6

                                            AnimationComboBox {
                                                id: animationComboBox
                                                implicitWidth: 200
                                                animationsModel: modelData.animationsModel
                                            }

                                            QQC2.Button {
                                                id: animationConfigure
                                                icon.name: "configure"
                                                text: i18nc("@info:tooltip", "Configure…")
                                                display: QQC2.AbstractButton.IconOnly
                                                enabled: animationComboBox.isConfigurable
                                                visible: animationComboBox.isAnyConfigurable
                                                onClicked: kcm.configure(animationComboBox.configurePluginId, root)
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
                            }
                        }

                        Repeater {
                            id: otherEffectsRepeater
                            model: kcm.otherEffects.rowCount()
                            delegate: ColumnLayout {
                                Layout.fillWidth: true
                                spacing: 0
                                required property int index

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, 48)
                                    enabled: kcm.globalsSettings.animationDurationFactor != 0

                                    RowLayout {
                                        anchors {
                                            fill: parent
                                            leftMargin: Kirigami.Units.smallSpacing
                                            rightMargin: Kirigami.Units.smallSpacing
                                        }
                                        spacing: Kirigami.Units.largeSpacing

                                        QQC2.Label {
                                            text: kcm.otherEffects.data(kcm.otherEffects.index(index, 0), EffectsModel.NameRole)
                                            font.weight: Font.DemiBold
                                            color: Kirigami.Theme.textColor
                                            Layout.preferredWidth: 200
                                        }

                                        Item { Layout.fillWidth: true }

                                        RowLayout {
                                            spacing: 6

                                            AnimationCheckBox {
                                                id: animationCheckBox
                                                animationsModel: kcm.otherEffects
                                                index: index
                                                text: kcm.otherEffects.data(kcm.otherEffects.index(index, 0), EffectsModel.DescriptionRole)
                                            }

                                            QQC2.Button {
                                                id: otherAnimationConfigure
                                                icon.name: "configure"
                                                text: i18nc("@info:tooltip", "Configure…")
                                                display: QQC2.AbstractButton.IconOnly
                                                enabled: animationCheckBox.checked
                                                visible: animationCheckBox.isConfigurable
                                                onClicked: kcm.configure(animationCheckBox.configurePluginId, root)
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