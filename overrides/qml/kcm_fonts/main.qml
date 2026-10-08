/*
    SPDX-FileCopyrightText: 2015 Antonis Tsiapaliokas <antonis.tsiapaliokas@kde.org>
    SPDX-FileCopyrightText: 2017 Marco Martin <mart@kde.org>
    SPDX-FileCopyrightText: 2019 Benjamin Port <benjamin.port@enioka.com>
    SPDX-FileCopyrightText: 2026 Ro-KDE Team
    SPDX-License-Identifier: LGPL-2.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QtControls
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM
import org.kde.config // KAuthorized

import org.kde.plasma.kcm.fonts as FontsKCM

KCM.SimpleKCM {
    id: root

    readonly property bool usingHugeFont: generalFontWidget.font.pointSize > 14
        || fixedWidthFontWidget.font.pointSize > 14
        || smallFontWidget.font.pointSize > 14
        || toolbarFontWidget.font.pointSize > 14
        || menuFontWidget.font.pointSize > 14

    readonly property bool usingInadvisablySmallFont: generalFontWidget.font.pointSize < 7
        || fixedWidthFontWidget.font.pointSize < 7
        || toolbarFontWidget.font.pointSize < 7
        || menuFontWidget.font.pointSize < 7

    readonly property bool usingDisplayFont: [
        generalFontWidget.font.family,
        fixedWidthFontWidget.font.family,
        smallFontWidget.font.family,
        toolbarFontWidget.font.family,
        menuFontWidget.font.family
    ].some(a => a && (a.includes("Display") || a.includes(i18nc("Sub-string in a font name; 'Display' as in display font", "Display"))))

    Kirigami.Action {
        id: kscreenAction
        visible: KAuthorized.authorizeControlModule("kcm_kscreen")
        text: i18n("Adjust Global Scale…")
        icon.name: "preferences-desktop-display"
        onTriggered: KCM.KCMLauncher.open("kcm_kscreen")
    }

    headerPaddingEnabled: false
    header: ColumnLayout {
        spacing: 0

        Kirigami.InlineMessage {
            id: antiAliasingMessage
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            showCloseButton: true
            text: i18n("Some changes such as anti-aliasing or DPI will only affect newly started applications.")

            Connections {
                target: kcm
                function onAliasingChangeApplied() {
                    antiAliasingMessage.visible = true
                }
            }
        }

        Kirigami.InlineMessage {
            id: hugeFontsMessage
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: i18n("Very large fonts may produce odd-looking results. Instead of using a very large font size, consider adjusting the global screen scale.")

            Connections {
                target: kcm
                function onFontsHaveChanged() {
                    hugeFontsMessage.visible = root.usingHugeFont;
                }
            }

            actions: [ kscreenAction ]
        }

        Kirigami.InlineMessage {
            id: displayFontsMessage
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: xi18nc("@info", "“Display” fonts are <link url='https://wikipedia.org/wiki/Display_typeface'>not intended for use on computer displays</link>, and may produce odd results. Consider using a different font.")

            onLinkActivated: (url) => Qt.openUrlExternally(url)

            Connections {
                target: kcm
                function onFontsHaveChanged() {
                    displayFontsMessage.visible = root.usingDisplayFont;
                }
            }
        }

        Kirigami.InlineMessage {
            id: dpiTwiddledMessage
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            showCloseButton: true
            text: i18n("The recommended way to scale the user interface is using the global screen scaling feature.")
            actions: [ kscreenAction ]
        }

        Kirigami.InlineMessage {
            id: fontTooSmallMessage
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: i18nc("@info:usagetip", "Plasma is not designed to be usable with fonts smaller than 4pt. Size has been reset to 4pt.")

            Connections {
                target: kcm
                function onFontTooSmall() {
                    fontTooSmallMessage.visible = true
                }
            }
        }

        Kirigami.InlineMessage {
            id: fontInadvisablySmall
            Layout.fillWidth: true
            position: Kirigami.InlineMessage.Position.Header
            type: Kirigami.MessageType.Warning
            showCloseButton: true
            text: i18nc("@info:usagetip", "Very small fonts may produce odd-looking results. Instead of using a very small font size, consider adjusting the global screen scale.")

            actions: [ kscreenAction ]

            Connections {
                target: kcm
                function onFontsHaveChanged() {
                    fontInadvisablySmall.visible = !fontTooSmallMessage.visible && root.usingInadvisablySmallFont;
                }
            }
        }
    }

    FontsKCM.DevicePixelRatioHelper {
        id: dprHelper
        window: root.Window.window
    }

    QtControls.ScrollView {
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            id: mainCardsLayout
            width: Math.min(Math.max(parent ? parent.width - Kirigami.Units.gridUnit * 2 : 720, 300), 720)
            anchors.horizontalCenter: parent ? parent.horizontalCenter : undefined
            spacing: Kirigami.Units.largeSpacing * 1.5

            // ==========================================
            // KART 1: Sistem Yazıtipleri
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                RowLayout {
                    Layout.fillWidth: true
                    Kirigami.Heading {
                        level: 4
                        text: i18n("Sistem Yazıtipleri")
                        font.weight: Font.DemiBold
                        leftPadding: 4
                    }
                    Item { Layout.fillWidth: true }
                    // Pill button
                    Rectangle {
                        implicitWidth: 180
                        implicitHeight: 32
                        radius: 16
                        color: Kirigami.Theme.highlightColor

                        RowLayout {
                            anchors.centerIn: parent
                            spacing: 6
                            Kirigami.Icon {
                                source: "font-select-symbolic"
                                implicitWidth: 14
                                implicitHeight: 14
                                color: Kirigami.Theme.highlightedTextColor
                            }
                            QtControls.Label {
                                text: i18n("Tümünü Ayarla…")
                                color: Kirigami.Theme.highlightedTextColor
                                font.weight: Font.DemiBold
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: kcm.adjustAllFonts()
                        }
                    }
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

                        FontWidget {
                            id: generalFontWidget
                            label: i18n("Genel Yazıtipi")
                            tooltipText: i18n("Select general font")
                            category: "font"
                            font: kcm.fontsSettings.font

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "font"
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        FontWidget {
                            id: fixedWidthFontWidget
                            label: i18n("Sabit Genişlikli Yazıtipi")
                            tooltipText: i18n("Select fixed width font")
                            category: "fixed"
                            font: kcm.fontsSettings.fixed

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "fixed"
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        FontWidget {
                            id: smallFontWidget
                            label: i18n("Küçük Yazıtipi")
                            tooltipText: i18n("Select small font")
                            category: "smallestReadableFont"
                            font: kcm.fontsSettings.smallestReadableFont

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "smallestReadableFont"
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        FontWidget {
                            id: toolbarFontWidget
                            label: i18n("Araç Çubuğu Yazıtipi")
                            tooltipText: i18n("Select toolbar font")
                            category: "toolBarFont"
                            font: kcm.fontsSettings.toolBarFont

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "toolBarFont"
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        FontWidget {
                            id: menuFontWidget
                            label: i18n("Menü Yazıtipi")
                            tooltipText: i18n("Select menu font")
                            category: "menuFont"
                            font: kcm.fontsSettings.menuFont

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "menuFont"
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        FontWidget {
                            label: i18n("Pencere Başlığı Yazıtipi")
                            tooltipText: i18n("Select window title font")
                            category: "activeFont"
                            font: kcm.fontsSettings.activeFont

                            KCM.SettingStateBinding {
                                configObject: kcm.fontsSettings
                                settingName: "activeFont"
                            }
                        }
                    }
                }
            }

            // ==========================================
            // KART 2: İşleme ve Kenar Yumuşatma
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    text: i18n("İşleme ve Kenar Yumuşatma")
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

                        // Anti-Aliasing
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

                                QtControls.Label {
                                    text: i18n("Kenar Yumuşatma (Anti-Aliasing)")
                                    font.weight: Font.DemiBold
                                    color: Kirigami.Theme.textColor
                                    Layout.preferredWidth: 200
                                }

                                Item { Layout.fillWidth: true }

                                QtControls.Switch {
                                    id: antiAliasingCheckBox
                                    checked: kcm.fontsAASettings.antiAliasing
                                    onToggled: kcm.fontsAASettings.antiAliasing = checked

                                    KCM.SettingStateBinding {
                                        configObject: kcm.fontsAASettings
                                        settingName: "antiAliasing"
                                        extraEnabledConditions: !kcm.fontsAASettings.isAaImmutable
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

                        // Sub-pixel rendering
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

                                QtControls.Label {
                                    text: i18n("Alt Piksel Oluşturma")
                                    font.weight: Font.DemiBold
                                    color: Kirigami.Theme.textColor
                                    Layout.preferredWidth: 200
                                }

                                Item { Layout.fillWidth: true }

                                QtControls.ComboBox {
                                    id: subPixelCombo
                                    implicitWidth: 220
                                    currentIndex: kcm.subPixelCurrentIndex
                                    onActivated: (index) => {
                                        kcm.subPixelCurrentIndex = index
                                    }
                                    model: kcm.subPixelOptionsModel
                                    textRole: "display"
                                }
                            }
                        }

                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Hinting
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

                                QtControls.Label {
                                    text: i18n("Yazıtipi İpuçları (Hinting)")
                                    font.weight: Font.DemiBold
                                    color: Kirigami.Theme.textColor
                                    Layout.preferredWidth: 200
                                }

                                Item { Layout.fillWidth: true }

                                QtControls.ComboBox {
                                    id: hintingCombo
                                    implicitWidth: 220
                                    currentIndex: kcm.hintingCurrentIndex
                                    onActivated: (index) => {
                                        kcm.hintingCurrentIndex = index
                                    }
                                    model: kcm.hintingOptionsModel
                                    textRole: "display"
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
