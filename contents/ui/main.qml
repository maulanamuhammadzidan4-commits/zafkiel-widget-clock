import QtQuick
import QtQuick.Controls
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    width: 420
    height: 420

    property real secondsValue: 0
    property real minutesValue: 0
    property real hoursValue: 0

    Timer {
        interval: 250
        running: true
        repeat: true
        onTriggered: {
            var d = new Date()
            root.secondsValue = d.getSeconds() + d.getMilliseconds() / 1000
            root.minutesValue = d.getMinutes() + root.secondsValue / 60
            root.hoursValue = (d.getHours() % 12) + root.minutesValue / 60
        }
    }

    Canvas {
        id: dial
        anchors.fill: parent
        antialiasing: true

        onPaint: {
            var ctx = getContext("2d")
            ctx.reset()
            ctx.clearRect(0, 0, width, height)

            var s = Math.min(width, height)
            var cx = width / 2
            var cy = height / 2
            var r = s * 0.46

            function circle(radius, color, lineWidth) {
                ctx.beginPath()
                ctx.arc(cx, cy, radius, 0, Math.PI * 2)
                ctx.strokeStyle = color
                ctx.lineWidth = lineWidth
                ctx.stroke()
            }

            function line(x1, y1, x2, y2, color, lineWidth) {
                ctx.beginPath()
                ctx.moveTo(x1, y1)
                ctx.lineTo(x2, y2)
                ctx.strokeStyle = color
                ctx.lineWidth = lineWidth
                ctx.stroke()
            }

            function point(radius, angle) {
                return {
                    x: cx + Math.sin(angle) * radius,
                    y: cy - Math.cos(angle) * radius
                }
            }

            // Dial transparan dengan cincin hitam, merah, dan emas.
            circle(r, "#d5ad61", 2.2)
            circle(r - 5, "#74151d", 1.5)
            circle(r - 10, "#d5ad61", 0.8)
            circle(r * 0.79, "#74151d", 1.1)
            circle(r * 0.76, "#d5ad61", 0.7)
            circle(r * 0.48, "#74151d", 1.1)
            circle(r * 0.45, "#d5ad61", 0.8)

            // Ornamen geometris pada lingkaran luar.
            for (var j = 0; j < 12; j++) {
                var a = j * Math.PI / 6
                var p1 = point(r - 13, a)
                var p2 = point(r - 24, a + 0.035)
                var p3 = point(r - 35, a)
                var p4 = point(r - 24, a - 0.035)

                ctx.beginPath()
                ctx.moveTo(p1.x, p1.y)
                ctx.lineTo(p2.x, p2.y)
                ctx.lineTo(p3.x, p3.y)
                ctx.lineTo(p4.x, p4.y)
                ctx.closePath()
                ctx.strokeStyle = "#d5ad61"
                ctx.lineWidth = 1.1
                ctx.stroke()
            }

            // Enam puluh penanda menit.
            for (var i = 0; i < 60; i++) {
                var angle = i * Math.PI / 30
                var major = i % 5 === 0
                var inner = major ? r * 0.78 : r * 0.84
                var outer = r * 0.90
                var a1 = point(inner, angle)
                var a2 = point(outer, angle)

                line(
                    a1.x, a1.y, a2.x, a2.y,
                    major ? "#e2bd70" : "#9e4a42",
                    major ? 2.0 : 0.8
                )
            }

            // Ornamen radial di sekitar pusat.
            for (var k = 0; k < 24; k++) {
                var theta = k * Math.PI / 12
                var q1 = point(r * 0.43, theta)
                var q2 = point(r * 0.47, theta + 0.035)
                var q3 = point(r * 0.43, theta + 0.07)

                line(q1.x, q1.y, q2.x, q2.y, "#d5ad61", 0.8)
                line(q2.x, q2.y, q3.x, q3.y, "#d5ad61", 0.8)
            }

            // Jarum jam.
            ctx.save()
            ctx.translate(cx, cy)
            ctx.rotate(hoursValue * Math.PI / 6)
            ctx.beginPath()
            ctx.moveTo(0, r * 0.12)
            ctx.lineTo(-4.2, r * 0.06)
            ctx.lineTo(-2.8, -r * 0.43)
            ctx.lineTo(0, -r * 0.49)
            ctx.lineTo(2.8, -r * 0.43)
            ctx.lineTo(4.2, r * 0.06)
            ctx.closePath()
            ctx.fillStyle = "#d5ad61"
            ctx.fill()
            ctx.strokeStyle = "#74151d"
            ctx.lineWidth = 1
            ctx.stroke()
            ctx.restore()

            // Jarum menit.
            ctx.save()
            ctx.translate(cx, cy)
            ctx.rotate(minutesValue * Math.PI / 30)
            ctx.beginPath()
            ctx.moveTo(0, r * 0.12)
            ctx.lineTo(-2.8, r * 0.05)
            ctx.lineTo(-1.6, -r * 0.65)
            ctx.lineTo(0, -r * 0.73)
            ctx.lineTo(1.6, -r * 0.65)
            ctx.lineTo(2.8, r * 0.05)
            ctx.closePath()
            ctx.fillStyle = "#e5c780"
            ctx.fill()
            ctx.strokeStyle = "#74151d"
            ctx.lineWidth = 0.8
            ctx.stroke()
            ctx.restore()

            // Jarum detik merah.
            ctx.save()
            ctx.translate(cx, cy)
            ctx.rotate(secondsValue * Math.PI / 30)
            line(0, r * 0.17, 0, -r * 0.79, "#a51e2a", 1.5)
            ctx.beginPath()
            ctx.arc(0, -r * 0.72, 2.2, 0, Math.PI * 2)
            ctx.fillStyle = "#a51e2a"
            ctx.fill()
            ctx.restore()

            // Poros pusat berlapis.
            ctx.beginPath()
            ctx.arc(cx, cy, 8, 0, Math.PI * 2)
            ctx.fillStyle = "#74151d"
            ctx.fill()
            ctx.strokeStyle = "#e5c780"
            ctx.lineWidth = 2
            ctx.stroke()

            ctx.beginPath()
            ctx.arc(cx, cy, 2.5, 0, Math.PI * 2)
            ctx.fillStyle = "#f3d99a"
            ctx.fill()
        }

        Connections {
            target: root
            function onSecondsValueChanged() {
                dial.requestPaint()
            }
        }

        Component.onCompleted: requestPaint()
    }

    Repeater {
        model: 12

        delegate: Text {
            required property int index

            text: ["XII", "I", "II", "III", "IV", "V",
                   "VI", "VII", "VIII", "IX", "X", "XI"][index]

            color: "#e5c780"
            font.family: "Serif"
            font.pixelSize: Math.max(11, root.width * 0.042)
            font.bold: true

            x: root.width / 2
               + Math.sin(index * Math.PI / 6) * root.width * 0.345
               - width / 2

            y: root.height / 2
               - Math.cos(index * Math.PI / 6) * root.height * 0.345
               - height / 2
        }
    }
}
