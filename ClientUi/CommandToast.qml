import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string message: ""
    property string severity: "info"
    property bool shown: false

    width: Math.min(560, parent ? parent.width - 40 : 560)
    height: 48
    radius: ChronosTokens.radiusMedium
    color: ChronosTokens.panelDark
    border.color: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : severity === "ok" ? ChronosTokens.ok : ChronosTokens.info
    opacity: shown ? 1 : 0
    visible: opacity > 0

    Behavior on opacity { NumberAnimation { duration: 160 } }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 12
        StatusLed { severity: root.severity }
        Text { text: root.message; color: ChronosTokens.foreground; font.pixelSize: 12; font.family: ChronosTokens.monoFont; Layout.fillWidth: true; elide: Text.ElideRight }
    }

    Timer {
        id: hideTimer
        interval: 3600
        repeat: false
        onTriggered: root.shown = false
    }

    function show(text, sev) {
        message = text
        severity = sev || "info"
        shown = true
        hideTimer.restart()
    }
}
