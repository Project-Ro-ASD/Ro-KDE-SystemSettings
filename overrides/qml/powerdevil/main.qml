/*
 *  SPDX-FileCopyrightText: 2023 Jakob Petsovits <jpetso@petsovits.com>
 *
 *  SPDX-License-Identifier: GPL-2.0-only OR GPL-3.0-only OR LicenseRef-KDE-Accepted-GPL
 */

import QtQuick
import QtQuick.Controls as QQC2
import QtQuick.Layouts
import org.kde.kcmutils as KCM
import org.kde.kirigami as Kirigami

KCM.AbstractKCM {
    id: root

    KCM.ConfigModule.buttons: KCM.ConfigModule.Default | KCM.ConfigModule.Apply | KCM.ConfigModule.Help

    actions: Kirigami.Action {
        text: i18nc("@action:button", "Configure Advanced &Settings…")
        icon.name: "settings-configure"
        enabled: kcm.powerManagementServiceRegistered
        displayHint: Kirigami.DisplayHint.KeepVisible
        onTriggered: { kcm.push("GlobalConfig.qml"); }
    }

    implicitWidth: Kirigami.Units.gridUnit * 30
    implicitHeight: Kirigami.Units.gridUnit * 35
    framedView: false

    Rectangle {
        // We're using AbstractKCM so that the automatic scrolling support of SimpleKCM
        // doesn't get in the way of the "tab content" Flickable below.
        // Use this lovely rectangle instead to still give the view a default background color.
        anchors.fill: parent
        color: Kirigami.Theme.backgroundColor
    }

    Kirigami.PlaceholderMessage {
        id: errorMessage
        anchors.centerIn: parent
        width: parent.width - (Kirigami.Units.largeSpacing * 4)
        visible: !kcm.powerManagementServiceRegistered
        icon.name: "dialog-error"
        text: i18nc("@text:placeholdermessage", "Power Management settings could not be loaded")
        explanation: kcm.powerManagementServiceErrorReason
    }

    ColumnLayout {
        anchors.fill: parent
        visible: kcm.powerManagementServiceRegistered
        spacing: 0

        RowLayout {
            id: profileTabBar

            Layout.alignment: Qt.AlignHCenter
            Layout.topMargin: Kirigami.Units.largeSpacing
            Layout.bottomMargin: Kirigami.Units.largeSpacing
            spacing: 8
            visible: kcm.supportsBatteryProfiles

            property var selectedProfile: kcm.currentProfile || "AC"
            property bool allowAutoSwitchProfile: true

            readonly property var profileInfo: ({
                "AC": { label: i18n("Fişe Takılıyken"), icon: "battery-full-charging"},
                "Battery": {label: i18n("Pille Çalışırken"), icon: "battery-good"},
                "LowBattery": {label: i18n("Düşük Pille Çalışırken"), icon: "battery-low"},
            })

            function setProfileAndStopAutoSwitch(profile) {
                allowAutoSwitchProfile = false;
                selectedProfile = profile;
            }
            function stopAutoSwitchProfileOnInit() {
                if (allowAutoSwitchProfile && kcm.currentProfile) {
                    setProfileAndStopAutoSwitch(kcm.currentProfile);
                }
            }
            Component.onCompleted: { profileTabBar.stopAutoSwitchProfileOnInit(); }
            Connections {
                target: kcm
                function onCurrentProfileChanged() { profileTabBar.stopAutoSwitchProfileOnInit(); }
            }

            Repeater {
                model: [
                    { id: "AC", label: i18n("Fişe Takılıyken"), icon: "battery-full-charging" },
                    { id: "Battery", label: i18n("Pille Çalışırken"), icon: "battery-good" },
                    { id: "LowBattery", label: i18n("Düşük Pille Çalışırken"), icon: "battery-low" }
                ]
                QQC2.Button {
                    id: tabBtn
                    text: modelData.label
                    icon.name: modelData.icon
                    checked: profileTabBar.selectedProfile === modelData.id
                    checkable: true
                    flat: true
                    implicitHeight: 36
                    padding: Kirigami.Units.largeSpacing
                    background: Rectangle {
                        radius: 18
                        color: tabBtn.checked ? Kirigami.Theme.highlightColor : (tabBtn.hovered ? Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.08) : Qt.rgba(Kirigami.Theme.textColor.r, Kirigami.Theme.textColor.g, Kirigami.Theme.textColor.b, 0.04))
                    }
                    contentItem: RowLayout {
                        spacing: 8
                        Kirigami.Icon {
                            source: tabBtn.icon.name
                            implicitWidth: 16
                            implicitHeight: 16
                            color: tabBtn.checked ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                        }
                        QQC2.Label {
                            text: tabBtn.text
                            color: tabBtn.checked ? Kirigami.Theme.highlightedTextColor : Kirigami.Theme.textColor
                            font.weight: tabBtn.checked ? Font.DemiBold : Font.Normal
                        }
                    }
                    onClicked: {
                        profileTabBar.setProfileAndStopAutoSwitch(modelData.id);
                    }
                }
            }
        }

        Item {
            id: scrollBarContainer
            clip: true

            Layout.fillWidth: true
            Layout.fillHeight: true
            implicitWidth: flickable.implicitWidth
            implicitHeight: flickable.implicitHeight

            Flickable {
                id: flickable

                anchors.fill: scrollBarContainer
                implicitWidth: wheelHandler.horizontalStepSize * 10 + leftMargin + rightMargin
                implicitHeight: wheelHandler.verticalStepSize * 10 + topMargin + bottomMargin
                contentWidth: contentItem.childrenRect.width
                contentHeight: contentItem.childrenRect.height

                leftMargin: QQC2.ScrollBar.vertical.visible && QQC2.ScrollBar.vertical.mirrored ? QQC2.ScrollBar.vertical.width : 0
                rightMargin: QQC2.ScrollBar.vertical.visible && !QQC2.ScrollBar.vertical.mirrored ? QQC2.ScrollBar.vertical.width : 0
                bottomMargin: QQC2.ScrollBar.horizontal.visible ? QQC2.ScrollBar.horizontal.height : 0

                Kirigami.WheelHandler {
                    id: wheelHandler
                    target: flickable
                    filterMouseEvents: true
                    keyNavigationEnabled: true
                }

                QQC2.ScrollBar.vertical: QQC2.ScrollBar {
                    parent: scrollBarContainer
                    height: flickable.height - flickable.topMargin - flickable.bottomMargin
                    x: mirrored ? 0 : flickable.width - width
                    y: flickable.topMargin
                    active: flickable.QQC2.ScrollBar.horizontal.active
                    stepSize: wheelHandler.verticalStepSize / flickable.contentHeight
                }

                QQC2.ScrollBar.horizontal: QQC2.ScrollBar {
                    parent: scrollBarContainer
                    width: flickable.width - flickable.leftMargin - flickable.rightMargin
                    x: flickable.leftMargin
                    y: flickable.height - height
                    active: flickable.QQC2.ScrollBar.vertical.active
                    stepSize: wheelHandler.horizontalStepSize / flickable.contentWidth
                }

                Item {
                    id: tabContentContainer
                    width: scrollBarContainer.width - flickable.leftMargin - flickable.rightMargin
                    height: Math.max(scrollBarContainer.height - flickable.topMargin - flickable.bottomMargin, profileConfig.height + Kirigami.Units.smallSpacing)

                    MouseArea {
                        anchors.fill: parent
                        onClicked: {
                            // allow closing popups by clicking outside
                            profileConfig.forceActiveFocus();
                        }
                    }

                    ProfileConfig {
                        id: profileConfig
                        profileId: profileTabBar.selectedProfile
                        profileLabel: profileTabBar.profileInfo[profileTabBar.selectedProfile].label

                        width: tabContentContainer.width - 2 * Kirigami.Units.smallSpacing
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.top: tabContentContainer.top
                    }
                }
            }
        }
    }
}
