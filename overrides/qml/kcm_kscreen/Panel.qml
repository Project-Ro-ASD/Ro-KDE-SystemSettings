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
    spacing: Kirigami.Units.largeSpacing * 1.5

    // ==========================================
    // CARD 1: Ekran Yapılandırması
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
                    source: "video-display"
                    implicitWidth: 20
                    implicitHeight: 20
                }
                Kirigami.Heading {
                    level: 4
                    text: i18n("Ekran Ayarları")
                    font.weight: Font.DemiBold
                }
            }

            StackLayout {
                id: panelView
                currentIndex: root.selectedOutput
                Layout.fillWidth: true
                implicitHeight: (children.length > 0 && children[currentIndex]) ? children[currentIndex].implicitHeight : 550

                Repeater {
                    model: kcm.outputModel
                    OutputPanel {
                        twinFormLayouts: globalSettingsLayout
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
    // CARD 2: Gelişmiş ve Uyumluluk Ayarları
    // ==========================================
    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.035)
        border.color: Kirigami.ColorUtils.linearInterpolation(Kirigami.Theme.backgroundColor, Kirigami.Theme.textColor, 0.12)
        border.width: 1
        implicitHeight: cardCol2.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: kcm.xwaylandClientsScaleSupported || kcm.tearingSupported || !kcm.perOutputScaling

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
                    source: "preferences-system-windows"
                    implicitWidth: 20
                    implicitHeight: 20
                }
                Kirigami.Heading {
                    level: 4
                    text: i18n("Gelişmiş ve Uyumluluk Ayarları")
                    font.weight: Font.DemiBold
                }
            }

            Kirigami.FormLayout {
                id: globalSettingsLayout
                Layout.fillWidth: true

                RowLayout {
                    Layout.fillWidth: true
                    Kirigami.FormData.label: i18n("Global scale:")
                    visible: !kcm.perOutputScaling

                    QQC2.Slider {
                        id: globalScaleSlider
                        Accessible.description: i18nc("@info accessible description of slider value", "in percent of regular scale")
                        Kirigami.StyleHints.tickMarkStepSize: stepSize
                        Layout.fillWidth: true
                        from: 100
                        to: 300
                        stepSize: 25
                        live: true
                        value: kcm.globalScale * 100
                        onMoved: kcm.globalScale = value / 100;
                    }
                    QQC2.SpinBox {
                        id: spinbox
                        Layout.maximumWidth: Kirigami.Units.gridUnit * 7
                        readonly property real factor: 16.0
                        readonly property real realValue: value / factor
                        from: 1.0 * factor
                        to: 3.0 * factor
                        stepSize: 1
                        value: kcm.globalScale * factor
                        validator: DoubleValidator {
                            bottom: Math.min(spinbox.from, spinbox.to) * spinbox.factor
                            top:  Math.max(spinbox.from, spinbox.to) * spinbox.factor
                        }
                        textFromValue: (value, locale) =>
                            i18nc("Global scale factor expressed in percentage form", "%1%",
                                parseFloat(value * 1.0 / factor * 100.0))
                        valueFromText: (text, locale) =>
                            Number.fromLocaleString(locale, text.replace("%", "")) * factor / 100.0

                        onValueModified: {
                            kcm.globalScale = realValue;
                            if (kcm.globalScale % 0.25) {
                                weirdScaleFactorMsg.visible = true;
                            } else {
                                weirdScaleFactorMsg.visible = false;
                            }
                        }
                    }
                }

                QQC2.ButtonGroup {
                    id: x11AppsScaling
                    onClicked: kcm.xwaylandClientsScale = (button === x11ScalingApps)
                }

                RowLayout {
                    visible: kcm.xwaylandClientsScaleSupported
                    Kirigami.FormData.label: i18n("Legacy applications (X11):")
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.RadioButton {
                        id: x11ScalingApps
                        text: i18nc("The apps themselves should scale to fit the displays", "Apply scaling themselves")
                        checked: kcm.xwaylandClientsScale
                        QQC2.ButtonGroup.group: x11AppsScaling
                    }
                    Kirigami.ContextualHelpButton {
                        toolTipText: i18n("Legacy applications that support scaling will use it and look crisp, however those that don’t will not be scaled at all.")
                    }
                }

                RowLayout {
                    visible: kcm.xwaylandClientsScaleSupported
                    spacing: Kirigami.Units.smallSpacing

                    QQC2.RadioButton {
                        Kirigami.FormData.label: i18n("Legacy applications (X11):")
                        text: i18nc("The system will perform the x11 apps scaling", "Scaled by the system")
                        checked: !kcm.xwaylandClientsScale
                        QQC2.ButtonGroup.group: x11AppsScaling
                    }
                    Kirigami.ContextualHelpButton {
                        toolTipText: i18n("All legacy applications will be scaled by the system to the correct size, however they will always look slightly blurry.")
                    }
                }

                RowLayout {
                    Kirigami.FormData.label: i18nc("@label", "Screen tearing:")
                    visible: kcm.tearingSupported
                    QQC2.CheckBox {
                        text: i18nc("@option:check The thing being allowed in fullscreen windows is screen tearing", "Allow in fullscreen windows")
                        checked: kcm.tearingAllowed
                        onToggled: kcm.tearingAllowed = checked
                    }
                    Kirigami.ContextualHelpButton {
                        toolTipText: i18nc("@info:tooltip", "Screen tearing reduces latency with most displays. Note that not all graphics drivers support this setting.")
                    }
                }

                Item {
                    Kirigami.FormData.isSection: false
                    visible: kcm.xwaylandClientsScaleSupported
                }

                Kirigami.InlineMessage {
                    id: weirdScaleFactorMsg
                    Kirigami.FormData.isSection: true
                    Layout.fillWidth: true
                    type: Kirigami.MessageType.Information
                    text: i18n("The global scale factor is limited to multiples of 6.25% to minimize visual glitches in applications using the X11 windowing system.")
                    visible: false
                    showCloseButton: true
                }
            }
        }
    }
}
