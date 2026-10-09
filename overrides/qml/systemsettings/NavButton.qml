import QtQuick
import QtQuick.Controls as QQC2
import org.kde.kirigami as Kirigami

QQC2.AbstractButton {
    id: root

    property string symbol: "<"
    property string tooltip: ""

    implicitWidth: 30
    implicitHeight: 30

    hoverEnabled: true

    QQC2.ToolTip.visible: hovered && tooltip !== ""
    QQC2.ToolTip.text: tooltip
    QQC2.ToolTip.delay: Kirigami.Units.toolTipDelay

    background: Rectangle {
        implicitWidth: 30
        implicitHeight: 30
        radius: 8
        color: {
            if (!root.enabled) {
                return "transparent";
            }
            if (root.pressed) {
                return Qt.rgba(0, 0, 0, 0.12);
            }
            if (root.hovered) {
                return Qt.rgba(0, 0, 0, 0.07);
            }
            return Qt.rgba(0, 0, 0, 0.03);
        }
        border.color: {
            if (!root.enabled) {
                return Qt.rgba(0, 0, 0, 0.04);
            }
            if (root.hovered) {
                return Qt.rgba(0, 0, 0, 0.15);
            }
            return Qt.rgba(0, 0, 0, 0.08);
        }
        border.width: 1

        Behavior on color {
            ColorAnimation { duration: 120 }
        }
        Behavior on border.color {
            ColorAnimation { duration: 120 }
        }
    }

    contentItem: Text {
        text: root.symbol
        font.pixelSize: 15
        font.bold: true
        font.family: "Noto Sans, Inter, Roboto, sans-serif"
        horizontalAlignment: Text.AlignHCenter
        verticalAlignment: Text.AlignVCenter
        color: root.enabled ? Kirigami.Theme.textColor : Kirigami.Theme.disabledTextColor
        opacity: root.enabled ? 0.95 : 0.3
    }
}
