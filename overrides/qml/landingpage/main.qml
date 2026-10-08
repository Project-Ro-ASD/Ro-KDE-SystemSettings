/*
    SPDX-FileCopyrightText: 2026 Ro-ASD Team <ro-asd@project>
    SPDX-License-Identifier: GPL-3.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import org.kde.plasma.landingpage.kcm

import org.kde.plasma.core as PlasmaCore

KCMUtils.SimpleKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 46
    implicitHeight: Kirigami.Units.gridUnit * 40

    ColumnLayout {
        id: mainLayout
        width: root.width
        spacing: Kirigami.Units.largeSpacing * 1.5

        // ==========================================
        // 0. Hero / Bu Bilgisayar Hakkında Kartı (Deepin Style)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 14
            color: "#ffffff"
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1
            implicitHeight: heroContent.implicitHeight + Kirigami.Units.largeSpacing * 2

            RowLayout {
                id: heroContent
                anchors {
                    left: parent.left
                    right: parent.right
                    verticalCenter: parent.verticalCenter
                    margins: Kirigami.Units.largeSpacing * 1.5
                }
                spacing: Kirigami.Units.largeSpacing * 1.5

                Rectangle {
                    width: Kirigami.Units.gridUnit * 4
                    height: width
                    radius: 12
                    color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.highlightColor, Kirigami.Theme.backgroundColor, 0.8)

                    Kirigami.Icon {
                        anchors.centerIn: parent
                        width: Kirigami.Units.iconSizes.huge
                        height: width
                        source: "computer"
                    }
                }

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing / 2

                    RowLayout {
                        spacing: Kirigami.Units.mediumSpacing

                        Kirigami.Heading {
                            level: 2
                            text: i18n("Bu Bilgisayar")
                            font.weight: Font.DemiBold
                        }

                        Rectangle {
                            radius: 8
                            color: Kirigami.Theme.highlightColor
                            implicitWidth: badgeLabel.implicitWidth + Kirigami.Units.largeSpacing
                            implicitHeight: badgeLabel.implicitHeight + Kirigami.Units.smallSpacing

                            QQC2.Label {
                                id: badgeLabel
                                anchors.centerIn: parent
                                text: "Fedora Linux 44"
                                color: Kirigami.Theme.highlightedTextColor
                                font.weight: Font.Bold
                                font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                            }
                        }
                    }

                    QQC2.Label {
                        text: i18n("KDE Plasma 6 Masaüstü Ortamı • Ro-ASD Tasarım Sistemi")
                        opacity: 0.65
                        font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                    }
                }
            }
        }

        // ==========================================
        // 1. Tema ve Renkler Kartı (Görünüş Seçimi)
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 14
            color: "#ffffff"
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1
            implicitHeight: themeCardCol.implicitHeight + Kirigami.Units.largeSpacing * 2.5

            ColumnLayout {
                id: themeCardCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing * 1.5
                }
                spacing: Kirigami.Units.largeSpacing

                // Kart Başlığı
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "preferences-desktop-theme"
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium
                    }

                    ColumnLayout {
                        spacing: 0
                        Kirigami.Heading {
                            level: 3
                            text: i18n("Tema ve Görünüm")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Sistem renk şemasını ve genel arayüz temasını seçin")
                            opacity: 0.65
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }

                // Tema Kutucukları (Açık, Koyu, Otomatik)
                RowLayout {
                    Layout.alignment: Qt.AlignCenter
                    spacing: Kirigami.Units.largeSpacing * 1.5

                    QQC2.ButtonGroup { id: themeGroup }

                    LookAndFeelBox {
                        id: lightLookAndFeelBox

                        packageId: kcm.globalsSettings.defaultLightLookAndFeel
                        variant: LookAndFeel.Variant.Light

                        checked: !kcm.globalsSettings.automaticLookAndFeel && kcm.globalsSettings.lookAndFeelPackage === kcm.globalsSettings.defaultLightLookAndFeel
                        group: themeGroup

                        onToggled: {
                            kcm.globalsSettings.automaticLookAndFeel = false;
                            kcm.globalsSettings.lookAndFeelPackage = kcm.globalsSettings.defaultLightLookAndFeel;
                        }

                        onAccepted: (lnfId) => {
                            kcm.globalsSettings.defaultLightLookAndFeel = lnfId;
                        }

                        KCMUtils.SettingHighlighter {
                            highlight: kcm.globalsSettings.automaticLookAndFeel || kcm.globalsSettings.lookAndFeelPackage != kcm.defaultLookAndFeelPackage
                        }
                    }

                    LookAndFeelBox {
                        id: darkLookAndFeelBox

                        packageId: kcm.globalsSettings.defaultDarkLookAndFeel
                        variant: LookAndFeel.Variant.Dark

                        checked: !kcm.globalsSettings.automaticLookAndFeel && kcm.globalsSettings.lookAndFeelPackage === kcm.globalsSettings.defaultDarkLookAndFeel
                        group: themeGroup

                        onToggled: {
                            kcm.globalsSettings.automaticLookAndFeel = false;
                            kcm.globalsSettings.lookAndFeelPackage = kcm.globalsSettings.defaultDarkLookAndFeel;
                        }

                        onAccepted: (lnfId) => {
                            kcm.globalsSettings.defaultDarkLookAndFeel = lnfId;
                        }

                        KCMUtils.SettingHighlighter {
                            highlight: kcm.globalsSettings.automaticLookAndFeel || kcm.globalsSettings.lookAndFeelPackage != kcm.defaultLookAndFeelPackage
                        }
                    }

                    LookAndFeelBox {
                        id: automaticLookAndFeelBox
                        popupEnabled: false

                        group: themeGroup

                        text: i18nc("Switch between dark and light look and feel packages automatically", "Otomatik")

                        checked: kcm.globalsSettings.automaticLookAndFeel
                        onToggled: kcm.globalsSettings.automaticLookAndFeel = true;

                        preview: SplitView {
                            first: lightLookAndFeelBox.previewImage
                            second: darkLookAndFeelBox.previewImage
                            shutter: 0.15

                            Kirigami.Icon {
                                anchors.right: parent.right
                                anchors.top: parent.top
                                anchors.margins: Kirigami.Units.smallSpacing
                                source: "lighttable"
                                isMask: true
                                color: "white"
                                width: Kirigami.Units.iconSizes.smallMedium
                                height: width
                            }
                        }

                        KCMUtils.SettingHighlighter {
                            highlight: kcm.globalsSettings.automaticLookAndFeel || kcm.globalsSettings.lookAndFeelPackage != kcm.defaultLookAndFeelPackage
                        }

                        QQC2.ToolTip.text: i18nc("@info:tooltip 1 is the name of a light global theme, 2 is the name of a dark global theme", "Gündüz “%1”, gece “%2” temasını kullan", lightLookAndFeelBox.text, darkLookAndFeelBox.text)
                        QQC2.ToolTip.visible: automaticLookAndFeelBox.hovered
                        QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay
                    }
                }

                // Ek Görünüş Butonları
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.largeSpacing

                    MostUsedIcon {
                        id: wallpaperKCMButton
                        Layout.fillWidth: true
                        kcmId: "kcm_wallpaper"
                        visible: kcmAction !== null
                    }

                    MostUsedIcon {
                        Layout.fillWidth: true
                        kcmId: "kcm_lookandfeel"
                        visible: kcmAction !== null
                    }
                }
            }
        }

        // ==========================================
        // 2. Masaüstü Davranışı ve Canlandırma Hızı Kartı
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 14
            color: "#ffffff"
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1
            implicitHeight: behaviorCardCol.implicitHeight + Kirigami.Units.largeSpacing * 2.5

            ColumnLayout {
                id: behaviorCardCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing * 1.5
                }
                spacing: Kirigami.Units.largeSpacing

                // Kart Başlığı
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "speedometer"
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium
                    }

                    ColumnLayout {
                        spacing: 0
                        Kirigami.Heading {
                            level: 3
                            text: i18n("Masaüstü ve Canlandırma Hızı")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Pencere animasyonlarının akıcılığını ve dosya tıklama tercihlerini yapılandırın")
                            opacity: 0.65
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }

                // Canlandırma Hızı Slider
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: i18n("Canlandırma Hızı")
                        font.weight: Font.Medium
                    }

                    QQC2.Slider {
                        id: slider
                        Layout.fillWidth: true

                        property var valueMapping: [4, 2, 1.5, 1, 0.75, 0.5, 0]

                        from: 0
                        to: valueMapping.length - 1
                        stepSize: 1
                        Kirigami.StyleHints.tickMarkStepSize: 1
                        snapMode: QQC2.Slider.SnapAlways

                        onMoved: kcm.globalsSettings.animationDurationFactor = valueMapping[value]
                        value: {
                            let factor = kcm.globalsSettings.animationDurationFactor
                            let index = valueMapping.findIndex(item => item <= factor)
                            return index >= 0 ? index : valueMapping.length - 1
                        }

                        Accessible.name: i18nc("@title:slider", "Canlandırma hızı:")

                        KCMUtils.SettingStateBinding {
                            configObject: kcm.globalsSettings
                            settingName: "animationDurationFactor"
                        }
                    }

                    RowLayout {
                        QQC2.Label {
                            text: i18nc("Animation speed", "Yavaş")
                            opacity: 0.7
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                        Item { Layout.fillWidth: true }
                        QQC2.Label {
                            text: i18nc("Animation speed", "Anında")
                            opacity: 0.7
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }

                // Tıklama Davranışı
                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.Label {
                        text: i18n("Dosyalara ve Klasörlere Tıklamak:")
                        font.weight: Font.Medium
                    }

                    RowLayout {
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.ButtonGroup { id: singleClickGroup }

                        QQC2.RadioButton {
                            id: doubleClick
                            text: i18n("Öğeyi seçer (Açmak için çift tıklayın)")
                            checked: !kcm.globalsSettings.singleClick
                            onToggled: kcm.globalsSettings.singleClick = false
                            QQC2.ButtonGroup.group: singleClickGroup

                            KCMUtils.SettingStateBinding {
                                configObject: kcm.globalsSettings
                                settingName: "singleClick"
                                extraEnabledConditions: singleClick.enabled
                            }
                        }

                        QQC2.RadioButton {
                            id: singleClick
                            text: i18n("Öğeyi açar (Tek tıklama ile)")
                            checked: kcm.globalsSettings.singleClick
                            onToggled: kcm.globalsSettings.singleClick = true
                            QQC2.ButtonGroup.group: singleClickGroup

                            KCMUtils.SettingStateBinding {
                                configObject: kcm.globalsSettings
                                settingName: "singleClick"
                            }
                        }
                    }
                }

                // Genel Davranış Butonu
                QQC2.Button {
                    Layout.fillWidth: true
                    readonly property PlasmaCore.Action kcmAction: kcm.kcmAction("kcm_workspace")
                    visible: kcmAction !== null
                    icon.name: "preferences-system-windows"
                    text: kcmAction?.text ?? i18n("Ek Davranış Ayarları")
                    onClicked: if (kcmAction) kcmAction.trigger();
                }
            }
        }

        // ==========================================
        // 3. Sık Kullanılan Sayfalar Kartı
        // ==========================================
        Rectangle {
            Layout.fillWidth: true
            radius: 14
            color: "#ffffff"
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1
            visible: recentlyUsedRepeater.count > 0
            implicitHeight: mostUsedCardCol.implicitHeight + Kirigami.Units.largeSpacing * 2.5

            ColumnLayout {
                id: mostUsedCardCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing * 1.5
                }
                spacing: Kirigami.Units.largeSpacing

                // Kart Başlığı
                RowLayout {
                    spacing: Kirigami.Units.smallSpacing

                    Kirigami.Icon {
                        source: "bookmarks"
                        implicitWidth: Kirigami.Units.iconSizes.medium
                        implicitHeight: Kirigami.Units.iconSizes.medium
                    }

                    ColumnLayout {
                        spacing: 0
                        Kirigami.Heading {
                            level: 3
                            text: i18n("En Sık Kullanılan Sayfalar")
                            font.weight: Font.DemiBold
                        }
                        QQC2.Label {
                            text: i18n("Sık başvurduğunuz sistem ayarları modüllerine tek tıkla ulaşın")
                            opacity: 0.65
                            font.pixelSize: Kirigami.Theme.smallFont.pixelSize
                        }
                    }
                }

                GridLayout {
                    id: mostUsedGrid
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: Kirigami.Units.smallSpacing
                    columnSpacing: Kirigami.Units.smallSpacing

                    Repeater {
                        id: recentlyUsedRepeater
                        model: kcm.mostUsedModel

                        delegate: MostUsedIcon {
                            required property var model
                            Layout.fillWidth: true
                            kcmIcon: model.decoration
                            kcmName: model.display
                            onClicked: kcm.openKCM(model.kcmPlugin)
                        }
                    }
                }
            }
        }
    }
}
