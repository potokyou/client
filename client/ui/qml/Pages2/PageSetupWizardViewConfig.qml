import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import QtQuick.Dialogs

import PageEnum 1.0

import "./"
import "../Controls2"
import "../Controls2/TextTypes"
import "../Config"

PageType {
    id: root

    property bool showContent: false

    defaultActiveFocusItem: focusItem

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

        KeyNavigation.tab: showContentButton
    }

    Connections {
        target: ImportController

        function onImportErrorOccurred(errorMessage, goToPageHome) {
            if (goToPageHome) {
                PageController.goToStartPage()
            } else {
                PageController.closePage()
            }
        }

        function onImportFinished() {
            if (!ConnectionController.isConnected) {
                ServersModel.setDefaultServerIndex(ServersModel.getServersCount() - 1);
                ServersModel.processedIndex = ServersModel.defaultIndex
            }

            PageController.goToStartPage()
            if (stackView.currentItem.objectName === PageController.getPagePath(PageEnum.PageSetupWizardStart)) {
                PageController.replaceStartPage()
            }
        }
    }

    FlickableType {
        id: fl
        anchors.top: backButton.bottom
        anchors.bottom: parent.bottom
        contentHeight: content.implicitHeight + connectButton.implicitHeight

        ColumnLayout {
            id: content

            anchors.top: parent.top
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.rightMargin: 16
            anchors.leftMargin: 16

            HeaderType {
                headerText: qsTr("New connection")
            }

            RowLayout {
                Layout.topMargin: 32
                spacing: 8

                visible: fileName.text !== ""

                Image {
                    source: "qrc:/images/controls/file-check-2.svg"
                }

                Header2TextType {
                    id: fileName

                    Layout.fillWidth: true

                    text: ImportController.getConfigFileName()
                    wrapMode: Text.Wrap
                }
            }

            CheckBoxType {
                id: cloakingCheckBox

                visible: ImportController.isNativeWireGuardConfig()

                Layout.fillWidth: true
                text: qsTr("Enable WireGuard obfuscation. It may be useful if WireGuard is blocked on your provider.")
            }

            WarningType {
                Layout.topMargin: 16
                Layout.fillWidth: true

                textString: ImportController.getMaliciousWarningText()
                textFormat: Qt.RichText
                visible: textString !== ""

                iconPath: "qrc:/images/controls/alert-circle.svg"

                textColor: "#EB5757"
                imageColor: "#EB5757"
            }

            WarningType {
                Layout.topMargin: 16
                Layout.fillWidth: true

                textString: qsTr("Use only the configuration files that you received when paying for a subscription through the Telegram bot.")

                iconPath: "qrc:/images/controls/alert-circle.svg"
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.bottomMargin: 48

                implicitHeight: configContent.implicitHeight

                radius: 10
                color: "#130a29"

                visible: showContent

                ParagraphTextType {
                    id: configContent

                    anchors.fill: parent
                    anchors.margins: 16

                    wrapMode: Text.Wrap

                    text: ImportController.getConfig()
                }
            }
        }
    }

    Rectangle {
        anchors.fill: columnContent
        anchors.bottomMargin: -24
        color: "#333d5f"
        opacity: 0.8
    }

    ColumnLayout {
        id: columnContent
        anchors.bottom: parent.bottom
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.rightMargin: 16
        anchors.leftMargin: 16

        Keys.onTabPressed: lastItemTabClicked(focusItem)

        BasicButtonType {
            id: connectButton
            Layout.fillWidth: true
            Layout.bottomMargin: 32

            text: qsTr("Connect")
            clickedFunc: function() {
                if (cloakingCheckBox.checked) {
                    ImportController.processNativeWireGuardConfig()
                }
                ImportController.importConfig()
            }
        }
    }
}
