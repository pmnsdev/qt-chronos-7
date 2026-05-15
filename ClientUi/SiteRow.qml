import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    signal clicked()

    property string siteId: "SITE-0001"
    property string siteName: "Pump"
    property string region: "North"
    property int deviceId: 1
    property string host: "10.0.0.1"
    property int unitId: 1
    property int plcMinute: 0
    property int refMinute: 0
    property int driftMin: 0
    property int bars: 0
    property int rsrp: -90
    property int sinr: 10
    property int rttMs: 100
    property string link: "ONLINE"
    property string health: "ok"
    property bool selected: false

    height: ChronosTokens.rowHeight
    color: selected ? ChronosTokens.panelActive : mouseArea.containsMouse ? ChronosTokens.panelHover : "transparent"
    border.color: ChronosTokens.panelBorderDim
    border.width: 0

    RowLayout {
        anchors.fill: parent
        anchors.leftMargin: 12
        anchors.rightMargin: 12
        spacing: 10

        StatusLed { severity: root.health; Layout.preferredWidth: 18 }

        ColumnLayout {
            Layout.preferredWidth: 130
            spacing: 0
            Text { text: root.siteId; color: ChronosTokens.foreground; font.pixelSize: 11; font.bold: true; font.family: ChronosTokens.monoFont }
            Text { text: root.siteName; color: ChronosTokens.mutedText; font.pixelSize: 9; font.family: ChronosTokens.monoFont; elide: Text.ElideRight; Layout.fillWidth: true }
        }

        Text { text: root.region; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 70 }
        Text { text: root.host + ":502/u" + root.unitId; color: ChronosTokens.foreground; font.pixelSize: 11; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 150; elide: Text.ElideRight }
        Text { text: ":" + String(root.plcMinute).padStart(2, "0"); color: ChronosTokens.info; font.pixelSize: 12; font.bold: true; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 64 }
        Text { text: (root.driftMin > 0 ? "+" : "") + root.driftMin; color: root.health === "crit" ? ChronosTokens.crit : root.health === "warn" ? ChronosTokens.warn : ChronosTokens.ok; font.pixelSize: 12; font.bold: true; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 54 }

        RowLayout {
            Layout.preferredWidth: 104
            spacing: 6
            SignalBars { bars: root.bars }
            Text { text: root.rsrp + " dBm"; color: ChronosTokens.mutedText; font.pixelSize: 10; font.family: ChronosTokens.monoFont }
        }

        Text { text: root.sinr + " dB"; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 58 }
        SeverityTag { text: root.link; severity: root.link === "OFFLINE" ? "crit" : root.link === "ONLINE" ? "ok" : "warn"; Layout.preferredWidth: 92 }
        Text { text: root.rttMs + " ms"; color: ChronosTokens.faintText; font.pixelSize: 10; font.family: ChronosTokens.monoFont; Layout.preferredWidth: 56 }
    }

    MouseArea {
        id: mouseArea
        anchors.fill: parent
        hoverEnabled: true
        onClicked: root.clicked()
    }

    Rectangle {
        anchors.bottom: parent.bottom
        width: parent.width
        height: 1
        color: ChronosTokens.panelBorderDim
    }
}
