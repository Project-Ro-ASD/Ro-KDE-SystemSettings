/*
    SPDX-FileCopyrightText: 2026 Project Ro KDE
    SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only
*/

import QtQuick
import QtQuick.Layouts
import QtQuick.Controls as QQC2
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls
import org.kde.kwindowsystem

ColumnLayout {
    id: root
    spacing: Kirigami.Units.largeSpacing
    Layout.fillWidth: true

    QQC2.ButtonGroup {
        id: effectGroup
    }

    // ==========================================
    // 1. Yakınlaştırma Modu
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Yakınlaştırma Modu")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: modeCol.implicitHeight + Kirigami.Units.largeSpacing * 2

        ColumnLayout {
            id: modeCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Option 1: Tam ekran
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check, enable zoom effect", "Tam Ekran Yakınlaştırma")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Tüm ekran içeriğini fare işaretçisi odaklı olarak büyütür")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.RadioButton {
                    id: zoomRadio
                    QQC2.ButtonGroup.group: effectGroup
                    checked: kcm.zoomMagnifierSettings.zoom
                    onToggled: {
                        kcm.zoomMagnifierSettings.zoom = true;
                        kcm.zoomMagnifierSettings.magnifier = false;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Option 2: Bölgeyi büyüt
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Bölgeyi Büyüt (Büyüteç)")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("İmlecin etrafındaki pencere alanını büyüteç gibi büyütür")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.RadioButton {
                    id: magnifierRadio
                    QQC2.ButtonGroup.group: effectGroup
                    checked: kcm.zoomMagnifierSettings.magnifier
                    onToggled: {
                        kcm.zoomMagnifierSettings.zoom = false;
                        kcm.zoomMagnifierSettings.magnifier = true;
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Option 3: Devre dışı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Devre Dışı")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Yakınlaştırma ve büyüteç efektlerini kapatır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.RadioButton {
                    id: disabledRadio
                    QQC2.ButtonGroup.group: effectGroup
                    checked: !(kcm.zoomMagnifierSettings.zoom || kcm.zoomMagnifierSettings.magnifier)
                    onToggled: {
                        kcm.zoomMagnifierSettings.zoom = false;
                        kcm.zoomMagnifierSettings.magnifier = false;
                    }
                }
            }
        }
    }

    // ==========================================
    // 2. Yakınlaştırma Seçenekleri
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Yakınlaştırma Seçenekleri")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: kcm.zoomMagnifierSettings.zoom || kcm.zoomMagnifierSettings.magnifier
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: optionsCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: kcm.zoomMagnifierSettings.zoom || kcm.zoomMagnifierSettings.magnifier

        ColumnLayout {
            id: optionsCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            // Row 1: Yakınlaştırma çarpanı
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Yakınlaştırma Çarpanı")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Temel büyütme oranını ayarlar (1.05x - 4.00x)")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    id: sharedZoomFactorSpinBox
                    from: 21
                    to: 80
                    stepSize: 1
                    value: Math.round(kcm.zoomMagnifierSettings.sharedZoomFactor * 20)
                    textFromValue: (val, loc) => (val / 20).toLocaleString(loc, 'f', 2) + "x"
                    valueFromText: (txt, loc) => Math.round(Number.fromLocaleString(loc, txt.replace("x", "")) * 20)
                    onValueModified: kcm.zoomMagnifierSettings.sharedZoomFactor = value / 20

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "SharedZoomFactor"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 2: İşaretçi izlemesi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:listbox", "İşaretçi İzlemesi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Fare imlecinin yakınlaştırılmış alan içerisindeki hareketi")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.ComboBox {
                    id: mouseTrackingCombo
                    model: [
                        { title: i18nc("@item:inlistbox", "Oransal"), settingIndex: 0 },
                        { title: i18nc("@item:inlistbox", "Ortalanmış"), settingIndex: 1 },
                        { title: i18nc("@item:inlistbox", "Ortalanmış (Katı)"), settingIndex: 4 },
                        { title: i18nc("@item:inlistbox", "İtme"), settingIndex: 2 },
                        { title: i18nc("@item:inlistbox", "Devre Dışı"), settingIndex: 3 }
                    ]
                    textRole: "title"
                    currentIndex: model.findIndex(m => m.settingIndex === kcm.zoomMagnifierSettings.zoomMouseTracking)
                    onActivated: index => kcm.zoomMagnifierSettings.zoomMouseTracking = model[index].settingIndex

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "ZoomMouseTracking"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 3: Piksel ızgarası düzeyi
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Piksel Izgarası Gösterme Düzeyi")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Bu yakınlaştırma düzeyinden itibaren piksel çizgilerini göster")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.SpinBox {
                    id: zoomPixelGridSpinBox
                    from: 0
                    to: 10000
                    stepSize: 100
                    value: Math.round(kcm.zoomMagnifierSettings.zoomPixelGridZoom * 100)
                    textFromValue: (val, loc) => (val / 100).toLocaleString(loc, 'f', 2)
                    valueFromText: (txt, loc) => Math.round(Number.fromLocaleString(loc, txt) * 100)
                    onValueModified: kcm.zoomMagnifierSettings.zoomPixelGridZoom = value / 100

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "ZoomPixelGridZoom"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 4: Ekran içeriğini keskinleştir
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Ekran İçeriğini Keskinleştir")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Yakınlaştırıldığında piksel netliğini artıran özel filtre uygula")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.zoomMagnifierSettings.zoomUsePatternUpscaler
                    onToggled: kcm.zoomMagnifierSettings.zoomUsePatternUpscaler = checked

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "ZoomUsePatternUpscaler"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            // Row 5: Metin imlecini izle
            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@option:check", "Metin İmlecini İzle")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Yazı yazarken odağı metin imlecine göre otomatik kaydır")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Switch {
                    checked: kcm.zoomMagnifierSettings.zoomEnableTextCaretTracking
                    onToggled: kcm.zoomMagnifierSettings.zoomEnableTextCaretTracking = checked

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "ZoomEnableTextCaretTracking"
                    }
                }
            }

            // Büyüteç boyutları (sadece büyüteç etkinse)
            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.zoomMagnifierSettings.magnifier
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.zoomMagnifierSettings.magnifier

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Büyüteç Genişliği")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.SpinBox {
                    from: 100
                    to: 2000
                    stepSize: 10
                    value: kcm.zoomMagnifierSettings.magnifierWidth
                    textFromValue: val => val + " px"
                    onValueModified: kcm.zoomMagnifierSettings.magnifierWidth = value

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "MagnifierWidth"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
                visible: kcm.zoomMagnifierSettings.magnifier
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing
                visible: kcm.zoomMagnifierSettings.magnifier

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label:spinbox", "Büyüteç Yüksekliği")
                        font.weight: Font.DemiBold
                    }
                }

                QQC2.SpinBox {
                    from: 100
                    to: 2000
                    stepSize: 10
                    value: kcm.zoomMagnifierSettings.magnifierHeight
                    textFromValue: val => val + " px"
                    onValueModified: kcm.zoomMagnifierSettings.magnifierHeight = value

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "MagnifierHeight"
                    }
                }
            }
        }
    }

    // ==========================================
    // 3. Kısayollar ve Sarma Eylemleri
    // ==========================================
    Kirigami.Heading {
        level: 4
        text: i18nc("@title:group", "Kısayollar ve Sarma Eylemleri")
        font.weight: Font.DemiBold
        Layout.leftMargin: Kirigami.Units.smallSpacing
        visible: kcm.zoomMagnifierSettings.zoom || kcm.zoomMagnifierSettings.magnifier
    }

    Rectangle {
        Layout.fillWidth: true
        radius: 12
        color: "#ffffff"
        border.color: Qt.rgba(0, 0, 0, 0.08)
        border.width: 1
        implicitHeight: shortcutCol.implicitHeight + Kirigami.Units.largeSpacing * 2
        visible: kcm.zoomMagnifierSettings.zoom || kcm.zoomMagnifierSettings.magnifier

        ColumnLayout {
            id: shortcutCol
            anchors {
                left: parent.left
                right: parent.right
                top: parent.top
                margins: Kirigami.Units.largeSpacing
            }
            spacing: Kirigami.Units.mediumSpacing

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@label", "Sarma Hareketini Niteleyici Düğmeler")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Niteleyici tuşa basılı tutarken fare tekerleğini kaydırarak yakınlaştırın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                KQuickControls.KeySequenceItem {
                    id: zoomPointerAxisGestureModifiersBox
                    keySequence: kcm.zoomMagnifierSettings.zoomPointerAxisGestureModifiers
                    onKeySequenceModified: kcm.zoomMagnifierSettings.zoomPointerAxisGestureModifiers = keySequence
                    patterns: KQuickControls.ShortcutPattern.Modifier
                    multiKeyShortcutsAllowed: false

                    Connections {
                        target: kcm.zoomMagnifierSettings
                        function onZoomPointerAxisGestureModifiersChanged() {
                            zoomPointerAxisGestureModifiersBox.keySequence = kcm.zoomMagnifierSettings.zoomPointerAxisGestureModifiers;
                        }
                    }

                    KCM.SettingStateBinding {
                        configObject: kcm.zoomMagnifierSettings
                        settingName: "ZoomPointerAxisGestureModifiers"
                    }
                }
            }

            Rectangle {
                Layout.fillWidth: true
                height: 1
                color: Qt.rgba(0, 0, 0, 0.06)
            }

            RowLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.mediumSpacing

                ColumnLayout {
                    Layout.fillWidth: true
                    spacing: 2
                    QQC2.Label {
                        text: i18nc("@action:button", "Klavye Kısayolları")
                        font.weight: Font.DemiBold
                    }
                    QQC2.Label {
                        text: i18n("Yakınlaştırma ve büyütmeyi klavyeden denetlemek için tuş atayın")
                        font: Kirigami.Theme.smallFont
                        opacity: 0.75
                    }
                }

                QQC2.Button {
                    text: i18nc("@action:button", "Kısayolları Yapılandır…")
                    icon.name: "preferences-desktop-keyboard-shortcut"
                    onClicked: kcm.configureZoomMagnifyShortcuts()
                }
            }
        }
    }
}
