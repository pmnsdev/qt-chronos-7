import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root
    property var store

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ChronosPanel {
            title: "ACTIVE ALARMS"
            kicker: "01"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 940

            ListView {
                id: alarmList
                anchors.fill: parent
                anchors.margins: 10
                clip: true
                spacing: 0
                model: root.store ? root.store.alarms : []
                delegate: AlarmRow {
                    width: alarmList.width
                    severity: modelData.severity
                    timestamp: modelData.ts
                    code: modelData.code
                    source: modelData.source
                    message: modelData.message
                }
            }
        }

        ChronosPanel {
            title: "THRESHOLD POLICY"
            kicker: "02"
            Layout.preferredWidth: 450
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 14
                spacing: 8

                Repeater {
                    model: [
                        { metric: "Minute drift", warn: "+/-1 min", crit: "+/-5 min" },
                        { metric: "Modbus write fail", warn: "1 attempt", crit: "3 attempts" },
                        { metric: "Modbus exception", warn: "any", crit: "0x0B gateway" },
                        { metric: "RSRP", warn: "-110 dBm", crit: "-116 dBm" },
                        { metric: "SINR", warn: "0 dB", crit: "-3 dB" },
                        { metric: "PDP flap", warn: "3 / 10 min", crit: "10 / 10 min" },
                        { metric: "Verify mismatch", warn: "1 cycle", crit: "3 cycles" }
                    ]
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 64
                        color: ChronosTokens.panelDark
                        border.color: ChronosTokens.panelBorderDim
                        radius: ChronosTokens.radiusSmall

                        GridLayout {
                            anchors.fill: parent
                            anchors.margins: 10
                            columns: 3
                            Text { text: modelData.metric; color: ChronosTokens.foreground; font.pixelSize: 12; font.bold: true; font.family: ChronosTokens.monoFont; Layout.fillWidth: true }
                            Text { text: modelData.warn; color: ChronosTokens.warn; font.pixelSize: 11; font.family: ChronosTokens.monoFont; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 94 }
                            Text { text: modelData.crit; color: ChronosTokens.crit; font.pixelSize: 11; font.family: ChronosTokens.monoFont; horizontalAlignment: Text.AlignRight; Layout.preferredWidth: 94 }
                            Text { text: "raise alarm when threshold is crossed"; color: ChronosTokens.faintText; font.pixelSize: 9; font.family: ChronosTokens.monoFont; Layout.columnSpan: 3 }
                        }
                    }
                }
            }
        }
    }
}
