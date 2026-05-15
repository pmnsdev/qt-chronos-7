import QtQuick
import "."

Item {
    id: root
    property string severity: "ok"
    property string label: ""
    property bool blinkOnCritical: true

    implicitWidth: labelItem.visible ? led.width + 8 + labelItem.implicitWidth : led.width
    implicitHeight: 20

    readonly property color ledColor: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : severity === "info" ? ChronosTokens.info : ChronosTokens.ok

    Row {
        anchors.verticalCenter: parent.verticalCenter
        spacing: 8

        Rectangle {
            id: led
            width: 9
            height: 9
            radius: 5
            color: root.ledColor
            opacity: root.severity === "crit" && root.blinkOnCritical ? 1.0 : 0.9

            SequentialAnimation on opacity {
                running: root.severity === "crit" && root.blinkOnCritical
                loops: Animation.Infinite
                NumberAnimation { to: 0.35; duration: 500 }
                NumberAnimation { to: 1.0; duration: 500 }
            }
        }

        Text {
            id: labelItem
            visible: root.label.length > 0
            text: root.label
            color: ChronosTokens.mutedText
            font.pixelSize: 11
            font.family: ChronosTokens.monoFont
        }
    }
}
