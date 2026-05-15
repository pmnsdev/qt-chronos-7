import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string severity: "crit"
    property string timestamp: ""
    property string code: "ALARM"
    property string source: "SITE"
    property string message: ""

    height: 66
    color: mouseArea.containsMouse ? ChronosTokens.panelHover : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 12

        StatusLed { severity: root.severity }

        ColumnLayout {
            Layout.preferredWidth: 128
            spacing: 2
            Text { text: "TIMESTAMP UTC"; color: ChronosTokens.faintText; font.pixelSize: 9; font.letterSpacing: 1.2; font.family: ChronosTokens.monoFont }
            Text { text: root.timestamp; color: ChronosTokens.foreground; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
        }

        ColumnLayout {
            Layout.preferredWidth: 150
            SeverityTag { text: root.code; severity: root.severity }
            Text { text: "src: " + root.source; color: ChronosTokens.mutedText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
        }

        Text {
            text: root.message
            color: ChronosTokens.foreground
            opacity: 0.9
            font.pixelSize: 12
            font.family: ChronosTokens.monoFont
            wrapMode: Text.WordWrap
            Layout.fillWidth: true
        }

        Button { text: "ACK"; Layout.preferredWidth: 64; Layout.preferredHeight: 28 }
        Button { text: "TRACE"; Layout.preferredWidth: 72; Layout.preferredHeight: 28 }
    }

    MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
    Rectangle { anchors.bottom: parent.bottom; height: 1; width: parent.width; color: ChronosTokens.panelBorderDim }
}
