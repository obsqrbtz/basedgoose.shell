import QtQuick
import "../Commons" as Commons

Canvas {
    id: graph

    // Primary data series
    property var data: []
    // Optional second series drawn on the same scale (e.g. TX overlaid on RX)
    property var data2: []
    // 0 = auto-scale from data; positive value fixes the max (e.g. 100 for %)
    property real maxValue: 0

    property color lineColor: Commons.Theme.primary
    property color fillColor: Qt.rgba(Commons.Theme.primary.r, Commons.Theme.primary.g, Commons.Theme.primary.b, 0.12)
    property color lineColor2: Commons.Theme.secondary
    property color fillColor2: Qt.rgba(Commons.Theme.secondary.r, Commons.Theme.secondary.g, Commons.Theme.secondary.b, 0.08)
    property real lineWidth: 1.5

    onDataChanged: requestPaint()
    onData2Changed: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()

    onPaint: {
        var ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        if (!data || data.length < 2) return

        var max = maxValue > 0 ? maxValue : 0
        if (max === 0) {
            for (var k = 0; k < data.length; k++)
                if (data[k] > max) max = data[k]
            if (data2) {
                for (var m = 0; m < data2.length; m++)
                    if (data2[m] > max) max = data2[m]
            }
        }
        if (max === 0) max = 1

        function yFor(v) {
            return height - 2 - Math.max(0, (v / max) * (height - 4))
        }

        function drawSeries(arr, lColor, fColor) {
            if (!arr || arr.length < 2) return
            var n = arr.length
            var step = width / (n - 1)

            ctx.beginPath()
            ctx.moveTo(0, height)
            ctx.lineTo(0, yFor(arr[0]))
            for (var i = 1; i < n; i++)
                ctx.lineTo(i * step, yFor(arr[i]))
            ctx.lineTo((n - 1) * step, height)
            ctx.closePath()
            ctx.fillStyle = fColor
            ctx.fill()

            ctx.beginPath()
            ctx.moveTo(0, yFor(arr[0]))
            for (var j = 1; j < n; j++)
                ctx.lineTo(j * step, yFor(arr[j]))
            ctx.strokeStyle = lColor
            ctx.lineWidth = lineWidth
            ctx.lineJoin = "round"
            ctx.stroke()
        }

        if (data2 && data2.length >= 2)
            drawSeries(data2, lineColor2, fillColor2)
        drawSeries(data, lineColor, fillColor)
    }
}
