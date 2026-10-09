/*
    SPDX-FileCopyrightText: 2026 Project Ro ASD
    SPDX-License-Identifier: GPL-2.0-or-later
*/

pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCMUtils

import org.kde.kirigami as Kirigami
import org.kde.kquickcontrols as KQuickControls

import org.kde.plasma.private.kcm_mouse as Mouse

KCMUtils.SimpleKCM {
    id: root

    readonly property Mouse.InputBackend backend: KCMUtils.ConfigModule.inputBackend
    readonly property Mouse.InputDevice device: backend.inputDevices[KCMUtils.ConfigModule.currentDeviceIndex] ?? null

    function supportsExtraButtons(dev: Mouse.InputDevice): bool {
        return (dev?.supportedButtons ?? 0) & ~(Qt.LeftButton | Qt.RightButton | Qt.MiddleButton);
    }

    actions: Kirigami.Action {
        icon.name: "input-mouse-click-left-symbolic"
        text: i18ndc("kcmmouse", "@action:button", "Configure Extra Buttons…")

        visible: {
            if (root.backend.isAnonymousInputDevice) {
                return false;
            }
            return root.backend.buttonMappingCount > 0
                || root.backend.inputDevices.some(root.supportsExtraButtons);
        }

        onTriggered: source => {
            root.KCMUtils.ConfigModule.push("bindings.qml");
        }
    }

    header: Header {
        saveLoadMessage: root.KCMUtils.ConfigModule.saveLoadMessage
        hotplugMessage: root.KCMUtils.ConfigModule.hotplugMessage
    }

    QtObject {
        id: accelSpeed

        readonly property real deviceSpeed: root.device?.pointerAcceleration ?? 0

        onDeviceSpeedChanged: {
            if (root.device) {
                accelSpeedSpinbox.value = Math.round(deviceSpeed * 100)
            }
        }

        function onAccelSpeedChanged(val: int) {
            if (root.device) {
                root.device.pointerAcceleration = val / 100
            }
        }
    }

    QQC2.ScrollView {
        id: scrollView
        anchors.fill: parent
        contentWidth: availableWidth

        ColumnLayout {
            width: Math.min(scrollView.width - Kirigami.Units.gridUnit * 2, 780)
            anchors.horizontalCenter: parent.horizontalCenter
            spacing: Kirigami.Units.largeSpacing * 1.5

            // Placeholder when no devices are found
            Kirigami.PlaceholderMessage {
                Layout.fillWidth: true
                visible: root.backend.inputDevices.length === 0
                icon.name: "input-mouse-symbolic"
                text: i18ndc("kcmmouse", "@info:status", "No pointing devices found")
            }

            // ==========================================
            // KART 1: Aygıt ve Temel Ayarlar (Device & General)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.device !== null && root.backend.inputDevices.length > 0

                Kirigami.Heading {
                    level: 4
                    font.weight: Font.DemiBold
                    text: i18ndc("kcmmouse", "@title:group", "Aygıt ve Genel Ayarlar")
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: card1Layout.implicitHeight + Kirigami.Units.largeSpacing
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        id: card1Layout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        // Satır 1: Cihaz Seçici
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.8, r1.implicitHeight + 16)
                            visible: !root.backend.isAnonymousInputDevice && root.backend.inputDevices.length > 1

                            RowLayout {
                                id: r1
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@title:listbox select device", "Seçili Fare Aygıtı")
                                    }
                                    QQC2.Label {
                                        text: root.device ? root.device.name : ""
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                        elide: Text.ElideRight
                                        Layout.fillWidth: true
                                    }
                                }

                                QQC2.ComboBox {
                                    id: deviceSelector
                                    Layout.preferredWidth: Math.min(parent.width * 0.45, 260)
                                    model: root.backend.inputDevices
                                    textRole: "name"

                                    Component.onCompleted: {
                                        currentIndex = Qt.binding(() => root.KCMUtils.ConfigModule.currentDeviceIndex)
                                    }
                                    onActivated: {
                                        root.KCMUtils.ConfigModule.currentDeviceIndex = currentIndex
                                    }
                                }
                            }
                        }

                        // Ara Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                            visible: !root.backend.isAnonymousInputDevice && root.backend.inputDevices.length > 1
                        }

                        // Satır 2: Aygıtı Etkinleştir
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.6, r2.implicitHeight + 16)

                            RowLayout {
                                id: r2
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@option:check", "Aygıtı Etkinleştir")
                                    }
                                    QQC2.Label {
                                        text: "Bu işaretçi aygıtının giriş sinyallerini açık tutun"
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                QQC2.Switch {
                                    id: deviceEnabled
                                    enabled: root.device?.supportsDisableEvents ?? false
                                    checked: enabled && !(root.device?.enabled ?? true) === false
                                    onToggled: {
                                        if (root.device) {
                                            root.device.enabled = checked
                                        }
                                    }
                                }
                            }
                        }

                        // Ara Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Satır 3: Sol El Kipi
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.6, r3.implicitHeight + 16)

                            RowLayout {
                                id: r3
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@option:check", "Sol El Kipi")
                                    }
                                    QQC2.Label {
                                        text: i18ndc("kcmmouse", "@info", "Sol ve sağ fare düğmelerinin işlevlerini birbiriyle değiştir")
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                QQC2.Switch {
                                    id: leftHanded
                                    enabled: root.device?.supportsLeftHanded ?? false
                                    checked: enabled && (root.device?.leftHanded ?? false)
                                    onToggled: {
                                        if (root.device) {
                                            root.device.leftHanded = checked
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // KART 2: İşaretçi ve Hız (Pointer & Speed)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.device !== null && root.backend.inputDevices.length > 0

                Kirigami.Heading {
                    level: 4
                    font.weight: Font.DemiBold
                    text: i18ndc("kcmmouse", "@title:group", "İşaretçi ve Hız")
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: card2Layout.implicitHeight + Kirigami.Units.largeSpacing
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        id: card2Layout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        // Satır 1: İşaretçi Hızı
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 3.0, rSpeed.implicitHeight + 16)

                            RowLayout {
                                id: rSpeed
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@label:slider", "İşaretçi Hızı")
                                    }
                                    QQC2.Label {
                                        text: "İmlecin fare hareketine verdiği tepki hızını ayarlayın"
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                RowLayout {
                                    Layout.preferredWidth: Math.min(parent.width * 0.48, 280)
                                    spacing: Kirigami.Units.smallSpacing

                                    QQC2.Slider {
                                        id: accelSpeedSlider
                                        Layout.fillWidth: true
                                        from: 1
                                        to: 11
                                        stepSize: 1
                                        enabled: root.device?.supportsPointerAcceleration ?? false
                                        value: enabled && root.device ? Math.round(6 + root.device.pointerAcceleration / 0.2) : 0

                                        onMoved: {
                                            if (root.device) {
                                                const accelSpeedValue = Math.round(((value - 6) * 0.2) * 100)
                                                accelSpeed.onAccelSpeedChanged(accelSpeedValue)
                                            }
                                        }

                                        background: Rectangle {
                                            x: accelSpeedSlider.leftPadding
                                            y: Math.round(accelSpeedSlider.topPadding + (accelSpeedSlider.availableHeight - height) / 2)
                                            implicitWidth: 200
                                            implicitHeight: 6
                                            width: accelSpeedSlider.availableWidth
                                            height: 6
                                            radius: 3
                                            color: "#e2e8f0"

                                            Rectangle {
                                                width: Math.max(0, Math.min(parent.width, accelSpeedSlider.visualPosition * parent.width))
                                                height: parent.height
                                                radius: 3
                                                color: accelSpeedSlider.enabled ? "#007aff" : "#94a3b8"

                                                Behavior on color { ColorAnimation { duration: 150 } }
                                            }
                                        }

                                        handle: Rectangle {
                                            x: Math.round(accelSpeedSlider.leftPadding + accelSpeedSlider.visualPosition * (accelSpeedSlider.availableWidth - width))
                                            y: Math.round(accelSpeedSlider.topPadding + (accelSpeedSlider.availableHeight - height) / 2)
                                            implicitWidth: 18
                                            implicitHeight: 18
                                            radius: 9
                                            color: "#ffffff"
                                            border.color: accelSpeedSlider.pressed ? "#007aff" : (accelSpeedSlider.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                                            border.width: accelSpeedSlider.pressed || accelSpeedSlider.hovered ? 2 : 1

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: parent.width + 6
                                                height: parent.height + 6
                                                radius: width / 2
                                                color: "#007aff"
                                                opacity: accelSpeedSlider.pressed ? 0.25 : (accelSpeedSlider.hovered ? 0.12 : 0)
                                                z: -1
                                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                            }

                                            scale: accelSpeedSlider.pressed ? 1.08 : (accelSpeedSlider.hovered ? 1.04 : 1.0)
                                            Behavior on scale { NumberAnimation { duration: 150 } }
                                            Behavior on border.color { ColorAnimation { duration: 150 } }
                                        }
                                    }

                                    QQC2.SpinBox {
                                        id: accelSpeedSpinbox
                                        Layout.preferredWidth: 68
                                        implicitHeight: 28
                                        from: -100
                                        to: 100
                                        stepSize: 1
                                        editable: true
                                        enabled: root.device?.supportsPointerAcceleration ?? false
                                        value: enabled && root.device ? Math.round(root.device.pointerAcceleration * 100) : 0

                                        background: Rectangle {
                                            implicitWidth: 68
                                            implicitHeight: 28
                                            radius: 6
                                            color: "#f8fafc"
                                            border.color: accelSpeedSpinbox.activeFocus ? "#007aff" : Qt.rgba(0, 0, 0, 0.12)
                                            border.width: 1
                                        }

                                        validator: DoubleValidator {
                                            bottom: accelSpeedSpinbox.from
                                            top: accelSpeedSpinbox.to
                                        }

                                        onValueModified: {
                                            if (root.device) {
                                                accelSpeed.onAccelSpeedChanged(value)
                                                value = Qt.binding(() => accelSpeedSpinbox.enabled && root.device
                                                    ? Math.round(root.device.pointerAcceleration * 100)
                                                    : 0
                                                );
                                            }
                                        }

                                        textFromValue: function(val, locale) {
                                            return Number(val / 100).toLocaleString(locale, "f", 2)
                                        }

                                        valueFromText: function(text, locale) {
                                            return Number.fromLocaleString(locale, text) * 100
                                        }
                                    }
                                }
                            }
                        }

                        // Ara Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Satır 2: İşaretçi İvmelendirmesi
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.6, rAccel.implicitHeight + 16)
                            enabled: root.device?.supportsPointerAccelerationProfileAdaptive ?? false
                            visible: enabled

                            RowLayout {
                                id: rAccel
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@option:check", "İşaretçi İvmelendirmesini Etkinleştir")
                                    }
                                    QQC2.Label {
                                        text: "Hızlı hareketlerde imlecin kat ettiği mesafe artırılır"
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                RowLayout {
                                    spacing: Kirigami.Units.smallSpacing
                                    QQC2.Switch {
                                        id: accelProfileEnabled
                                        checked: rAccel.parent.enabled && !(root.device?.pointerAccelerationProfileFlat ?? false)
                                        onToggled: {
                                            if (root.device) {
                                                root.device.pointerAccelerationProfileFlat = !checked
                                                root.device.pointerAccelerationProfileAdaptive = checked
                                            }
                                        }
                                    }
                                    Kirigami.ContextualHelpButton {
                                        toolTipText: i18ndc("kcmmouse", "@info:whatsthis", "Etkinleştirildiğinde, daha hızlı fare hareketlerinde işaretçi daha uzağa gider.")
                                    }
                                }
                            }
                        }
                    }
                }
            }

            // ==========================================
            // KART 3: Sarma ve Kaydırma (Scrolling)
            // ==========================================
            ColumnLayout {
                Layout.fillWidth: true
                spacing: Kirigami.Units.smallSpacing
                visible: root.device !== null && root.backend.inputDevices.length > 0

                Kirigami.Heading {
                    level: 4
                    font.weight: Font.DemiBold
                    text: i18ndc("kcmmouse", "@title:group", "Sarma ve Kaydırma")
                    leftPadding: 4
                }

                Rectangle {
                    Layout.fillWidth: true
                    implicitHeight: card3Layout.implicitHeight + Kirigami.Units.largeSpacing
                    radius: 12
                    color: "#ffffff"
                    border.color: Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08)
                    border.width: 1

                    ColumnLayout {
                        id: card3Layout
                        anchors {
                            left: parent.left
                            right: parent.right
                            top: parent.top
                            margins: Kirigami.Units.largeSpacing
                        }
                        spacing: 0

                        // Satır 1: Sarma Hızı
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 3.2, rScroll.implicitHeight + 16)
                            visible: !root.backend.isAnonymousInputDevice

                            RowLayout {
                                id: rScroll
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@label:slider", "Sarma Hızı")
                                    }
                                    QQC2.Label {
                                        text: "Fare tekerleğiyle sayfalarda gezinme çarpanını belirleyin"
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                ColumnLayout {
                                    Layout.preferredWidth: Math.min(parent.width * 0.48, 280)
                                    spacing: 2

                                    QQC2.Slider {
                                        id: scrollFactor
                                        Layout.fillWidth: true
                                        from: 0
                                        to: 14
                                        stepSize: 1
                                        enabled: root.device !== null

                                        readonly property list<real> values: [
                                            0.1, 0.3, 0.5, 0.75, 1, 1.5, 2, 3, 4, 5, 7, 9, 12, 15, 20
                                        ]

                                        function indexOf(val: real): int {
                                            const index = values.indexOf(val)
                                            return index === -1 ? values.indexOf(1) : index
                                        }
                                        value: indexOf(root.device?.scrollFactor ?? 1)

                                        onMoved: {
                                            if (root.device) {
                                                root.device.scrollFactor = values[value]
                                            }
                                        }

                                        background: Rectangle {
                                            x: scrollFactor.leftPadding
                                            y: Math.round(scrollFactor.topPadding + (scrollFactor.availableHeight - height) / 2)
                                            implicitWidth: 200
                                            implicitHeight: 6
                                            width: scrollFactor.availableWidth
                                            height: 6
                                            radius: 3
                                            color: "#e2e8f0"

                                            Rectangle {
                                                width: Math.max(0, Math.min(parent.width, scrollFactor.visualPosition * parent.width))
                                                height: parent.height
                                                radius: 3
                                                color: scrollFactor.enabled ? "#007aff" : "#94a3b8"

                                                Behavior on color { ColorAnimation { duration: 150 } }
                                            }
                                        }

                                        handle: Rectangle {
                                            x: Math.round(scrollFactor.leftPadding + scrollFactor.visualPosition * (scrollFactor.availableWidth - width))
                                            y: Math.round(scrollFactor.topPadding + (scrollFactor.availableHeight - height) / 2)
                                            implicitWidth: 18
                                            implicitHeight: 18
                                            radius: 9
                                            color: "#ffffff"
                                            border.color: scrollFactor.pressed ? "#007aff" : (scrollFactor.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
                                            border.width: scrollFactor.pressed || scrollFactor.hovered ? 2 : 1

                                            Rectangle {
                                                anchors.centerIn: parent
                                                width: parent.width + 6
                                                height: parent.height + 6
                                                radius: width / 2
                                                color: "#007aff"
                                                opacity: scrollFactor.pressed ? 0.25 : (scrollFactor.hovered ? 0.12 : 0)
                                                z: -1
                                                Behavior on opacity { NumberAnimation { duration: 150 } }
                                            }

                                            scale: scrollFactor.pressed ? 1.08 : (scrollFactor.hovered ? 1.04 : 1.0)
                                            Behavior on scale { NumberAnimation { duration: 150 } }
                                            Behavior on border.color { ColorAnimation { duration: 150 } }
                                        }
                                    }

                                    RowLayout {
                                        Layout.fillWidth: true
                                        QQC2.Label {
                                            text: i18ndc("kcmmouse", "@label", "Daha yavaş")
                                            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
                                            color: Kirigami.Theme.disabledTextColor
                                        }
                                        Item { Layout.fillWidth: true }
                                        QQC2.Label {
                                            text: i18ndc("kcmmouse", "@label", "Daha hızlı")
                                            font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.8
                                            color: Kirigami.Theme.disabledTextColor
                                        }
                                    }
                                }
                            }
                        }

                        // Ara Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Satır 2: Ters Sarma (Doğal Sarma)
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.6, rNatScroll.implicitHeight + 16)

                            RowLayout {
                                id: rNatScroll
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@option:check", "Sarma Yönünü Tersine Çevir")
                                    }
                                    QQC2.Label {
                                        text: "İçeriğin hareketini tekerleğin dönüş yönüyle uyumlu kılar (Doğal sarma)"
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                QQC2.Switch {
                                    id: naturalScroll
                                    enabled: root.device?.supportsNaturalScroll ?? false
                                    checked: enabled && (root.device?.naturalScroll ?? false)
                                    onToggled: {
                                        if (root.device) {
                                            root.device.naturalScroll = checked
                                        }
                                    }
                                }
                            }
                        }

                        // Ara Çizgi
                        Rectangle {
                            Layout.fillWidth: true
                            height: 1
                            color: Kirigami.Theme.textColor
                            opacity: 0.06
                        }

                        // Satır 3: Orta Fare Tuşuyla Sarma
                        Item {
                            Layout.fillWidth: true
                            implicitHeight: Math.max(Kirigami.Units.gridUnit * 2.6, rMidScroll.implicitHeight + 16)

                            RowLayout {
                                id: rMidScroll
                                anchors {
                                    fill: parent
                                    leftMargin: Kirigami.Units.smallSpacing
                                    rightMargin: Kirigami.Units.smallSpacing
                                }
                                spacing: Kirigami.Units.largeSpacing

                                ColumnLayout {
                                    Layout.fillWidth: true
                                    spacing: 2
                                    Kirigami.Heading {
                                        level: 5
                                        font.weight: Font.DemiBold
                                        text: i18ndc("kcmmouse", "@option:check", "Orta Fare Tuşuyla Sarma")
                                    }
                                    QQC2.Label {
                                        text: i18ndc("kcmmouse", "@info", "Sarmak için orta fare düğmesini basılı tutup fareyi hareket ettirin")
                                        color: Kirigami.Theme.disabledTextColor
                                        font.pointSize: Kirigami.Theme.defaultFont.pointSize * 0.9
                                    }
                                }

                                RowLayout {
                                    spacing: Kirigami.Units.smallSpacing
                                    QQC2.Switch {
                                        id: scrollOnButtonDown
                                        enabled: root.device?.supportsScrollOnButtonDown ?? false
                                        checked: enabled && (root.device?.scrollOnButtonDown ?? false)
                                        onToggled: {
                                            if (root.device) {
                                                root.device.scrollOnButtonDown = checked
                                            }
                                        }
                                    }
                                    Kirigami.ContextualHelpButton {
                                        toolTipText: i18ndc("kcmmouse", "@info:whatsthis", "Bu özellik, orta tuşla sürükleme kullanan uygulamalarda çakışabilir. Öncelikle tekerleği bulunmayan cihazlar içindir.")
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
    }
}
