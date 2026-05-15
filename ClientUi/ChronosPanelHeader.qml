import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string kicker: ""
    property string title: "PANEL"
    property alias rightContent: rightSlot.data

    height: 42
    color: "transparent"
    border.color: "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 14
        anchors.rightMargin: 14
        spacing: 10

        Text {
            visible: root.kicker.length > 0
            text: root.kicker
            color: ChronosTokens.faintText
            font.pixelSize: 10
            font.letterSpacing: 2
            font.family: ChronosTokens.monoFont
        }

        Text {
            text: root.title
            color: ChronosTokens.foreground
            font.pixelSize: 14
            font.bold: true
            font.family: ChronosTokens.monoFont
            Layout.fillWidth: true
            elide: Text.ElideRight
        }

        Item {
            id: rightSlot
            Layout.preferredWidth: childrenRect.width
            Layout.preferredHeight: 28
        }
    }

    Rectangle {
        height: 1
        width: parent.width
        anchors.bottom: parent.bottom
        color: ChronosTokens.panelBorder
    }
}
