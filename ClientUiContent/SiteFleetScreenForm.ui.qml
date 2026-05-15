import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root
    property var store
    property var gateway
    property var toast

    property var visibleSites: []
    property var selectedSite: visibleSites.length > 0 ? visibleSites[0] : null
    property string pendingCorrelationId: ""
    property string pendingSiteId: ""
    property int pendingMinute: -1
    property string commandState: "ready"

    function updateFiltered() {
        visibleSites = store ? store.filteredSites(searchField.text, regionFilter.currentText, stateFilter.currentText) : []
        if (!selectedSite && visibleSites.length > 0) selectedSite = visibleSites[0]
    }

    function sendWriteCommand() {
        if (!selectedSite || !gateway) return
        commandState = "busy"
        pendingSiteId = selectedSite.siteId
        pendingMinute = Math.round(minuteSlider.value)
        pendingCorrelationId = gateway.sendCommand(selectedSite.deviceId, "write_register", selectedSite.unitId, selectedSite.backendAddress, pendingMinute, "uint16")
        if (store) store.appendAudit("info", "ui", pendingSiteId + " write requested HR40001 value=" + pendingMinute)
    }

    Component.onCompleted: updateFiltered()

    Connections {
        target: root.store
        function onSitesChanged() { root.updateFiltered() }
    }

    Connections {
        target: root.gateway
        function onCommandResult(correlationId, success, status, error) {
            if (correlationId !== root.pendingCorrelationId) return

            if (status === "accepted") {
                root.commandState = "busy"
                if (root.toast) root.toast.show("Command accepted. Waiting for read-back.", "info")
                return
            }

            if (success && status === "confirmed") {
                root.commandState = "success"
                if (root.store) root.store.applyWriteResult(root.pendingSiteId, root.pendingMinute)
                if (root.toast) root.toast.show("Write confirmed by read-back", "ok")
                root.pendingCorrelationId = ""
                root.updateFiltered()
                return
            }

            root.commandState = "error"
            if (root.store) root.store.appendAudit("crit", "gateway", root.pendingSiteId + " command failed status=" + status + " error=" + error)
            if (root.toast) root.toast.show("Command failed: " + (error.length > 0 ? error : status), "crit")
            root.pendingCorrelationId = ""
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 14
        spacing: 12

        ChronosPanel {
            title: "SITE FLEET - 128 PLCS / MODBUS TCP"
            kicker: "01"
            Layout.fillWidth: true
            Layout.fillHeight: true
            Layout.preferredWidth: 980

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 12
                spacing: 8

                RowLayout {
                    Layout.fillWidth: true
                    spacing: 8

                    TextField {
                        id: searchField
                        placeholderText: "search id / host"
                        Layout.preferredWidth: 220
                        onTextChanged: root.updateFiltered()
                    }

                    ComboBox {
                        id: regionFilter
                        model: ["all regions", "North", "South", "East", "West", "Central"]
                        Layout.preferredWidth: 160
                        onCurrentTextChanged: root.updateFiltered()
                    }

                    ComboBox {
                        id: stateFilter
                        model: ["all states", "drift != 0", "offline", "low RSRP"]
                        Layout.preferredWidth: 160
                        onCurrentTextChanged: root.updateFiltered()
                    }

                    Item { Layout.fillWidth: true }

                    SeverityTag { text: visibleSites.length + " MATCH"; severity: "info" }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 32
                    color: ChronosTokens.panelDark
                    border.color: ChronosTokens.panelBorderDim

                    RowLayout {
                        anchors.fill: parent
                        anchors.leftMargin: 40
                        anchors.rightMargin: 12
                        spacing: 10
                        Text { text: "SITE"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 130 }
                        Text { text: "REGION"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 70 }
                        Text { text: "HOST:PORT/U"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 150 }
                        Text { text: "HR40001"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 64 }
                        Text { text: "DRIFT"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 54 }
                        Text { text: "4G"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 104 }
                        Text { text: "SINR"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 58 }
                        Text { text: "LINK"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 1.4; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 92 }
                    }
                }

                ListView {
                    id: siteList
                    Layout.fillWidth: true
                    Layout.fillHeight: true
                    clip: true
                    model: root.visibleSites
                    delegate: SiteRow {
                        width: siteList.width
                        siteId: modelData.siteId
                        siteName: modelData.name
                        region: modelData.region
                        deviceId: modelData.deviceId
                        host: modelData.host
                        unitId: modelData.unitId
                        plcMinute: modelData.plcMinute
                        refMinute: modelData.refMinute
                        driftMin: modelData.driftMin
                        bars: modelData.bars
                        rsrp: modelData.rsrp
                        sinr: modelData.sinr
                        rttMs: modelData.rttMs
                        link: modelData.link
                        health: modelData.health
                        selected: root.selectedSite && root.selectedSite.siteId === modelData.siteId
                        onClicked: root.selectedSite = modelData
                    }
                }
            }
        }

        ChronosPanel {
            title: selectedSite ? "SET PLC TIME - " + selectedSite.siteId : "SET PLC TIME"
            kicker: "02"
            Layout.preferredWidth: 430
            Layout.fillHeight: true

            ColumnLayout {
                anchors.fill: parent
                anchors.margins: 16
                spacing: 14

                Item {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    visible: root.selectedSite !== null
                    RowLayout {
                        anchors.fill: parent
                        spacing: 12
                        MinuteDial { plcMinute: root.selectedSite ? root.selectedSite.plcMinute : 0; refMinute: root.selectedSite ? root.selectedSite.refMinute : 0; dialSize: 116 }
                        ColumnLayout {
                            Layout.fillWidth: true
                            Text { text: root.selectedSite ? root.selectedSite.name : "No site selected"; color: ChronosTokens.foreground; font.pixelSize: 15; font.bold: true; font.family: ChronosTokens.monoFont; elide: Text.ElideRight; Layout.fillWidth: true }
                            SeverityTag { text: root.selectedSite ? root.selectedSite.link : "N/A"; severity: root.selectedSite ? root.selectedSite.health : "info" }
                            Text { text: root.selectedSite ? "endpoint " + root.selectedSite.host + ":" + root.selectedSite.port : ""; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont; elide: Text.ElideRight; Layout.fillWidth: true }
                            Text { text: root.selectedSite ? "device " + root.selectedSite.deviceId + "  unit " + root.selectedSite.unitId : ""; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
                        }
                    }
                }

                GridLayout {
                    Layout.fillWidth: true
                    columns: 2
                    rowSpacing: 8
                    columnSpacing: 14
                    visible: root.selectedSite !== null

                    Text { text: "Register"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
                    Text { text: root.selectedSite ? "HR" + root.selectedSite.humanRegister + " -> address " + root.selectedSite.backendAddress : ""; color: ChronosTokens.foreground; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
                    Text { text: "PLC minute"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
                    Text { text: root.selectedSite ? ":" + String(root.selectedSite.plcMinute).padStart(2, "0") : "--"; color: ChronosTokens.info; font.pixelSize: 22; font.bold: true; font.family: ChronosTokens.monoFont }
                    Text { text: "UTC minute"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
                    Text { text: root.selectedSite ? ":" + String(root.selectedSite.refMinute).padStart(2, "0") : "--"; color: ChronosTokens.ok; font.pixelSize: 22; font.bold: true; font.family: ChronosTokens.monoFont }
                    Text { text: "Drift"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
                    Text { text: root.selectedSite ? (root.selectedSite.driftMin > 0 ? "+" : "") + root.selectedSite.driftMin + " min" : "--"; color: root.selectedSite && root.selectedSite.health === "crit" ? ChronosTokens.crit : root.selectedSite && root.selectedSite.health === "warn" ? ChronosTokens.warn : ChronosTokens.ok; font.pixelSize: 22; font.bold: true; font.family: ChronosTokens.monoFont }
                }

                Rectangle {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 120
                    color: ChronosTokens.panelDark
                    border.color: ChronosTokens.panelBorderDim
                    radius: ChronosTokens.radiusSmall

                    ColumnLayout {
                        anchors.fill: parent
                        anchors.margins: 12
                        Text { text: "WRITE VALUE 00..59"; color: ChronosTokens.faintText; font.pixelSize: 10; font.letterSpacing: 2; font.family: ChronosTokens.monoFont }
                        Slider { id: minuteSlider; from: 0; to: 59; stepSize: 1; value: root.selectedSite ? root.selectedSite.refMinute : 0; Layout.fillWidth: true }
                        Text { text: ":" + String(Math.round(minuteSlider.value)).padStart(2, "0"); color: ChronosTokens.info; font.pixelSize: 30; font.bold: true; font.family: ChronosTokens.monoFont; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                TextArea {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    readOnly: true
                    wrapMode: TextArea.NoWrap
                    text: root.selectedSite ? "> write_register\n  device_id=" + root.selectedSite.deviceId + "\n  unit_id=" + root.selectedSite.unitId + "\n  address=" + root.selectedSite.backendAddress + " // HR40001\n  value=" + Math.round(minuteSlider.value) + "\n  data_type=uint16" : "select a site"
                    font.family: ChronosTokens.monoFont
                    font.pixelSize: 11
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "Sync to UTC"; enabled: root.selectedSite !== null && root.commandState !== "busy"; onClicked: minuteSlider.value = root.selectedSite.refMinute }
                    Item { Layout.fillWidth: true }
                    Button { text: root.commandState === "busy" ? "Writing / verifying..." : "Write + Verify"; enabled: root.selectedSite !== null && root.commandState !== "busy"; highlighted: true; onClicked: confirmDialog.open() }
                }
            }
        }
    }

    Dialog {
        id: confirmDialog
        modal: true
        title: "Confirm Modbus write"
        standardButtons: Dialog.Ok | Dialog.Cancel

        contentItem: Text {
            width: 420
            text: root.selectedSite ? "Write HR40001 value :" + String(Math.round(minuteSlider.value)).padStart(2, "0") + " to " + root.selectedSite.siteId + "?\n\nThe UI should show success only after the backend returns confirmed read-back." : "No site selected."
            color: ChronosTokens.foreground
            wrapMode: Text.WordWrap
            font.family: ChronosTokens.monoFont
        }

        onAccepted: root.sendWriteCommand()
    }
}
