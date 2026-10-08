/*
    SPDX-FileCopyrightText: 2026 Project Ro ASD
    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts

import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCMUtils

import org.kde.kinfocenter.about_distro.private as Private

KCMUtils.SimpleKCM {
    id: root

    KCMUtils.ConfigModule.buttons: KCMUtils.ConfigModule.NoAdditionalButton

    implicitWidth: Kirigami.Units.gridUnit * 24
    implicitHeight: Kirigami.Units.gridUnit * 30

    topPadding: Kirigami.Units.gridUnit
    leftPadding: Kirigami.Units.gridUnit
    rightPadding: Kirigami.Units.gridUnit

    Private.ServiceRunner {
        id: kicRunner
        desktopFileName: "org.kde.kinfocenter"
    }

    QQC2.ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(Math.max(scrollView.availableWidth - Kirigami.Units.gridUnit * 2, 300), 720)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Kirigami.Units.largeSpacing * 1.5

            // ==========================================
            // ÜST GEZİNME HAPLARI (Deepin 23 Pill Buttons)
            // ==========================================
            RowLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing

                Rectangle {
                    implicitWidth: 140
                    implicitHeight: 34
                    radius: 17
                    color: Kirigami.Theme.highlightColor

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Kirigami.Icon {
                            source: "computer"
                            implicitWidth: 16
                            implicitHeight: 16
                            color: Kirigami.Theme.highlightedTextColor
                        }
                        QQC2.Label {
                            text: i18nc("@title:tab", "Bu Bilgisayar")
                            color: Kirigami.Theme.highlightedTextColor
                            font.weight: Font.DemiBold
                        }
                    }
                }

                Rectangle {
                    implicitWidth: 150
                    implicitHeight: 34
                    radius: 17
                    color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.06)
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    RowLayout {
                        anchors.centerIn: parent
                        spacing: 6
                        Kirigami.Icon {
                            source: "hwinfo"
                            implicitWidth: 16
                            implicitHeight: 16
                        }
                        QQC2.Label {
                            text: i18nc("@title:tab", "Donanım Raporu")
                            font.weight: Font.Normal
                        }
                    }

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: {
                            if (kicRunner.canRun) kicRunner.run();
                        }
                    }
                }
            }

            // ==========================================
            // CİHAZ GÖRSELİ VE BİLGİ BAŞLIĞI (Hero Device)
            // ==========================================
            ColumnLayout {
                Layout.alignment: Qt.AlignHCenter
                spacing: Kirigami.Units.smallSpacing

                // Modern Monitör İllüstrasyonu
                Item {
                    Layout.alignment: Qt.AlignHCenter
                    implicitWidth: 160
                    implicitHeight: 110

                    // Monitör Ekranı
                    Rectangle {
                        anchors {
                            top: parent.top
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: 150
                        height: 92
                        radius: 10
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                        border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.15)
                        border.width: 2

                        Rectangle {
                            anchors.fill: parent
                            anchors.margins: 4
                            radius: 7
                            gradient: Gradient {
                                GradientStop { position: 0.0; color: Qt.rgba(Kirigami.Theme.highlightColor.r, Kirigami.Theme.highlightColor.g, Kirigami.Theme.highlightColor.b, 0.25) }
                                GradientStop { position: 1.0; color: Qt.rgba(Kirigami.Theme.backgroundColor.r, Kirigami.Theme.backgroundColor.g, Kirigami.Theme.backgroundColor.b, 0.85) }
                            }

                            Kirigami.Icon {
                                source: kcm.distroLogo
                                anchors.centerIn: parent
                                implicitWidth: 48
                                implicitHeight: 48
                            }
                        }
                    }

                    // Monitör Ayağı
                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: 50
                        height: 6
                        radius: 3
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.25)
                    }
                    Rectangle {
                        anchors {
                            bottom: parent.bottom
                            bottomMargin: 5
                            horizontalCenter: parent.horizontalCenter
                        }
                        width: 14
                        height: 14
                        color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.2)
                    }
                }

                // Cihaz ve Sürüm Başlığı
                RowLayout {
                    Layout.alignment: Qt.AlignHCenter
                    spacing: 6
                    Kirigami.Heading {
                        text: kcm.distroNameVersion
                        level: 2
                        font.weight: Font.Bold
                    }
                }

                QQC2.Label {
                    Layout.alignment: Qt.AlignHCenter
                    text: kcm.distroVariant
                    visible: text.length > 0
                    color: Kirigami.Theme.disabledTextColor
                    font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.95
                }
            }

            // ==========================================
            // KART 1: Yazılım Bilgileri (Software Spec Card)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    font.weight: Font.DemiBold
                    text: i18nc("@title:group", "Yazılım Bilgileri")
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: softwareCol.implicitHeight + Kirigami.Units.largeSpacing
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        id: softwareCol
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        Repeater {
                            model: kcm.softwareEntries

                            ColumnLayout {
                                required property var entry
                                Layout.fillWidth: true
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowContent.implicitHeight + 12)

                                    RowLayout {
                                        id: rowContent
                                        anchors {
                                            fill: parent
                                            leftMargin: Kirigami.Units.smallSpacing
                                            rightMargin: Kirigami.Units.smallSpacing
                                        }
                                        spacing: Kirigami.Units.largeSpacing

                                        QQC2.Label {
                                            text: entry ? entry.localizedLabel() : ""
                                            font.weight: Font.DemiBold
                                            Layout.preferredWidth: 200
                                            color: Kirigami.Theme.textColor
                                        }

                                        Kirigami.SelectableLabel {
                                            text: entry ? entry.localizedValue() : ""
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                            color: Kirigami.Theme.disabledTextColor
                                        }

                                        Kirigami.Badge {
                                            visible: text.length > 0
                                            padding: 1
                                            customColor: {
                                                if (!entry) return Kirigami.Theme.activeBackgroundColor;
                                                switch (entry.localizedHint().color) {
                                                    case Private.hint.Color.One: return Kirigami.Theme.activeBackgroundColor
                                                    case Private.hint.Color.Two: return Kirigami.Theme.positiveBackgroundColor
                                                    case Private.hint.Color.Three: return Kirigami.Theme.alternateBackgroundColor
                                                }
                                                return Kirigami.Theme.activeBackgroundColor;
                                            }
                                            text: entry ? entry.localizedHint().text : ""
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

            // ==========================================
            // KART 2: Donanım Bilgileri (Hardware Spec Card)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing

                Kirigami.Heading {
                    level: 4
                    font.weight: Font.DemiBold
                    text: i18nc("@title:group", "Donanım Özellikleri")
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: hardwareCol.implicitHeight + Kirigami.Units.largeSpacing
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        id: hardwareCol
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        Repeater {
                            model: kcm.hardwareEntries

                            ColumnLayout {
                                required property var entry
                                Layout.fillWidth: true
                                spacing: 0

                                Item {
                                    Layout.fillWidth: true
                                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, hRowContent.implicitHeight + 12)

                                    RowLayout {
                                        id: hRowContent
                                        anchors {
                                            fill: parent
                                            leftMargin: Kirigami.Units.smallSpacing
                                            rightMargin: Kirigami.Units.smallSpacing
                                        }
                                        spacing: Kirigami.Units.largeSpacing

                                        QQC2.Label {
                                            text: entry ? entry.localizedLabel() : ""
                                            font.weight: Font.DemiBold
                                            Layout.preferredWidth: 200
                                            color: Kirigami.Theme.textColor
                                        }

                                        Kirigami.SelectableLabel {
                                            text: entry ? entry.localizedValue() : ""
                                            Layout.fillWidth: true
                                            horizontalAlignment: Text.AlignRight
                                            color: Kirigami.Theme.disabledTextColor
                                        }

                                        Kirigami.Badge {
                                            visible: text.length > 0
                                            padding: 1
                                            customColor: {
                                                if (!entry) return Kirigami.Theme.activeBackgroundColor;
                                                switch (entry.localizedHint().color) {
                                                    case Private.hint.Color.One: return Kirigami.Theme.activeBackgroundColor
                                                    case Private.hint.Color.Two: return Kirigami.Theme.positiveBackgroundColor
                                                    case Private.hint.Color.Three: return Kirigami.Theme.alternateBackgroundColor
                                                }
                                                return Kirigami.Theme.activeBackgroundColor;
                                            }
                                            text: entry ? entry.localizedHint().text : ""
                                        }

                                        Kirigami.ContextualHelpButton {
                                            visible: toolTipText.length > 0
                                            toolTipText: entry ? entry.localizedHelp() : ""
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

    actions: [
        Kirigami.Action {
            visible: !kcm.isThisKInfoCenter && kicRunner.canRun
            icon.name: kicRunner.iconName
            text: i18nc("@action:button", "Launch %1…", kicRunner.genericName)
            tooltip: i18nc("@info:tooltip launches kinfocenter from systemsettings", "See more detailed system information")
            onTriggered: source => kicRunner.run()
        },
        Kirigami.Action {
            visible: kcm.isEnglish
            icon.name: "edit-copy-symbolic"
            text: i18nc("@action:button", "Copy Details")
            onTriggered: source => kcm.copyToClipboard()
        },
        Kirigami.Action {
            visible: !kcm.isEnglish
            icon.name: "edit-copy-symbolic"
            text: i18nc("@action:button", "Copy Details")

            Kirigami.Action {
                text: i18nc("@action:button Copy Details...", "In current language")
                onTriggered: source => kcm.copyToClipboard()
                shortcut: StandardKey.Copy
            }

            Kirigami.Action {
                text: i18nc("@action:button Copy Details...", "In English")
                onTriggered: source => kcm.copyToClipboardInEnglish()
            }
        }
    ]
}
