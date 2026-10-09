import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.Slider {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitHandleWidth + leftPadding + rightPadding,
                            160)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitHandleHeight + topPadding + bottomPadding,
                             26)

    hoverEnabled: true

    background: Rectangle {
        x: control.leftPadding
        y: Math.round(control.topPadding + (control.availableHeight - height) / 2)
        implicitWidth: 200
        implicitHeight: 6
        width: control.availableWidth
        height: 6
        radius: 3
        color: "#e2e8f0"

        Rectangle {
            width: Math.max(0, Math.min(parent.width, control.visualPosition * parent.width))
            height: parent.height
            radius: 3
            color: control.enabled ? "#007aff" : "#94a3b8"

            Behavior on color { ColorAnimation { duration: 150 } }
        }
    }

    handle: Rectangle {
        x: Math.round(control.leftPadding + control.visualPosition * (control.availableWidth - width))
        y: Math.round(control.topPadding + (control.availableHeight - height) / 2)
        implicitWidth: 18
        implicitHeight: 18
        radius: 9
        color: "#ffffff"
        border.color: control.pressed ? "#007aff" : (control.hovered ? "#007aff" : Qt.rgba(0, 0, 0, 0.2))
        border.width: control.pressed || control.hovered ? 2 : 1

        Rectangle {
            anchors.centerIn: parent
            width: parent.width + 6
            height: parent.height + 6
            radius: width / 2
            color: "#007aff"
            opacity: control.pressed ? 0.25 : (control.hovered ? 0.12 : 0)
            z: -1
            Behavior on opacity { NumberAnimation { duration: 150 } }
        }

        scale: control.pressed ? 1.08 : (control.hovered ? 1.04 : 1.0)
        Behavior on scale { NumberAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }
    }
}
