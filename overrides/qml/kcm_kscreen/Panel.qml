/*
    SPDX-FileCopyrightText: 2019 Roman Gilg <subdiff@gmail.com>
    SPDX-FileCopyrightText: 2026 Ro-ASD Team <ro-asd@project>
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels

import org.kde.kcmutils as KCM

ColumnLayout {
    id: root

    property KSortFilterProxyModel enabledOutputs
    property int selectedOutput

    signal reorder()

    Layout.fillWidth: true
    spacing: Kirigami.Units.largeSpacing * 1.5

    // ==========================================
    // KART 1: Ekran Ayarları
    // ==========================================
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing

        Kirigami.Heading {
            level: 4
            font.weight: Font.DemiBold
            text: i18n("Ekran Ayarları")
            leftPadding: 4
        }

        Rectangle {
            Layout.fillWidth: true
            radius: 12
            color: "#ffffff"
            border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
            border.width: 1
            implicitHeight: panelView.implicitHeight + Kirigami.Units.largeSpacing * 2

            StackLayout {
                id: panelView
                currentIndex: root.selectedOutput
                anchors {
                    left: parent.left
                    right: parent.right
                    top: parent.top
                    margins: Kirigami.Units.largeSpacing
                }

                Repeater {
                    model: kcm.outputModel
                    OutputPanel {
                        enabledOutputs: root.enabledOutputs
                        onReorder: root.reorder()
                    }

                    onItemAdded: panelView.currentIndex = Qt.binding(() => root.selectedOutput)
                    onItemRemoved: panelView.currentIndex = Qt.binding(() => root.selectedOutput)
                }
            }
        }
    }

    // ==========================================
    // KART 2: Gelişmiş ve Uyumluluk Ayarları
    // ==========================================
    ColumnLayout {
        Layout.fillWidth: true
        spacing: Kirigami.Units.smallSpacing
        visible: kcm.xwaylandClientsScaleSupported || kcm.tearingSupported || !kcm.perOutputScaling

        Kirigami.Heading {
            level: 4
            font.weight: Font.DemiBold
            text: i18n("Gelişmiş ve Uyumluluk Ayarları")
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

                // Row 1: Global scale
                Item {
                    visible: !kcm.perOutputScaling
                    Layout.fillWidth: true
                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowGlobalScale.implicitHeight + 12)

                    RowLayout {
                        id: rowGlobalScale
                        anchors {
                            fill: parent
                            leftMargin: Kirigami.Units.smallSpacing
                            rightMargin: Kirigami.Units.smallSpacing
                        }
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.Label {
                            text: i18n("Genel Arayüz Ölçeği")
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 200
                            color: Kirigami.Theme.textColor
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 8

                            QQC2.Slider {
                                id: globalScaleSlider
                                Accessible.description: i18nc("@info accessible description of slider value", "in percent of regular scale")
                                Kirigami.StyleHints.tickMarkStepSize: stepSize
                                implicitWidth: 160
                                from: 100
                                to: 300
                                stepSize: 25
                                live: true
                                value: kcm.globalScale * 100
                                onMoved: kcm.globalScale = value / 100
                            }

                            QQC2.Label {
                                text: Math.round(globalScaleSlider.value) + "%"
                                font.weight: Font.DemiBold
                                Layout.preferredWidth: 45
                                horizontalAlignment: Text.AlignRight
                                color: Kirigami.Theme.textColor
                            }
                        }
                    }
                }
                Rectangle {
                    visible: !kcm.perOutputScaling
                    Layout.fillWidth: true
                    height: 1
                    color: Kirigami.Theme.textColor
                    opacity: 0.06
                }

                // Row 2: Legacy apps (X11) scaling
                Item {
                    visible: kcm.xwaylandClientsScaleSupported
                    Layout.fillWidth: true
                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowX11Scale.implicitHeight + 12)

                    RowLayout {
                        id: rowX11Scale
                        anchors {
                            fill: parent
                            leftMargin: Kirigami.Units.smallSpacing
                            rightMargin: Kirigami.Units.smallSpacing
                        }
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.Label {
                            text: i18n("Eski Uygulamalar (X11) Ölçekleme")
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 200
                            color: Kirigami.Theme.textColor
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 8

                            QQC2.ComboBox {
                                implicitWidth: 220
                                model: [
                                    { text: i18nc("The apps themselves should scale", "Uygulama Kendisi Ölçeklesin"), val: true },
                                    { text: i18nc("The system will perform scaling", "Sistem Tarafından Ölçeklensin"), val: false }
                                ]
                                textRole: "text"
                                currentIndex: kcm.xwaylandClientsScale ? 0 : 1
                                onActivated: kcm.xwaylandClientsScale = model[currentIndex].val
                            }

                            Kirigami.ContextualHelpButton {
                                toolTipText: i18n("Eski X11 uygulamalarının yüksek çözünürlüklü ekranlarda nasıl ölçekleneceğini belirler.")
                            }
                        }
                    }
                }
                Rectangle {
                    visible: kcm.xwaylandClientsScaleSupported && kcm.tearingSupported
                    Layout.fillWidth: true
                    height: 1
                    color: Kirigami.Theme.textColor
                    opacity: 0.06
                }

                // Row 3: Screen tearing
                Item {
                    visible: kcm.tearingSupported
                    Layout.fillWidth: true
                    implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowTearing.implicitHeight + 12)

                    RowLayout {
                        id: rowTearing
                        anchors {
                            fill: parent
                            leftMargin: Kirigami.Units.smallSpacing
                            rightMargin: Kirigami.Units.smallSpacing
                        }
                        spacing: Kirigami.Units.largeSpacing

                        QQC2.Label {
                            text: i18n("Tam Ekran Yırtılmasına İzin Ver")
                            font.weight: Font.DemiBold
                            Layout.preferredWidth: 200
                            color: Kirigami.Theme.textColor
                        }

                        Item { Layout.fillWidth: true }

                        RowLayout {
                            spacing: 6

                            QQC2.Switch {
                                checked: kcm.tearingAllowed
                                onToggled: kcm.tearingAllowed = checked
                            }

                            Kirigami.ContextualHelpButton {
                                toolTipText: i18nc("@info:tooltip", "Tam ekran oyunlarda ve uygulamalarda gecikmeyi azaltmak için ekran yırtılmasına izin verir.")
                            }
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
