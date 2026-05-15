import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string label: "HEALTHY"
    property string value: "0"
    property string severity: "ok"

    readonly property color cardColor: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : severity === "info" ? ChronosTokens.info : ChronosTokens.ok

    implicitWidth: 160
    implicitHeight: 86
    color: Qt.rgba(cardColor.r, cardColor.g, cardColor.b, 0.08)
    border.color: Qt.rgba(cardColor.r, cardColor.g, cardColor.b, 0.45)
    radius: ChronosTokens.radiusSmall

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4

        RowLayout {
            Layout.fillWidth: true
            StatusLed { severity: root.severity; blinkOnCritical: false }
            Text {
                text: root.label
                color: ChronosTokens.mutedText
                font.pixelSize: 10
                font.letterSpacing: 1.5
                font.family: ChronosTokens.monoFont
                Layout.fillWidth: true
            }
        }

        Text {
            text: root.value
            color: root.cardColor
            font.pixelSize: 28
            font.bold: true
            font.family: ChronosTokens.monoFont
            Layout.alignment: Qt.AlignLeft
        }
    }
}
