import QtQuick
import "."

Row {
    id: root
    property int bars: 0
    spacing: 2
    height: 18

    readonly property string severity: bars >= 4 ? "ok" : bars >= 2 ? "warn" : "crit"
    readonly property color barColor: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : ChronosTokens.ok

    Repeater {
        model: 5
        Rectangle {
            width: 4
            height: 5 + index * 3
            anchors.bottom: parent.bottom
            radius: 1
            color: index < root.bars ? root.barColor : ChronosTokens.panelBorder
            opacity: index < root.bars ? 1.0 : 0.4
        }
    }
}
