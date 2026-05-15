import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Item {
    id: root

    property alias searchFieldText: searchField.text
    property alias regionFilterCurrentText: regionFilter.currentText
    property alias stateFilterCurrentText: stateFilter.currentText
    property alias minuteSliderValue: minuteSlider.value
    property alias confirmDialog: confirmDialog

    property var store
    property var gateway
    property var toast

    property var visibleSites: []
    property var selectedSite: visibleSites.length > 0 ? visibleSites[0] : null
    property string pendingCorrelationId: ""
    property string pendingSiteId: ""
    property int pendingMinute: -1
    property string commandState: "ready"

    property int minuteSliderValueRounded: minuteSlider.value
    property string minuteSliderText: ""
    property string writeCommandText: ""
    property string confirmDialogText: ""

    signal updateFilteredSignal()
    signal sendWriteCommandSignal()
    signal syncToUtcClicked()
    signal writeAndVerifyClicked()


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

                    }

                    ComboBox {
                        id: regionFilter
                        model: ["all regions", "North", "South", "East", "West", "Central"]
                        Layout.preferredWidth: 160

                    }

                    ComboBox {
                        id: stateFilter
                        model: ["all states", "drift != 0", "offline", "low RSRP"]
                        Layout.preferredWidth: 160

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
                    Text { text: root.selectedSite ? ":" + root.selectedSite.plcMinuteText : "--"; color: ChronosTokens.info; font.pixelSize: 22; font.bold: true; font.family: ChronosTokens.monoFont }
                    Text { text: "UTC minute"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
                    Text { text: root.selectedSite ? ":" + root.selectedSite.refMinuteText : "--"; color: ChronosTokens.ok; font.pixelSize: 22; font.bold: true; font.family: ChronosTokens.monoFont }
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
                        Text { text: root.minuteSliderText; color: ChronosTokens.info; font.pixelSize: 30; font.bold: true; font.family: ChronosTokens.monoFont; Layout.alignment: Qt.AlignHCenter }
                    }
                }

                TextArea {
                    Layout.fillWidth: true
                    Layout.preferredHeight: 112
                    readOnly: true
                    wrapMode: TextArea.NoWrap
                    text: root.writeCommandText
                    font.family: ChronosTokens.monoFont
                    font.pixelSize: 11
                }

                Item { Layout.fillHeight: true }

                RowLayout {
                    Layout.fillWidth: true
                    Button { text: "Sync to UTC"; enabled: root.selectedSite !== null && root.commandState !== "busy"; onClicked: root.syncToUtcClicked() }
                    Item { Layout.fillWidth: true }
                    Button { text: root.commandState === "busy" ? "Writing / verifying..." : "Write + Verify"; enabled: root.selectedSite !== null && root.commandState !== "busy"; highlighted: true; onClicked: root.writeAndVerifyClicked() }
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
            text: root.confirmDialogText
            color: ChronosTokens.foreground
            wrapMode: Text.WordWrap
            font.family: ChronosTokens.monoFont
        }

        onAccepted: root.sendWriteCommandSignal()
    }
}
