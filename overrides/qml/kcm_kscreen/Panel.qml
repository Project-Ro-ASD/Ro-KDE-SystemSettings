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
                                implicitWidth: 160
                                from: 100
                                to: 300
                                stepSize: 25
                                live: true
                                value: kcm.globalScale * 100
                                onMoved: kcm.globalScale = value / 100

                                background: Rectangle {
                                    x: globalScaleSlider.leftPadding
                                    y: Math.round(globalScaleSlider.topPadding + (globalScaleSlider.availableHeight - height) / 2)
                                    implicitWidth: 160
                                    implicitHeight: 6
                                    width: globalScaleSlider.availableWidth
                                    height: 6
                                    radius: 3
                                    color: "#e2e8f0"

                                    Rectangle {
                                        width: Math.max(0, Math.min(parent.width, globalScaleSlider.visualPosition * parent.width))
                                        height: parent.height
                                        radius: 3
                                        color: globalScaleSlider.enabled ? "#007aff" : "#94a3b8"

                                        Behavior on color { ColorAnimation { duration: 150 } }
                                    }
                                }

                                handle: Rectangle {
                                    x: Math.round(globalScaleSlider.leftPadding + globalScaleSlider.visualPosition * (globalScaleSlider.availableWidth - width))
                                    y: Math.round(globalScaleSlider.topPadding + (globalScaleSlider.availableHeight - height) / 2)
                                    implicitWidth: 18
                                    implicitHeight: 18
                                    radius: 9
                                    color: "#ffffff"
                                    border.color: globalScaleSlider.pressed ? "#007aff" : (globalScaleSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                                    border.width: globalScaleSlider.pressed || globalScaleSlider.hovered ? 2 : 1

                                    Rectangle {
                                        anchors.centerIn: parent
                                        width: parent.width + 6
                                        height: parent.height + 6
                                        radius: width / 2
                                        color: "#007aff"
                                        opacity: globalScaleSlider.pressed ? 0.25 : (globalScaleSlider.hovered ? 0.12 : 0)
                                        z: -1
                                        Behavior on opacity { NumberAnimation { duration: 150 } }
                                    }

                                    scale: globalScaleSlider.pressed ? 1.08 : (globalScaleSlider.hovered ? 1.04 : 1.0)
                                    Behavior on scale { NumberAnimation { duration: 150 } }
                                    Behavior on border.color { ColorAnimation { duration: 150 } }
                                }
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
