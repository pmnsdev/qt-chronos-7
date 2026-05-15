import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string gatewayId: "GW-A"
    property string role: "Gateway"
    property string state: "ACTIVE"
    property string utcSrc: "GNSS"
    property int sites: 0
    property string health: "ok"

    implicitHeight: 58
    color: "transparent"
    border.color: ChronosTokens.panelBorderDim
    radius: ChronosTokens.radiusSmall

    RowLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 10

        StatusLed { severity: root.health }

        ColumnLayout {
            spacing: 2
            Layout.fillWidth: true
            Text { text: root.gatewayId + " - " + root.role; color: ChronosTokens.foreground; font.pixelSize: 12; font.bold: true; font.family: ChronosTokens.monoFont; elide: Text.ElideRight; Layout.fillWidth: true }
            Text { text: "utc " + root.utcSrc + "  sites " + root.sites; color: ChronosTokens.mutedText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
        }

        SeverityTag { text: root.state; severity: root.state === "ACTIVE" ? "ok" : "info" }
    }
}
