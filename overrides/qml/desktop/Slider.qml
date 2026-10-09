/*
    SPDX-License-Identifier: LGPL-3.0-only OR GPL-2.0-or-later
*/

import QtQuick
import QtQuick.Templates as T
import org.kde.kirigami as Kirigami

T.Slider {
    id: controlRoot

    Kirigami.Theme.colorSet: Kirigami.Theme.Button

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            160)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             26)

    baselineOffset: background ? background.y + background.baselineOffset : 0

    hoverEnabled: true

    snapMode: T.Slider.SnapOnRelease

    handle: Rectangle {
        id: sliderHandle
        readonly property real handleDiameter: 18
        width: handleDiameter
        height: handleDiameter
        radius: handleDiameter / 2

        x: controlRoot.orientation === Qt.Horizontal
            ? Math.round(controlRoot.leftPadding + controlRoot.visualPosition * (controlRoot.availableWidth - width))
            : Math.round(controlRoot.leftPadding + (controlRoot.availableWidth - width) / 2)
        y: controlRoot.orientation === Qt.Horizontal
            ? Math.round(controlRoot.topPadding + (controlRoot.availableHeight - height) / 2)
            : Math.round(controlRoot.topPadding + (1.0 - controlRoot.visualPosition) * (controlRoot.availableHeight - height))

        color: "#ffffff"
        border.color: controlRoot.pressed ? "#007aff" : (controlRoot.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
        border.width: controlRoot.pressed || controlRoot.hovered ? 2 : 1

        // Yumuşak gölge / vurgu efekti
        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 6
            height: parent.height + 6
            radius: width / 2
            color: "#007aff"
            opacity: controlRoot.pressed ? 0.25 : (controlRoot.hovered ? 0.12 : 0)
            z: -1
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        scale: controlRoot.pressed ? 1.08 : (controlRoot.hovered ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutQuad } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }

    background: Item {
        id: bgItem
        implicitWidth: controlRoot.orientation === Qt.Horizontal ? 200 : 26
        implicitHeight: controlRoot.orientation === Qt.Horizontal ? 26 : 200

        readonly property real trackThickness: 6
        readonly property real trackRadius: trackThickness / 2

        // Yatay Parça (Horizontal Track)
        Rectangle {
            visible: controlRoot.orientation === Qt.Horizontal
            anchors.centerIn: parent
            width: parent.width
            height: bgItem.trackThickness
            radius: bgItem.trackRadius
            color: "#e2e8f0"

            Rectangle {
                anchors.left: parent.left
                anchors.top: parent.top
                anchors.bottom: parent.bottom
                width: Math.max(0, Math.min(parent.width, controlRoot.visualPosition * parent.width))
                radius: bgItem.trackRadius
                color: controlRoot.enabled ? "#007aff" : "#94a3b8"

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Dikey Parça (Vertical Track)
        Rectangle {
            visible: controlRoot.orientation === Qt.Vertical
            anchors.centerIn: parent
            width: bgItem.trackThickness
            height: parent.height
            radius: bgItem.trackRadius
            color: "#e2e8f0"

            Rectangle {
                anchors.bottom: parent.bottom
                anchors.left: parent.left
                anchors.right: parent.right
                height: Math.max(0, Math.min(parent.height, (1.0 - controlRoot.visualPosition) * parent.height))
                radius: bgItem.trackRadius
                color: controlRoot.enabled ? "#007aff" : "#94a3b8"

                Behavior on color { ColorAnimation { duration: 150 } }
            }
        }

        // Mouse tekerleği ile ayarlama desteği
        MouseArea {
            property int wheelDelta: 0
            anchors.fill: parent
            acceptedButtons: Qt.NoButton
            onWheel: wheel => {
                const lastValue = controlRoot.value
                const delta = (wheel.angleDelta.y || -wheel.angleDelta.x) * (wheel.inverted ? -1 : 1)
                wheelDelta += delta
                while (wheelDelta >= 120) {
                    wheelDelta -= 120
                    controlRoot.increase()
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120
                    controlRoot.decrease()
                }
                if (lastValue !== controlRoot.value) {
                    controlRoot.moved()
                }
            }
        }
    }
}
