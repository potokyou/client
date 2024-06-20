import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Config"
import "../Controls2/TextTypes"

PageType {
    id: root

    defaultActiveFocusItem: hostname.textField

    Item {
        id: focusItem
        KeyNavigation.tab: backButton
    }

    BackButtonType {
        id: backButton

        anchors.top: parent.top
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.topMargin: 20

        KeyNavigation.tab: hostname.textField
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
            anchors.rightMargin: 16
            anchors.leftMargin: 16

            spacing: 16

            HeaderType {
                Layout.fillWidth: true

                headerText: qsTr("For developers")
            }

            TextFieldWithHeaderType {
                id: hostname

                Layout.fillWidth: true
                headerText: qsTr("Server IP address [:port]")
                textFieldPlaceholderText: qsTr("255.255.255.255:22")
                textField.validator: RegularExpressionValidator {
                    regularExpression: InstallController.ipAddressPortRegExp()
                }

                textField.onFocusChanged: {
                    textField.text = textField.text.replace(/^\s+|\s+$/g, '')
                }

                KeyNavigation.tab: username.textField
            }

            TextFieldWithHeaderType {
                id: username

                Layout.fillWidth: true
                headerText: qsTr("SSH Username")
                textFieldPlaceholderText: "root"

                textField.onFocusChanged: {
                    textField.text = textField.text.replace(/^\s+|\s+$/g, '')
                }

                KeyNavigation.tab: secretData.textField
            }

            TextFieldWithHeaderType {
                id: secretData

                property bool hidePassword: true

                Layout.fillWidth: true
                headerText: qsTr("Password or SSH private key")
                textField.echoMode: hidePassword ? TextInput.Password : TextInput.Normal
                buttonImageSource: textFieldText !== "" ? (hidePassword ? "qrc:/images/controls/eye.svg" : "qrc:/images/controls/eye-off.svg")
                                                        : ""

                clickedFunc: function() {
                    hidePassword = !hidePassword
                }

                textField.onFocusChanged: {
                    textField.text = textField.text.replace(/^\s+|\s+$/g, '')
                }

                KeyNavigation.tab: continueButton
            }

            BasicButtonType {
                id: continueButton

                Layout.fillWidth: true
                Layout.topMargin: 24

                text: qsTr("Continue")

                Keys.onTabPressed: lastItemTabClicked(focusItem)

                clickedFunc: function() {
                    forceActiveFocus()
                    if (!isCredentialsFilled()) {
                        return
                    }

                    InstallController.setShouldCreateServer(true)
                    InstallController.setProcessedServerCredentials(hostname.textField.text, username.textField.text, secretData.textField.text)

                    PageController.showBusyIndicator(true)
                    var isConnectionOpened = InstallController.checkSshConnection()
                    PageController.showBusyIndicator(false)
                    if (!isConnectionOpened) {
                        return
                    }

                    PageController.goToPage(PageEnum.PageSetupWizardEasy)
                }
            }

            LabelTextType {
                Layout.fillWidth: true
                Layout.topMargin: 12

                text: qsTr("All data you enter will remain strictly confidential and will not be shared or disclosed to the Potok or any third parties")
            }
        }
    }

    function isCredentialsFilled() {
        var hasEmptyField = false

        if (hostname.textFieldText === "") {
            hostname.errorText = qsTr("Ip address cannot be empty")
            hasEmptyField = true
        } else if (!hostname.textField.acceptableInput) {
            hostname.errorText = qsTr("Enter the address in the format 255.255.255.255:88")
        }

        if (username.textFieldText === "") {
            username.errorText = qsTr("Login cannot be empty")
            hasEmptyField = true
        }
        if (secretData.textFieldText === "") {
            secretData.errorText = qsTr("Password/private key cannot be empty")
            hasEmptyField = true
        }
        return !hasEmptyField
    }
}
