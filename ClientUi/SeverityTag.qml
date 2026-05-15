import QtQuick
import "."

Rectangle {
    id: root
    property string text: "ONLINE"
    property string severity: "info"
    property int horizontalPadding: 8

    readonly property color tagColor: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : severity === "ok" ? ChronosTokens.ok : ChronosTokens.info

    implicitWidth: label.implicitWidth + horizontalPadding * 2
    implicitHeight: 22
    radius: ChronosTokens.radiusSmall
    border.width: 1
    border.color: tagColor
    color: Qt.rgba(tagColor.r, tagColor.g, tagColor.b, 0.12)

    Text {
        id: label
        anchors.centerIn: parent
        text: root.text
        color: root.tagColor
        font.pixelSize: 10
        font.bold: true
        font.family: ChronosTokens.monoFont
    }
}
