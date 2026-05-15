import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root
    property var store

    ChronosPanel {
        anchors.fill: parent
        anchors.margins: 14
        title: "MODBUS / LTE AUDIT - TX RX STREAM"
        kicker: "01"

        ColumnLayout {
            anchors.fill: parent
            anchors.margins: 12
            spacing: 8

            RowLayout {
                Layout.fillWidth: true
                SeverityTag { text: "CRIT"; severity: "crit" }
                SeverityTag { text: "WARN"; severity: "warn" }
                SeverityTag { text: "INFO"; severity: "info" }
                SeverityTag { text: "OK"; severity: "ok" }
                Item { Layout.fillWidth: true }
                Button { text: "Export CSV" }
                Button { text: "Export JSONL" }
            }

            Rectangle {
                Layout.fillWidth: true
                Layout.fillHeight: true
                color: ChronosTokens.terminalBackground
                border.color: ChronosTokens.panelBorderDim
                radius: ChronosTokens.radiusSmall

                ListView {
                    id: auditList
                    anchors.fill: parent
                    anchors.margins: 8
                    clip: true
                    model: root.store ? root.store.auditEvents : []
                    delegate: AuditLine {
                        width: auditList.width
                        severity: modelData.severity
                        timestamp: modelData.ts
                        source: modelData.source
                        message: modelData.message
                    }
                    onCountChanged: positionViewAtEnd()
                }
            }
        }
    }
}
