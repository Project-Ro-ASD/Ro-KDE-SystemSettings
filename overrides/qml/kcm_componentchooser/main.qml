/*
    SPDX-FileCopyrightText: 2020 Tobias Fella <fella@posteo.de>
    SPDX-FileCopyrightText: 2026 Kayseri Design Modern Overrides

    SPDX-License-Identifier: GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kcmutils as KCM

KCM.SimpleKCM {
    id: root

    implicitWidth: Kirigami.Units.gridUnit * 42

    function unsupportedMimeText(kcm_component) {
        return i18n("’%1’ seems to not support the following mimetypes associated with this kind of application: %2", kcm_component.applications[kcm_component.index]["name"], kcm_component.unsupportedMimeTypes.join(", "))
    }

    topPadding: 0
    bottomPadding: Kirigami.Units.gridUnit

    ComponentOverlay {
        id: overlay
        parent: root.QQC2.Overlay.overlay
        width: Math.min(root.width, Kirigami.Units.gridUnit * 25)
    }

    component MimeMessage: Kirigami.InlineMessage {
        property var componentChooser
        Layout.fillWidth: true
        visible: componentChooser.unsupportedMimeTypes.length > 0 || componentChooser.mimeTypesNotAssociated.length > 0
        type: Kirigami.MessageType.Warning
        text: i18nc("@info:status", "This application may not be able to open all file types.")
        actions: Kirigami.Action {
            text: i18nc("@action:button", "View Details")
            onTriggered: {
                overlay.componentChooser = componentChooser
                overlay.open()
            }
        }
    }

    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.largeSpacing

        // ==========================================
        // SECTION 1: Internet
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("Internet related application’s category’s name", "Internet")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: internetCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: internetCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Browser
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Web browser")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: browserCombo
                        component: kcm.browsers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.browsers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.browsers }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 2: Email
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Email client")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: emailCombo
                        component: kcm.emailClients
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.emailClients.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.emailClients }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 3: Calendar
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18nc("Default calendar application", "Calendar")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: calendarCombo
                        component: kcm.calendar
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.calendar.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.calendar }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 4: Phone Numbers
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18nc("Default phone app", "Phone Numbers")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: dialerCombo
                        component: kcm.telUriHandlers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.telUriHandlers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.telUriHandlers }
            }
        }

        // ==========================================
        // SECTION 2: Multimedia
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("Multimedia related application’s category’s name", "Multimedia")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: multiCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: multiCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Image viewer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Image viewer")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: imageViewerCombo
                        component: kcm.imageViewers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.imageViewers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.imageViewers }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 2: Music player
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Music player")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: musicPlayerCombo
                        component: kcm.musicPlayers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.musicPlayers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.musicPlayers }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 3: Video player
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Video player")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: videoPlayerCombo
                        component: kcm.videoPlayers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.videoPlayers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.videoPlayers }
            }
        }

        // ==========================================
        // SECTION 3: Documents
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("Documents related application’s category’s name", "Documents")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: docCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: docCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: Text editor
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Text editor")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: textEditorCombo
                        component: kcm.textEditors
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.textEditors.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.textEditors }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 2: PDF viewer
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("PDF viewer")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: pdfViewerCombo
                        component: kcm.pdfViewers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.pdfViewers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.pdfViewers }
            }
        }

        // ==========================================
        // SECTION 4: Utilities
        // ==========================================
        Kirigami.Heading {
            level: 4
            text: i18nc("Utilities related application’s category’s name", "Utilities")
            font.weight: Font.DemiBold
            Layout.leftMargin: Kirigami.Units.smallSpacing
            Layout.topMargin: Kirigami.Units.smallSpacing
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(0, 0, 0, 0.08)
            border.width: 1
            implicitHeight: utilCol.implicitHeight + Kirigami.Units.largeSpacing * 2

            ColumnLayout {
                id: utilCol
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }
                spacing: Kirigami.Units.mediumSpacing

                // Row 1: File manager
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("File manager")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: fileManagerCombo
                        component: kcm.fileManagers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.fileManagers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.fileManagers }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 2: Terminal emulator
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Terminal emulator")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: terminalCombo
                        component: kcm.terminalEmulators
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.terminalEmulators.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.terminalEmulators }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 3: Archive manager
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18n("Archive manager")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: archiveCombo
                        component: kcm.archiveManagers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.archiveManagers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.archiveManagers }

                Rectangle { Layout.fillWidth: true; height: 1; color: Qt.rgba(0, 0, 0, 0.06) }

                // Row 4: Map
                RowLayout {
                    Layout.fillWidth: true
                    spacing: Kirigami.Units.mediumSpacing

                    QQC2.Label {
                        text: i18nc("Map related application’s category’s name", "Map")
                        font.weight: Font.DemiBold
                        Layout.fillWidth: true
                    }

                    ComponentComboBox {
                        id: mapCombo
                        component: kcm.geoUriHandlers
                        implicitWidth: Kirigami.Units.gridUnit * 15
                        KCM.SettingHighlighter { highlight: !kcm.geoUriHandlers.isDefaults }
                    }
                }
                MimeMessage { componentChooser: kcm.geoUriHandlers }
            }
        }
    }
}
