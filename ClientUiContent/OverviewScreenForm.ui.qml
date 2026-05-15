import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root
    property var store

    ScrollView {
        anchors.fill: parent
        clip: true

        GridLayout {
            x: 14
            y: 14
            width: Math.max(parent.width - 28, 1180)
            height: 1160
            columns: 12
            rowSpacing: 12
            columnSpacing: 12

            ChronosPanel {
                title: "FLEET MINUTE DRIFT - PLC HR40001 VS UTC"
                kicker: "01"
                Layout.columnSpan: 8
                Layout.fillWidth: true
                Layout.preferredHeight: 310

                DriftHistogram {
                    anchors.fill: parent
                    anchors.margins: 12
                    values: root.store ? root.store.driftValues() : []
                }
            }

            ChronosPanel {
                title: "FLEET STATUS"
                kicker: "02"
                Layout.columnSpan: 4
                Layout.fillWidth: true
                Layout.preferredHeight: 310

                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 14
                    spacing: 12

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        FleetStatusCard { label: "HEALTHY"; value: String(root.store ? root.store.countHealth("ok") : 0); severity: "ok"; Layout.fillWidth: true }
                        FleetStatusCard { label: "WARN"; value: String(root.store ? root.store.countHealth("warn") : 0); severity: "warn"; Layout.fillWidth: true }
                    }

                    RowLayout {
                        Layout.fillWidth: true
                        spacing: 10
                        FleetStatusCard { label: "CRITICAL"; value: String(root.store ? root.store.countHealth("crit") : 0); severity: "crit"; Layout.fillWidth: true }
                        FleetStatusCard { label: "ONLINE"; value: String(root.store ? root.store.countOnline() : 0); severity: "info"; Layout.fillWidth: true }
                    }

                    Rectangle {
                        Layout.fillWidth: true
                        Layout.fillHeight: true
                        color: ChronosTokens.panelDark
                        border.color: ChronosTokens.panelBorderDim
                        radius: ChronosTokens.radiusSmall

                        ColumnLayout {
                            anchors.fill: parent
                            anchors.margins: 12
                            Text { text: "REFERENCE UTC MINUTE"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 2; font.family: ChronosTokens.monoFont }
                            Text { text: ":" + String(root.store ? root.store.referenceMinute : 0).padStart(2, "0"); color: ChronosTokens.info; font.pixelSize: 42; font.bold: true; font.family: ChronosTokens.monoFont }
                            Text { text: "Smallest writable unit: one minute, value 0..59"; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont; wrapMode: Text.WordWrap; Layout.fillWidth: true }
                        }
                    }
                }
            }

            ChronosPanel {
                title: "WORST OFFENDERS - MINUTE DIALS"
                kicker: "03"
                Layout.columnSpan: 12
                Layout.fillWidth: true
                Layout.preferredHeight: 420

                // Responsive fix:
                // The original 3-column grid could compress each offender card until
                // only the dial was visible and the text clipped outside the card.
                // This ScrollView + adaptive column count keeps each card wide enough
                // for the dial, site name, PLC/UTC line, drift, and status tag.
                ScrollView {
                    id: worstScroll
                    anchors.fill: parent
                    anchors.margins: 14
                    clip: true
                    ScrollBar.horizontal.policy: ScrollBar.AlwaysOff
                    ScrollBar.vertical.policy: ScrollBar.AsNeeded

                    GridLayout {
                        id: worstGrid
                        width: Math.max(worstScroll.width - 8, 260)
                        columns: width >= 860 ? 3 : width >= 580 ? 2 : 1
                        rowSpacing: 10
                        columnSpacing: 10

                        Repeater {
                            model: root.store ? root.store.worstSites(6, root.store.revision) : []
                            Rectangle {
                                Layout.fillWidth: true
                                Layout.minimumWidth: 260
                                Layout.preferredHeight: 150
                                color: ChronosTokens.panelDark
                                border.color: ChronosTokens.panelBorderDim
                                radius: ChronosTokens.radiusSmall
                                clip: true

                                RowLayout {
                                    anchors.fill: parent
                                    anchors.margins: 10
                                    spacing: 10

                                    MinuteDial {
                                        plcMinute: modelData.plcMinute
                                        refMinute: modelData.refMinute
                                        dialSize: 82
                                        Layout.preferredWidth: 82
                                        Layout.preferredHeight: 82
                                        Layout.alignment: Qt.AlignVCenter
                                    }

                                    ColumnLayout {
                                        Layout.fillWidth: true
                                        Layout.minimumWidth: 0
                                        spacing: 3

                                        Text {
                                            text: modelData.siteId
                                            color: ChronosTokens.foreground
                                            font.pixelSize: 13
                                            font.bold: true
                                            font.family: ChronosTokens.monoFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: modelData.name
                                            color: ChronosTokens.mutedText
                                            font.pixelSize: 10
                                            font.family: ChronosTokens.monoFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: "PLC :" + String(modelData.plcMinute).padStart(2, "0") + " / UTC :" + String(modelData.refMinute).padStart(2, "0")
                                            color: ChronosTokens.info
                                            font.pixelSize: 11
                                            font.family: ChronosTokens.monoFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        Text {
                                            text: "DRIFT " + (modelData.driftMin > 0 ? "+" : "") + modelData.driftMin + " min"
                                            color: modelData.health === "crit" ? ChronosTokens.crit : modelData.health === "warn" ? ChronosTokens.warn : ChronosTokens.ok
                                            font.pixelSize: 13
                                            font.bold: true
                                            font.family: ChronosTokens.monoFont
                                            elide: Text.ElideRight
                                            Layout.fillWidth: true
                                        }
                                        SeverityTag {
                                            text: modelData.link
                                            severity: modelData.health
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            }

            ChronosPanel {
                title: "GATEWAYS AND MODBUS BROKERS"
                kicker: "04"
                Layout.columnSpan: 12
                Layout.fillWidth: true
                Layout.preferredHeight: 310

                ListView {
                    anchors.fill: parent
                    anchors.margins: 12
                    clip: true
                    spacing: 8
                    model: root.store ? root.store.gateways : []
                    delegate: GatewayStatusCard {
                        width: ListView.view.width
                        gatewayId: modelData.id
                        role: modelData.role
                        state: modelData.state
                        utcSrc: modelData.utcSrc
                        sites: modelData.sites
                        health: modelData.health
                    }
                }
            }
        }
    }
}
