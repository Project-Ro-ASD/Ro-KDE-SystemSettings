pragma ComponentBehavior: Bound

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kirigami as Kirigami
import org.kde.systemsettings
import org.kde.systemsettings.nav 1.0

Kirigami.ScrollablePage {
    id: subSubCategoryColumn

    Kirigami.Theme.colorSet: Kirigami.Theme.View
    Kirigami.Theme.inherit: false

    readonly property var elements: [
        {
            icon: "zoom-in",
            title: i18nc("@title Category name in sidebar", "Zoom & Magnifier")
        },
        {
            icon: "notifications",
            title: i18nc("@title Category name in sidebar", "System Bell")
        },
        {
            icon: "input-keyboard",
            title: i18nc("@title Category name in sidebar", "Modifier Keys")
        },
        {
            icon: "view-filter",
            title: i18nc("@title Category name in sidebar", "Keyboard Filters")
        },
        {
            icon: "input-mouse",
            title: i18nc("@title Category name in sidebar", "Mouse Navigation")
        },
        {
            icon: "input-caps-on",
            title: i18nc("@title Category name in sidebar", "Activation Shortcuts")
        },
        {
            icon: "text-speak",
            title: i18nc("@title Category name in sidebar", "Screen Reader")
        },
        {
            icon: "view-visible",
            title: i18nc("@title Category name in sidebar", "Color Blindness Correction")
        },
        {
            icon: "image-invert-symbolic",
            title: i18nc("@title Category name in sidebar, for inverting screen colors", "Invert")
        },
        {
            icon: "cursor-arrow",
            title: i18nc("@title Category name in sidebar, shake pointer to find it", "Shake Pointer")
        }
    ]

    header: Kirigami.AbstractApplicationHeader {
        id: pageHeader

        contentItem: RowLayout {
            id: rowLayout
            anchors.fill: parent
            spacing: Kirigami.Units.smallSpacing

            NavButton {
                id: backNavBtn
                symbol: "<"
                enabled: true
                tooltip: i18n("Geri")
                onClicked: {
                    SettingsNav.goBack();
                }
            }

            NavButton {
                id: forwardNavBtn
                symbol: ">"
                enabled: false
                tooltip: i18n("İleri")
            }

            QQC2.Label {
                id: headerTitle
                Layout.fillWidth: true
                Layout.fillHeight: true
                text: SettingsNav.level2Title !== "" ? SettingsNav.level2Title : i18n("Erişilebilirlik")
                font.bold: true
                font.pixelSize: 14
                verticalAlignment: Text.AlignVCenter
                elide: Text.ElideRight
                textFormat: Text.PlainText
            }

            HamburgerMenuButton {
                id: hamburgerMenuButton
            }
        }
    }

    ListView {
        id: subSubView

        anchors.fill: parent
        model: subSubCategoryColumn.elements
        currentIndex: SettingsNav.accessIndex
        activeFocusOnTab: true
        keyNavigationWraps: true
        Accessible.role: Accessible.List

        delegate: QQC2.ItemDelegate {
            id: delegate

            required property int index
            required property var modelData

            width: ListView.view?.width ?? 0
            text: modelData.title
            icon.name: modelData.icon

            highlighted: ListView.isCurrentItem

            contentItem: RowLayout {
                spacing: Kirigami.Units.smallSpacing

                Kirigami.IconTitleSubtitle {
                    Layout.fillWidth: true
                    icon: icon.fromControlsIcon(delegate.icon)
                    title: delegate.text
                    selected: delegate.highlighted || delegate.pressed
                }
            }

            onClicked: {
                SettingsNav.selectAccessPage(index);
                subSubView.currentIndex = index;
            }

            Keys.onEnterPressed: clicked()
            Keys.onReturnPressed: clicked()
            Keys.onEscapePressed: SettingsNav.goBack()

            Keys.onLeftPressed: {
                if (!LayoutMirroring.enabled) {
                    SettingsNav.goBack();
                }
            }
            Keys.onRightPressed: {
                if (LayoutMirroring.enabled) {
                    SettingsNav.goBack();
                }
            }
        }
    }
}
