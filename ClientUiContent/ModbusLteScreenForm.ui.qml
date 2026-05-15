import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root
    property var store

    GridLayout {
        anchors.fill: parent
        anchors.margins: 14
        columns: 12
        rowSpacing: 12
        columnSpacing: 12

        ChronosPanel {
            title: "MODBUS TCP - DIRECT MASTER PARAMETERS"
            kicker: "01"
            Layout.columnSpan: 7
            Layout.fillWidth: true
            Layout.preferredHeight: 360

            GridLayout {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                columnSpacing: 32
                rowSpacing: 12

                Repeater {
                    model: [
                        { k: "transport", v: "Modbus/TCP" },
                        { k: "server port", v: "502 / TCP" },
                        { k: "write function", v: "0x06 Write Single Register" },
                        { k: "read function", v: "0x03 Read Holding Register" },
                        { k: "human register", v: "HR40001" },
                        { k: "backend address", v: "1 (worker adjusts to offset 0)" },
                        { k: "payload range", v: "0..59 minute" },
                        { k: "data type", v: "uint16" },
                        { k: "gateway result", v: "accepted -> confirmed / timeout" },
                        { k: "read-back", v: "required before UI success" }
                    ]
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.k.toUpperCase(); color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.6; font.family: ChronosTokens.monoFont }
                        Text { text: modelData.v; color: ChronosTokens.foreground; font.pixelSize: 13; font.bold: true; font.family: ChronosTokens.monoFont; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Rectangle { Layout.fillWidth: true; height: 1; color: ChronosTokens.panelBorderDim }
                    }
                }
            }
        }

        ChronosPanel {
            title: "4G / LTE NETWORK"
            kicker: "02"
            Layout.columnSpan: 5
            Layout.fillWidth: true
            Layout.preferredHeight: 360

            GridLayout {
                anchors.fill: parent
                anchors.margins: 16
                columns: 2
                columnSpacing: 28
                rowSpacing: 12

                Repeater {
                    model: [
                        { k: "bearer", v: "LTE Cat-1 / Cat-M1" },
                        { k: "default APN", v: "scada.iot" },
                        { k: "VPN", v: "IPsec to GW-A" },
                        { k: "RSRP warn/crit", v: "-110 / -116 dBm" },
                        { k: "SINR warn/crit", v: "0 / -3 dB" },
                        { k: "keepalive", v: "UDP/4500 every 30s" },
                        { k: "PDP flap warn", v: "3 / 10 min" },
                        { k: "RTT model", v: "80..560 ms typical" }
                    ]
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text { text: modelData.k.toUpperCase(); color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.6; font.family: ChronosTokens.monoFont }
                        Text { text: modelData.v; color: ChronosTokens.foreground; font.pixelSize: 13; font.bold: true; font.family: ChronosTokens.monoFont; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        Rectangle { Layout.fillWidth: true; height: 1; color: ChronosTokens.panelBorderDim }
                    }
                }
            }
        }

        ChronosPanel {
            title: "SCHEDULER - TIME PUSH PIPELINE"
            kicker: "03"
            Layout.columnSpan: 12
            Layout.fillWidth: true
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 10

                Repeater {
                    model: [
                        { step: "T+0", title: "Broadcast set minute", detail: "write_register HR40001 <- UTC.minute", severity: "ok", state: "ARMED" },
                        { step: "T+30", title: "Verify read", detail: "read_register HR40001 and compare", severity: "ok", state: "ARMED" },
                        { step: "T+45", title: "Retry stragglers", detail: "retry failed sites with backoff", severity: "info", state: "IDLE" },
                        { step: "T+55", title: "Alarm rollup", detail: "raise MINUTE-DRIFT for abs(drift) >= 5", severity: "warn", state: "ARMED" }
                    ]
                    Rectangle {
                        Layout.fillWidth: true
                        Layout.preferredHeight: 72
                        color: ChronosTokens.panelDark
                        border.color: ChronosTokens.panelBorderDim
                        radius: ChronosTokens.radiusSmall

                        RowLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            spacing: 14
                            Text { text: modelData.step; color: ChronosTokens.info; font.pixelSize: 18; font.bold: true; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 72 }
                            StatusLed { severity: modelData.severity }
                            ColumnLayout {
                                Layout.fillWidth: true
                                Text {
                                    text: modelData.title
                                    color: ChronosTokens.foreground
                                    font.pixelSize: 14
                                    font.bold: true
                                    font.family: ChronosTokens.monoFont
                                }
                                Text {
                                    text: modelData.detail
                                    color: ChronosTokens.mutedText
                                    font.pixelSize: 11
                                    font.family: ChronosTokens.monoFont
                                }
                            }
                            SeverityTag { text: modelData.state; severity: modelData.severity }
                        }
                    }
                }
            }
        }
    }
}
