import QtQuick
import "."

Canvas {
    id: root
    property int plcMinute: 0
    property int refMinute: 0
    property int dialSize: 112
    width: dialSize
    height: dialSize

    function normalizedDrift() {
        return ((plcMinute - refMinute + 30 + 60) % 60) - 30
    }

    function severityColor() {
        var d = Math.abs(normalizedDrift())
        if (d >= 5) return ChronosTokens.crit
        if (d >= 1) return ChronosTokens.warn
        return ChronosTokens.ok
    }

    function drawHand(ctx, minute, length, color, lineWidth) {
        var cx = width / 2
        var cy = height / 2
        var a = minute / 60 * Math.PI * 2 - Math.PI / 2
        ctx.strokeStyle = color
        ctx.lineWidth = lineWidth
        ctx.beginPath()
        ctx.moveTo(cx, cy)
        ctx.lineTo(cx + Math.cos(a) * length, cy + Math.sin(a) * length)
        ctx.stroke()
    }

    onPaint: {
        var ctx = getContext("2d")
        ctx.reset()
        var cx = width / 2
        var cy = height / 2
        var r = Math.min(width, height) / 2 - 10

        ctx.strokeStyle = ChronosTokens.panelBorder
        ctx.lineWidth = 1
        ctx.beginPath()
        ctx.arc(cx, cy, r, 0, Math.PI * 2)
        ctx.stroke()

        for (var i = 0; i < 60; i++) {
            var a = i / 60 * Math.PI * 2 - Math.PI / 2
            var inner = i % 5 === 0 ? r - 8 : r - 3
            ctx.strokeStyle = i % 5 === 0 ? ChronosTokens.mutedText : ChronosTokens.panelBorder
            ctx.globalAlpha = i % 5 === 0 ? 0.70 : 0.45
            ctx.lineWidth = i % 5 === 0 ? 1.2 : 0.8
            ctx.beginPath()
            ctx.moveTo(cx + Math.cos(a) * inner, cy + Math.sin(a) * inner)
            ctx.lineTo(cx + Math.cos(a) * r, cy + Math.sin(a) * r)
            ctx.stroke()
        }

        ctx.globalAlpha = 1.0
        drawHand(ctx, refMinute, r - 16, ChronosTokens.info, 2)
        drawHand(ctx, plcMinute, r - 8, severityColor(), 3)

        ctx.fillStyle = severityColor()
        ctx.beginPath()
        ctx.arc(cx, cy, 3.5, 0, Math.PI * 2)
        ctx.fill()
    }

    onPlcMinuteChanged: requestPaint()
    onRefMinuteChanged: requestPaint()
    Component.onCompleted: requestPaint()
}
