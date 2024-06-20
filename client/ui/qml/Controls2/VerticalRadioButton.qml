import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import Qt5Compat.GraphicalEffects

import "TextTypes"

RadioButton {
    id: root

    property int textMaximumLineCount: 2
    property int textElide: Qt.ElideRight
    property string descriptionText

    property string hoveredColor: Qt.rgba(1, 1, 1, 0.05)
    property string defaultColor: Qt.rgba(1, 1, 1, 0)
    property string disabledColor: Qt.rgba(1, 1, 1, 0)
    property string selectedColor: Qt.rgba(1, 1, 1, 0)

    property string textColor: "#D7D8DB"
    property string selectedTextColor: "#BD5871"

    property string borderFocusedColor: "#D7D8DB"
    property int borderFocusedWidth: 1

    property string imageSource
    property bool showImage

    hoverEnabled: true
    focusPolicy: Qt.TabFocus

    indicator: Rectangle {
        id: background

        anchors.verticalCenter: parent.verticalCenter

        border.color: root.focus ? root.borderFocusedColor : "transparent"
        border.width: root.focus ? root.borderFocusedWidth : 0

        implicitWidth: 56
        implicitHeight: 56
        radius: 16

        color: {
            if (root.enabled) {
                if (root.hovered) {
                    return hoveredColor
                } else if (root.checked) {
                    return selectedColor
                }
                return defaultColor
            } else {
                return disabledColor
            }
        }

        Behavior on color {
            PropertyAnimation { duration: 200 }
        }

        Behavior on border.color {
            PropertyAnimation { duration: 200 }
        }

        Image {
            source: {
                if (showImage) {
                    return imageSource
                } else if (root.pressed) {
                    return "qrc:/images/controls/radio-button-inner-circle-pressed.png"
                } else if (root.checked) {
                    return "qrc:/images/controls/radio-button-inner-circle.png"
                }

                return ""
            }

            anchors.centerIn: parent

            width: 24
            height: 24
        }

        Image {
            source: {
                if (showImage) {
                    return ""
                } else if (root.pressed || root.checked) {
                    return "qrc:/images/controls/radio-button-pressed.svg"
                } else {
                    return "qrc:/images/controls/radio-button.svg"
                }
            }

            anchors.centerIn: parent

            width: 24
            height: 24
        }
    }

    contentItem: Item {
        anchors.left: parent.left
        anchors.right: parent.right
        anchors.leftMargin: 8 + background.width

        implicitHeight: content.implicitHeight

        ColumnLayout {
            id: content

            anchors.left: parent.left
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            spacing: 4

            ListItemTitleType {
                text: root.text
                maximumLineCount: root.textMaximumLineCount
                elide: root.textElide

                color: {
                    if (root.checked) {
                        return selectedTextColor
                    }
                    return textColor
                }

                Layout.fillWidth: true

                Behavior on color {
                    PropertyAnimation { duration: 200 }
                }
            }

            CaptionTextType {
                id: description

                color: "#878B91"
                text: root.descriptionText

                visible: root.descriptionText !== ""

                Layout.fillWidth: true
            }
        }
    }

    MouseArea {
        anchors.fill: root
        cursorShape: Qt.PointingHandCursor
        enabled: false
    }
}


