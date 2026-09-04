import QtQuick
import qs.Config

Canvas {
    id: root

    property var values: []
    property color accent: Theme.primary
    property real maximum: 100
    property bool filled: true

    implicitHeight: 32
    onValuesChanged: requestPaint()
    onAccentChanged: requestPaint()

    onPaint: {
        const ctx = getContext("2d");
        ctx.reset();

        const points = values ?? [];
        if (points.length < 2)
            return;

        const top = maximum > 0 ? maximum : Math.max(1, Math.max(...points));
        const stepX = width / (points.length - 1);
        const toY = v => height - Math.max(0, Math.min(1, v / top)) * height;

        ctx.beginPath();
        ctx.moveTo(0, toY(points[0]));
        for (let i = 1; i < points.length; i++)
            ctx.lineTo(i * stepX, toY(points[i]));

        if (filled) {
            ctx.save();
            ctx.lineTo(width, height);
            ctx.lineTo(0, height);
            ctx.closePath();
            ctx.fillStyle = Qt.rgba(accent.r, accent.g, accent.b, 0.15);
            ctx.fill();
            ctx.restore();
        }

        ctx.strokeStyle = accent;
        ctx.lineWidth = 1.5;
        ctx.stroke();
    }
}
