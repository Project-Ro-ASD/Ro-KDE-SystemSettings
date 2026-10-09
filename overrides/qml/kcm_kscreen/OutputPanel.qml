/*
    SPDX-FileCopyrightText: 2019 Roman Gilg <subdiff@gmail.com>
    SPDX-FileCopyrightText: 2026 Ro-ASD Team <ro-asd@project>
    SPDX-License-Identifier: GPL-2.0-or-later
*/
import QtCore
import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import QtQuick.Dialogs
import org.kde.kirigami as Kirigami
import org.kde.kitemmodels

import org.kde.private.kcm.kscreen as KScreen

ColumnLayout {
    id: root

    property KSortFilterProxyModel enabledOutputs
    property var element: model
    property var twinFormLayouts: null

    readonly property int comboboxWidth: 220
    readonly property int sliderWidth: 160
    readonly property int maxSpinboxWidth: Kirigami.Units.gridUnit * 7
    readonly property bool hdrAvailable: (element.capabilities & KScreen.Output.Capability.HighDynamicRange) && (element.capabilities & KScreen.Output.Capability.WideColorGamut)
    readonly property bool hdrActive: hdrAvailable && element.hdr
    readonly property var colorProfileSource: hdrActive ? element.hdrColorProfileSource : element.colorProfileSource

    signal reorder()

    spacing: 0

    // 1. Ekranı Etkinleştir / Cihaz Durumu
    Item {
        visible: kcm.multipleScreensAvailable
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowEnabled.implicitHeight + 12)

        RowLayout {
            id: rowEnabled
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Ekranı Etkinleştir")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            QQC2.Switch {
                checked: element.enabled
                onToggled: element.enabled = checked
            }
        }
    }
    Rectangle {
        visible: kcm.multipleScreensAvailable
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 2. Birincil Ekran Seçimi
    Item {
        visible: kcm.primaryOutputSupported && root.enabledOutputs.count >= 2
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowPrimary.implicitHeight + 12)

        RowLayout {
            id: rowPrimary
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Birincil Ekran")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: Kirigami.Units.smallSpacing

                QQC2.Button {
                    visible: root.enabledOutputs.count >= 3
                    text: i18n("Öncelikleri Değiştir…")
                    icon.name: "document-edit"
                    onClicked: root.reorder();
                }

                QQC2.RadioButton {
                    id: primaryRadio
                    visible: root.enabledOutputs.count === 2
                    text: i18n("Birincil Olarak Kullan")
                    checked: element.priority === 1
                    onToggled: element.priority = 1

                    indicator: Rectangle {
                        implicitWidth: 20
                        implicitHeight: 20
                        radius: 10
                        color: primaryRadio.checked ? "#007aff" : "#ffffff"
                        border.color: primaryRadio.checked ? "#007aff" : (primaryRadio.hovered ? "#007aff" : "#cbd5e1")
                        border.width: primaryRadio.checked ? 0 : 1.5

                        Behavior on color { ColorAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }

                        Rectangle {
                            anchors.centerIn: parent
                            width: 8
                            height: 8
                            radius: 4
                            color: "#ffffff"
                            opacity: primaryRadio.checked ? 1.0 : 0.0
                            scale: primaryRadio.checked ? 1.0 : 0.3

                            Behavior on opacity { NumberAnimation { duration: 150 } }
                            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
                        }
                    }
                }
            }
        }
    }
    Rectangle {
        visible: kcm.primaryOutputSupported && root.enabledOutputs.count >= 2
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 3. Ekran Çözünürlüğü
    Item {
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowRes.implicitHeight + 12)

        RowLayout {
            id: rowRes
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Ekran Çözünürlüğü")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                QQC2.ComboBox {
                    id: resolutionCombobox
                    implicitWidth: root.comboboxWidth
                    visible: count > 1
                    model: element.resolutions
                    onActivated: element.resolutionIndex = currentIndex;
                    Component.onCompleted: currentIndex = Qt.binding(() => element.resolutionIndex);
                }

                QQC2.Label {
                    id: singleResolutionLabel
                    visible: resolutionCombobox.count <= 1
                    text: element.resolutions[0] || ""
                    font.weight: Font.DemiBold
                    color: Kirigami.Theme.textColor
                }

                Kirigami.ContextualHelpButton {
                    visible: resolutionCombobox.count <= 1
                    toolTipText: i18nc("@info", "“%1” is the only resolution supported by this display.", singleResolutionLabel.text)
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

    // 4. Arayüz Ölçeği
    Item {
        visible: kcm.perOutputScaling && element.replicationSourceIndex == 0
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowScale.implicitHeight + 12)

        RowLayout {
            id: rowScale
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Arayüz Ölçeği")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 8

                QQC2.Slider {
                    id: scaleSlider
                    Accessible.description: i18nc("@info accessible description of slider value", "in percent of regular scale")
                    implicitWidth: root.sliderWidth
                    from: 50
                    to: 300
                    stepSize: 25
                    live: true
                    value: element.scale * 100
                    onMoved: element.scale = value / 100

                    background: Rectangle {
                        x: scaleSlider.leftPadding
                        y: Math.round(scaleSlider.topPadding + (scaleSlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: scaleSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, scaleSlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: scaleSlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(scaleSlider.leftPadding + scaleSlider.visualPosition * (scaleSlider.availableWidth - width))
                        y: Math.round(scaleSlider.topPadding + (scaleSlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: scaleSlider.pressed ? "#007aff" : (scaleSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: scaleSlider.pressed || scaleSlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: scaleSlider.pressed ? 0.25 : (scaleSlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: scaleSlider.pressed ? 1.08 : (scaleSlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }

                QQC2.SpinBox {
                    id: spinbox
                    readonly property real factor: 120.0
                    readonly property real realValue: value / factor
                    implicitWidth: root.maxSpinboxWidth
                    from: 0.5 * factor
                    to: 3.0 * factor
                    stepSize: factor * 0.05
                    value: element.scale * factor
                    validator: DoubleValidator {
                        bottom: Math.min(spinbox.from, spinbox.to) * spinbox.factor
                        top:  Math.max(spinbox.from, spinbox.to) * spinbox.factor
                    }
                    textFromValue: (value, locale) =>
                        i18nc("Global scale factor expressed in percentage form", "%%1",
                            parseFloat(value * 1.0 / factor * 100.0))
                    valueFromText: (text, locale) =>
                        Number.fromLocaleString(locale, text.replace("%", "")) * factor / 100.0
                    onValueModified: element.scale = realValue
                }
            }
        }
    }
    Rectangle {
        visible: kcm.perOutputScaling && element.replicationSourceIndex == 0
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 5. Ekran Yönelimi
    Item {
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowOrient.implicitHeight + 12)

        RowLayout {
            id: rowOrient
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Ekran Yönelimi")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            Orientation {}
        }
    }
    Rectangle {
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 6. Yenileme Hızı
    Item {
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowRefresh.implicitHeight + 12)

        RowLayout {
            id: rowRefresh
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Yenileme Hızı")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                QQC2.ComboBox {
                    id: refreshRateCombobox
                    implicitWidth: root.comboboxWidth
                    visible: count > 1
                    model: element.refreshRates
                    onActivated: element.refreshRateIndex = currentIndex;
                    Component.onCompleted: currentIndex = Qt.binding(() => element.refreshRateIndex);
                }

                QQC2.Label {
                    id: singleRefreshRateLabel
                    visible: refreshRateCombobox.count <= 1
                    text: element.refreshRates[0] || ""
                    font.weight: Font.DemiBold
                    color: Kirigami.Theme.textColor
                }

                Kirigami.ContextualHelpButton {
                    visible: refreshRateCombobox.count <= 1
                    toolTipText: resolutionCombobox.count <= 1 ? i18nc("@info", "“%1” is the only refresh rate supported by this display.", singleRefreshRateLabel.text)
                                                               : i18nc("@info", "“%1” is the only refresh rate supported by this display at the current resolution.", singleRefreshRateLabel.text)
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

    // 7. Uyarlanabilir Eşitleme (VRR)
    Item {
        visible: element.capabilities & KScreen.Output.Capability.Vrr
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowVrr.implicitHeight + 12)

        RowLayout {
            id: rowVrr
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Uyarlanabilir Eşitleme (VRR)")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            QQC2.ComboBox {
                implicitWidth: root.comboboxWidth
                model: [
                    { label: i18n("Never"), value: KScreen.Output.VrrPolicy.Never },
                    { label: i18n("Automatic"), value: KScreen.Output.VrrPolicy.Automatic },
                    { label: i18n("Always"), value: KScreen.Output.VrrPolicy.Always },
                ]
                textRole: "label"
                valueRole: "value"
                onActivated: element.vrrPolicy = currentValue;
                Component.onCompleted: currentIndex = indexOfValue(element.vrrPolicy);
            }
        }
    }
    Rectangle {
        visible: element.capabilities & KScreen.Output.Capability.Vrr
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 8. RGB Renk Aralığı
    Item {
        visible: element.capabilities & KScreen.Output.Capability.RgbRange
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowRgb.implicitHeight + 12)

        RowLayout {
            id: rowRgb
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("RGB Renk Aralığı")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                QQC2.ComboBox {
                    id: rgbRangeCombobox
                    implicitWidth: root.comboboxWidth
                    model: [
                        { label: i18n("Automatic"), value: KScreen.Output.RgbRange.Automatic },
                        { label: i18n("Full"), value: KScreen.Output.RgbRange.Full },
                        { label: i18n("Limited"), value: KScreen.Output.RgbRange.Limited }
                    ]
                    textRole: "label"
                    valueRole: "value"
                    onActivated: element.rgbRange = currentValue;
                    Component.onCompleted: currentIndex = indexOfValue(element.rgbRange);
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: xi18nc("@info", "Determines whether the range of possible color values needs to be limited for the display. This should only be changed if the colors on the screen look washed out.")
                }
            }
        }
    }
    Rectangle {
        visible: element.capabilities & KScreen.Output.Capability.RgbRange
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 9. Renk Profili
    Item {
        readonly property bool supportsIcc: (element.capabilities & KScreen.Output.Capability.IccProfile)
        readonly property bool supportsBuiltIn: (element.capabilities & KScreen.Output.Capability.BuiltInColorProfile)
        visible: (supportsIcc || supportsBuiltIn) && !root.hdrActive
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowColorProfile.implicitHeight + 12)

        RowLayout {
            id: rowColorProfile
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Renk Profili")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                ColorProfileSelector {
                    colorProfileSource: element.colorProfileSource
                    onSourceChanged: element.colorProfileSource = colorProfileSource
                    supportsNoProfile: true
                    supportsIccProfile: (element.capabilities & KScreen.Output.Capability.IccProfile)
                    supportsBuiltInProfile: (element.capabilities & KScreen.Output.Capability.BuiltInColorProfile)
                    comboboxWidth: root.comboboxWidth
                    visible: (supportsIccProfile || supportsBuiltInProfile) && !root.hdrActive
                }

                IccSelector {
                    iccProfilePath: element.iccProfilePath
                    onPathChanged: element.iccProfilePath = iccProfilePath
                    visible: (element.capabilities & KScreen.Output.Capability.IccProfile)
                          && (element.colorProfileSource == KScreen.Output.ColorProfileSource.ICC)
                          && !root.hdrActive
                }
            }
        }
    }
    Rectangle {
        visible: ((element.capabilities & KScreen.Output.Capability.IccProfile) || (element.capabilities & KScreen.Output.Capability.BuiltInColorProfile)) && !root.hdrActive
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 10. Yüksek Dinamik Aralık (HDR)
    Item {
        visible: root.hdrAvailable
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowHdr.implicitHeight + 12)

        RowLayout {
            id: rowHdr
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Yüksek Dinamik Aralık (HDR)")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                QQC2.Switch {
                    id: hdrCheckbox
                    checked: element.hdr
                    onToggled: element.hdr = checked
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: i18nc("@info:tooltip", "HDR allows compatible applications to show brighter and more vivid colors.")
                }
            }
        }
    }
    Rectangle {
        visible: root.hdrAvailable
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 11. Ekran Parlaklığı
    Item {
        visible: root.hdrActive || (element.capabilities & KScreen.Output.Capability.BrightnessControl)
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowBrightness.implicitHeight + 12)

        RowLayout {
            id: rowBrightness
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Ekran Parlaklığı")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 8

                QQC2.Slider {
                    id: brightnessSlider
                    implicitWidth: root.sliderWidth
                    from: 0
                    to: 100
                    stepSize: 5
                    live: true
                    value: Math.round(element.brightness * 100.0)
                    onMoved: element.brightness = value / 100.0

                    background: Rectangle {
                        x: brightnessSlider.leftPadding
                        y: Math.round(brightnessSlider.topPadding + (brightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 200
                        implicitHeight: 6
                        width: brightnessSlider.availableWidth
                        height: 6
                        radius: 3
                        color: "#e2e8f0"

                        Rectangle {
                            width: Math.max(0, Math.min(parent.width, brightnessSlider.visualPosition * parent.width))
                            height: parent.height
                            radius: 3
                            color: brightnessSlider.enabled ? "#007aff" : "#94a3b8"

                            Behavior on color { ColorAnimation { duration: 150 } }
                        }
                    }

                    handle: Rectangle {
                        x: Math.round(brightnessSlider.leftPadding + brightnessSlider.visualPosition * (brightnessSlider.availableWidth - width))
                        y: Math.round(brightnessSlider.topPadding + (brightnessSlider.availableHeight - height) / 2)
                        implicitWidth: 18
                        implicitHeight: 18
                        radius: 9
                        color: "#ffffff"
                        border.color: brightnessSlider.pressed ? "#007aff" : (brightnessSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                        border.width: brightnessSlider.pressed || brightnessSlider.hovered ? 2 : 1

                        Rectangle {
                            anchors.centerIn: parent
                            width: parent.width + 6
                            height: parent.height + 6
                            radius: width / 2
                            color: "#007aff"
                            opacity: brightnessSlider.pressed ? 0.25 : (brightnessSlider.hovered ? 0.12 : 0)
                            z: -1
                            Behavior on opacity { NumberAnimation { duration: 150 } }
                        }

                        scale: brightnessSlider.pressed ? 1.08 : (brightnessSlider.hovered ? 1.04 : 1.0)
                        Behavior on scale { NumberAnimation { duration: 150 } }
                        Behavior on border.color { ColorAnimation { duration: 150 } }
                    }
                }

                QQC2.Label {
                    text: Math.round(brightnessSlider.value) + "%"
                    font.weight: Font.DemiBold
                    Layout.preferredWidth: 45
                    horizontalAlignment: Text.AlignRight
                    color: Kirigami.Theme.textColor
                }
            }
        }
    }
    Rectangle {
        visible: root.hdrActive || (element.capabilities & KScreen.Output.Capability.BrightnessControl)
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 12. EDR (Genişletilmiş Dinamik Aralık)
    Item {
        visible: !root.hdrAvailable && (element.capabilities & KScreen.Output.Capability.ExtendedDynamicRange)
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowEdr.implicitHeight + 12)

        RowLayout {
            id: rowEdr
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Genişletilmiş Dinamik Aralık (EDR)")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 6

                QQC2.Switch {
                    id: edrCheckbox
                    checked: element.edrPolicy == KScreen.Output.EdrPolicy.Always
                    onToggled: element.edrPolicy = (checked ? KScreen.Output.EdrPolicy.Always : KScreen.Output.EdrPolicy.Never)
                }

                Kirigami.ContextualHelpButton {
                    toolTipText: xi18nc("@info:tooltip", "EDR allows viewing HDR content on SDR displays by dynamically adjusting the backlight.<nl/><nl/>Note that this increases battery usage while viewing HDR content.")
                }
            }
        }
    }
    Rectangle {
        visible: !root.hdrAvailable && (element.capabilities & KScreen.Output.Capability.ExtendedDynamicRange)
        Layout.fillWidth: true
        height: 1
        color: Kirigami.Theme.textColor
        opacity: 0.06
    }

    // 13. Ekran Yansıtma Kaynağı
    Item {
        visible: kcm.outputReplicationSupported && element.replicationSourceModel && element.replicationSourceModel.count > 0
        Layout.fillWidth: true
        implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.5, rowReplica.implicitHeight + 12)

        RowLayout {
            id: rowReplica
            anchors {
                fill: parent
                leftMargin: Kirigami.Units.smallSpacing
                rightMargin: Kirigami.Units.smallSpacing
            }
            spacing: Kirigami.Units.largeSpacing

            QQC2.Label {
                text: i18n("Ekranı Yansıt")
                font.weight: Font.DemiBold
                Layout.preferredWidth: 200
                color: Kirigami.Theme.textColor
            }

            Item { Layout.fillWidth: true }

            QQC2.ComboBox {
                implicitWidth: root.comboboxWidth
                model: element.replicationSourceModel
                Component.onCompleted: currentIndex = element.replicationSourceIndex;
                onActivated: element.replicationSourceIndex = currentIndex;
            }
        }
    }
}
