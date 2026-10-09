import QtQuick
import QtQuick.Templates as T
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.RadioButton {
    id: control

    implicitWidth: Math.max(implicitBackgroundWidth + leftInset + rightInset,
                            implicitContentWidth + leftPadding + rightPadding,
                            implicitIndicatorWidth + leftPadding + rightPadding)
    implicitHeight: Math.max(implicitBackgroundHeight + topInset + bottomInset,
                             implicitContentHeight + topPadding + bottomPadding,
                             implicitIndicatorHeight + topPadding + bottomPadding)

    spacing: Kirigami.Units.smallSpacing
    hoverEnabled: true

    indicator: Rectangle {
        implicitWidth: 20
        implicitHeight: 20
        x: control.leftPadding
        y: Math.round(control.topPadding + (control.availableHeight - height) / 2)
        radius: 10
        color: control.checked ? "#007aff" : "#ffffff"
        border.color: control.checked ? "#007aff" : (control.hovered ? "#007aff" : "#cbd5e1")
        border.width: control.checked ? 0 : 1.5

        Behavior on color { ColorAnimation { duration: 150 } }
        Behavior on border.color { ColorAnimation { duration: 150 } }

        // Saf beyaz iç nokta (siyah nokta yerine modern görünüm)
        Rectangle {
            anchors.centerIn: parent
            width: 8
            height: 8
            radius: 4
            color: "#ffffff"
            opacity: control.checked ? 1.0 : 0.0
            scale: control.checked ? 1.0 : 0.3

            Behavior on opacity { NumberAnimation { duration: 150 } }
            Behavior on scale { NumberAnimation { duration: 150; easing.type: Easing.OutBack } }
        }
    }
}
