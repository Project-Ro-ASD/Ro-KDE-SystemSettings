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

    ColumnLayout {
        width: parent.width
        spacing: Kirigami.Units.largeSpacing * 1.5

        // ==========================================
        // CARD 1: Genel Canlandırma Hızı
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

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: "speedometer"
                        implicitWidth: 20
                        implicitHeight: 20
                    }
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Genel Canlandırma Hızı")
                        font.weight: Font.DemiBold
                    }
                }

                Kirigami.FormLayout {
                    Layout.fillWidth: true

                    GridLayout {
                        Kirigami.FormData.labelAlignment: Qt.AlignTop
                        Kirigami.FormData.label: i18n("Global animation speed:")
                        Kirigami.FormData.buddyFor: animationSpeedSlider
                        Layout.fillWidth: true
                        Layout.minimumWidth: Kirigami.Units.gridUnit * 16

                        rowSpacing: Kirigami.Units.smallSpacing
                        columnSpacing: Kirigami.Units.smallSpacing
                        columns: 2

                        QQC2.Slider {
                            id: animationSpeedSlider
                            Layout.fillWidth: true

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

                        Kirigami.ContextualHelpButton {
                            Layout.alignment: Qt.AlignTop
                            toolTipText: xi18nc("@info:tooltip", "Some applications do not support this setting: In particular, GTK applications cannot change animation duration, but will still disable animations when <interface>animation speed</interface> is <interface>Instant</interface>.")
                        }

                        RowLayout {
                            spacing: 0

                            QQC2.Label {
                                text: i18nc("Animation speed", "Slow")
                                textFormat: Text.PlainText
                            }

                            Item {
                                Layout.fillWidth: true
                            }

                            QQC2.Label {
                                text: i18nc("Animation speed", "Instant")
                                textFormat: Text.PlainText
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 2: Masaüstü ve Pencere Canlandırmaları
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.035)
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
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
                spacing: Kirigami.Units.largeSpacing

                RowLayout {
                    spacing: Kirigami.Units.smallSpacing
                    Kirigami.Icon {
                        source: "preferences-system-windows-actions"
                        implicitWidth: 20
                        implicitHeight: 20
                    }
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Masaüstü ve Pencere Canlandırmaları")
                        font.weight: Font.DemiBold
                    }
                }

                Kirigami.FormLayout {
                    id: mainLayout
                    Layout.fillWidth: true

                    Repeater {
                        model: [
                            {"animationsModel": kcm.windowOpenCloseAnimations,  "label": i18nc("@label:listbox", "Window open/close:")        },
                            {"animationsModel": kcm.windowMaximizeAnimations,   "label": i18nc("@label:listbox", "Window maximize:")          },
                            {"animationsModel": kcm.windowMinimizeAnimations,   "label": i18nc("@label:listbox", "Window minimize:")          },
                            {"animationsModel": kcm.windowFullscreenAnimations, "label": i18nc("@label:listbox", "Window full screen:")       },
                            {"animationsModel": kcm.peekDesktopAnimations,      "label": i18nc("@label:listbox", "Peek at desktop:")          },
                            {"animationsModel": kcm.virtualDesktopAnimations,   "label": i18nc("@label:listbox", "Virtual desktop switching:")}
                        ]
                        delegate: RowLayout {
                            id: animationLayout
                            Kirigami.FormData.buddyFor: animationComboBox
                            Kirigami.FormData.label: modelData.label
                            Layout.fillWidth: true
                            Layout.minimumWidth: Kirigami.Units.gridUnit * 16
                            spacing: Kirigami.Units.smallSpacing
                            enabled: kcm.globalsSettings.animationDurationFactor != 0

                            AnimationComboBox {
                                id: animationComboBox
                                Layout.fillWidth: true
                                Layout.rightMargin: !animationConfigure.visible ? (animationConfigure.implicitWidth + animationLayout.spacing) : undefined
                                animationsModel: modelData.animationsModel

                                KCM.SettingHighlighter {
                                    highlight: !animationComboBox.isDefault && kcm.globalsSettings.animationDurationFactor != 0
                                }
                            }

                            QQC2.Button {
                                id: animationConfigure
                                icon.name: "configure"
                                text: i18nc("@info:tooltip", "Configure…")
                                display: QQC2.AbstractButton.IconOnly
                                QQC2.ToolTip.text: text
                                QQC2.ToolTip.visible: hovered
                                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                                enabled: animationComboBox.isConfigurable
                                visible: animationComboBox.isAnyConfigurable
                                onClicked: kcm.configure(animationComboBox.configurePluginId, root)
                            }
                        }
                    }

                    Connections {
                        target: kcm.otherEffects
                        function onModelReset() { otherEffectsRepeater.model = kcm.otherEffects.rowCount(); }
                    }

                    Repeater {
                        id: otherEffectsRepeater
                        model: kcm.otherEffects.rowCount()
                        delegate: RowLayout {
                            id: otherAnimationLayout
                            Kirigami.FormData.buddyFor: animationCheckBox
                            Kirigami.FormData.label: i18nc("@option:check %1 is the name of an animation, e.g. 'Login' or 'Logout'",
                                                           "%1:",
                                                           kcm.otherEffects.data(kcm.otherEffects.index(index, 0), EffectsModel.NameRole))
                            Layout.fillWidth: true
                            required property int index
                            spacing: Kirigami.Units.smallSpacing
                            enabled: kcm.globalsSettings.animationDurationFactor != 0

                            AnimationCheckBox {
                                id: animationCheckBox
                                Layout.fillWidth: true
                                Layout.rightMargin: !otherAnimationConfigure.visible ? (otherAnimationConfigure.implicitWidth + otherAnimationLayout.spacing) : undefined
                                implicitWidth: 0
                                animationsModel: kcm.otherEffects
                                index: otherAnimationLayout.index
                                text: kcm.otherEffects.data(kcm.otherEffects.index(index, 0), EffectsModel.DescriptionRole)

                                Binding {
                                    target: animationCheckBox.indicator.anchors
                                    property: "verticalCenter"
                                    value: animationCheckBox.verticalCenter
                                    when: animationCheckBox.contentItem.lineCount > 1
                                }

                                KCM.SettingHighlighter {
                                    highlight: !animationCheckBox.isDefault && kcm.globalsSettings.animationDurationFactor != 0
                                }
                            }

                            QQC2.Button {
                                id: otherAnimationConfigure
                                icon.name: "configure"
                                text: i18nc("@info:tooltip", "Configure…")
                                display: QQC2.AbstractButton.IconOnly
                                QQC2.ToolTip.text: text
                                QQC2.ToolTip.visible: hovered
                                QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                                enabled: animationCheckBox.checked
                                visible: animationCheckBox.isConfigurable
                                onClicked: kcm.configure(animationCheckBox.configurePluginId, root)
                            }
                        }
                    }
                }
            }
        }

        // ==========================================
        // CARD 3: Ek Efektler ve Ayarlar (varsa)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.035)
            border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
            border.width: 1
            implicitHeight: cardCol3.implicitHeight + Kirigami.Units.largeSpacing * 2
            visible: effectsKCMButton.visible

            ColumnLayout {
                id: cardCol3
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
                        source: "preferences-desktop-theme"
                        implicitWidth: 20
                        implicitHeight: 20
                    }
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Daha Fazla Masaüstü Efekti")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.Button {
                    id: effectsKCMButton
                    Layout.preferredWidth: Kirigami.Units.gridUnit * 14
                    readonly property var kcmData: kcm.effectsKCMData()
                    visible: "icon" in kcmData && "name" in kcmData
                    implicitHeight: Kirigami.Units.gridUnit * 2.5
                    leftPadding: Kirigami.Units.largeSpacing
                    rightPadding: Kirigami.Units.largeSpacing

                    contentItem: RowLayout {
                        spacing: Kirigami.Units.smallSpacing
                        Kirigami.Icon {
                            Layout.alignment: Qt.AlignCenter
                            implicitWidth: Kirigami.Units.iconSizes.small
                            implicitHeight: Kirigami.Units.iconSizes.small
                            source: "icon" in effectsKCMButton.kcmData ? effectsKCMButton.kcmData.icon : ""
                        }
                        QQC2.Label {
                            Layout.fillWidth: true
                            elide: Text.ElideRight
                            textFormat: Text.PlainText
                            text: "name" in effectsKCMButton.kcmData ? effectsKCMButton.kcmData.name : ""
                        }
                    }
                    onClicked: kcm.launchEffectsKCM()
                }
            }
        }
    }
}