import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import QtCore

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Config"
import "../Components"
import "../Controls2/TextTypes"

PageType {
    id: root

    defaultActiveFocusItem: focusItem

    Connections {
        target: SettingsController

        function onChangeSettingsErrorOccurred(errorMessage) {
            PageController.showErrorMessage(errorMessage)
        }

        function onRestoreBackupFinished() {
            PageController.showNotificationMessage(qsTr("Settings restored from backup file"))
            //goToStartPage()
            PageController.goToPageHome()
        }

        function onImportBackupFromOutside(filePath) {
            restoreBackup(filePath)
        }
    }

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

        KeyNavigation.tab: makeBackupButton
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
            anchors.leftMargin: 16
            anchors.rightMargin: 16

            spacing: 16

            HeaderType {
                Layout.fillWidth: true

                headerText: qsTr("Back up your configuration")
                descriptionText: qsTr("You can save your settings to a backup file to restore them the next time you install the application.")
            }

            WarningType {
                Layout.topMargin: 16
                Layout.fillWidth: true

                textString: qsTr("The backup will contain your passwords and private keys for all servers added " +
                                            "to PotokVPN. Keep this information in a secure place.")

                iconPath: "qrc:/images/controls/alert-circle.svg"
            }

            BasicButtonType {
                id: makeBackupButton
                Layout.fillWidth: true
                Layout.topMargin: 14

                text: qsTr("Make a backup")

                clickedFunc: function() {
                    var fileName = ""
                    if (GC.isMobile()) {
                        fileName = "PotokVPN.backup"
                    } else {
                        fileName = SystemController.getFileName(qsTr("Save backup file"),
                                                                qsTr("Backup files (*.backup)"),
                                                                StandardPaths.standardLocations(StandardPaths.DocumentsLocation) + "/PotokVPN",
                                                                true,
                                                                ".backup")
                    }
                    if (fileName !== "") {
                        PageController.showBusyIndicator(true)
                        SettingsController.backupAppConfig(fileName)
                        PageController.showBusyIndicator(false)
                        PageController.showNotificationMessage(qsTr("Backup file saved"))
                    }
                }

                KeyNavigation.tab: restoreBackupButton
            }

            BasicButtonType {
                id: restoreBackupButton
                Layout.fillWidth: true
                Layout.topMargin: -8

                defaultColor: "transparent"
                hoveredColor: Qt.rgba(1, 1, 1, 0.08)
                pressedColor: Qt.rgba(1, 1, 1, 0.12)
                disabledColor: "#878B91"
                textColor: "#D7D8DB"
                borderWidth: 1

                text: qsTr("Restore from backup")

                clickedFunc: function() {
                    var filePath = SystemController.getFileName(qsTr("Open backup file"),
                                                                qsTr("Backup files (*.backup)"))
                    if (filePath !== "") {
                        restoreBackup(filePath)
                    }
                }

                Keys.onTabPressed: lastItemTabClicked()
            }
        }
    }

    function restoreBackup(filePath) {
        var headerText = qsTr("Import settings from a backup file?")
        var descriptionText = qsTr("All current settings will be reset");
        var yesButtonText = qsTr("Continue")
        var noButtonText = qsTr("Cancel")

        var yesButtonFunction = function() {
            if (ConnectionController.isConnected) {
                PageController.showNotificationMessage(qsTr("Cannot restore backup settings during active connection"))
            } else {
                PageController.showBusyIndicator(true)
                SettingsController.restoreAppConfig(filePath)
                PageController.showBusyIndicator(false)
            }
        }
        var noButtonFunction = function() {
        }

        showQuestionDrawer(headerText, descriptionText, yesButtonText, noButtonText, yesButtonFunction, noButtonFunction)
    }
}
