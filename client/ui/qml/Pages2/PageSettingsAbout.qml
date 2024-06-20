import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Config"
import "../Controls2/TextTypes"
import "../Components"

PageType {
    id: root

    defaultActiveFocusItem: focusItem

    Item {
        id: focusItem
        KeyNavigation.tab: backButton

        onFocusChanged: {
            if (focusItem.activeFocus) {
                fl.contentY = 0
            }
        }
    }

    BackButtonType {
        id: backButton

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20

        KeyNavigation.tab: telegramButton
    }

    FlickableType {
        id: fl
        anchors.top: backButton.bottom
        anchors.bottom: parent.bottom
        contentHeight: content.height

        ColumnLayout {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right

            Image {
                id: image
                source: "qrc:/images/potokBigLogo.png"

                Layout.alignment: Qt.AlignCenter
                Layout.topMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16
                Layout.preferredWidth: 291
                Layout.preferredHeight: 224
            }

            Header2TextType {
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                text: qsTr("PotokVPN")
                horizontalAlignment: Text.AlignHCenter
            }

            ParagraphTextType {
                Layout.fillWidth: true
                Layout.topMargin: 16
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                horizontalAlignment: Text.AlignHCenter

                height: 20
                font.pixelSize: 14

                text: qsTr("Potok is a premium VPN service aimed at bypassing restrictions.")
                color: "#CCCAC8"
            }

            ParagraphTextType {
                Layout.fillWidth: true
                Layout.topMargin: 32
                Layout.leftMargin: 16
                Layout.rightMargin: 16

                text: qsTr("Contacts")
            }

            LabelWithButtonType {
                id: telegramButton
                Layout.fillWidth: true
                Layout.topMargin: 16

                text: qsTr("Telegram канал")
                descriptionText: qsTr("With news about the project")
                leftImageSource: "qrc:/images/controls/telegram.svg"

                KeyNavigation.tab: mailButton
                parentFlickable: fl

                clickedFunction: function() {
                    Qt.openUrlExternally(qsTr("https://t.me/potok_you"))
                }
            }

            DividerType {}

            CaptionTextType {
                Layout.fillWidth: true
                Layout.topMargin: 40

                horizontalAlignment: Text.AlignHCenter

                text: qsTr("Software version: %1").arg(SettingsController.getAppVersion())
                color: "#878B91"
            }

            BasicButtonType {
                id: checkUpdatesButton
                Layout.alignment: Qt.AlignHCenter
                Layout.topMargin: 8
                Layout.bottomMargin: 16
                implicitHeight: 32

                defaultColor: "transparent"
                hoveredColor: Qt.rgba(1, 1, 1, 0.08)
                pressedColor: Qt.rgba(1, 1, 1, 0.12)
                disabledColor: "#878B91"
                textColor: "#FBB26A"

                text: qsTr("Our Telegram bot")

                KeyNavigation.tab: privacyPolicyButton
                parentFlickable: fl

                clickedFunc: function() {
                    Qt.openUrlExternally("https://t.me/potokVPN_bot")
                }
            }

            BasicButtonType {
              id: privacyPolicyButton
              Layout.alignment: Qt.AlignHCenter
              Layout.bottomMargin: 16
              Layout.topMargin: -15
              implicitHeight: 25

              defaultColor: "transparent"
              hoveredColor: Qt.rgba(1, 1, 1, 0.08)
              pressedColor: Qt.rgba(1, 1, 1, 0.12)
              disabledColor: "#878B91"
              textColor: "#FBB26A"

              text: qsTr("Privacy Policy")

              Keys.onTabPressed: lastItemTabClicked()
              parentFlickable: fl

              clickedFunc: function() {
                Qt.openUrlExternally("https://localhost/en/policy")
              }
            }
        }
    }
}
