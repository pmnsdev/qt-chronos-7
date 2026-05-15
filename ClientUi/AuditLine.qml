import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string severity: "info"
    property string timestamp: "00:00:00"
    property string source: "system"
    property string message: ""

    height: 26
    color: mouseArea.containsMouse ? ChronosTokens.panelHover : "transparent"

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        StatusLed { severity: root.severity; blinkOnCritical: false; Layout.preferredWidth: 16 }
        Text { text: root.timestamp; color: ChronosTokens.mutedText; font.pixelSize: 12; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 86 }
        Text { text: root.source; color: ChronosTokens.info; font.pixelSize: 12; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 120 }
        Text { text: root.message; color: root.severity === "crit" ? ChronosTokens.crit : root.severity === "warn" ? ChronosTokens.warn : root.severity === "ok" ? ChronosTokens.ok : ChronosTokens.foreground; font.pixelSize: 12; font.family: ChronosTokens.monoFont; elide: Text.ElideRight; Layout.fillWidth: true }
    }

    MouseArea { id: mouseArea; anchors.fill: parent; hoverEnabled: true; acceptedButtons: Qt.NoButton }
}
