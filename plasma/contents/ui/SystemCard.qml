import QtQuick
import QtQuick.Layouts
import org.kde.ksysguard.sensors as Sensors

GlyphCard {
    id: card
    property var samples: []

    Sensors.Sensor { id: cpu; sensorId: "cpu/all/usage" }
    Sensors.Sensor { id: memory; sensorId: "memory/physical/used" }
    Sensors.Sensor { id: gpu; sensorId: "gpu/all/usage" }

    Timer {
        interval: 2000
        running: card.visible
        repeat: true
        onTriggered: {
            const usage = Number(cpu.value)
            if (cpu.formattedValue && Number.isFinite(usage))
                card.samples = card.samples.slice(-29).concat(Math.max(0, Math.min(100, usage)))
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 15 * card.unit
        spacing: 15 * card.unit
        GridLayout {
            columns: 2
            columnSpacing: 16 * card.unit
            rowSpacing: 6 * card.unit
            Metric { label: "CPU"; value: cpu.formattedValue || "—" }
            Metric { label: "RAM"; value: memory.formattedValue || "—" }
            Metric { label: "GPU"; value: gpu.formattedValue || "—" }
        }

        ColumnLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            Text {
                text: "CPU · 60 S"
                color: "#a0a0a0"
                font.family: "monospace"
                font.pixelSize: Math.max(8, 11 * card.unit)
            }
            Canvas {
                id: history
                Layout.fillWidth: true
                Layout.fillHeight: true
                onWidthChanged: requestPaint()
                onHeightChanged: requestPaint()
                Connections {
                    target: card
                    function onSamplesChanged() { history.requestPaint() }
                }
                onPaint: {
                    const ctx = getContext("2d")
                    ctx.clearRect(0, 0, width, height)
                    const dx = width / 30
                    const dy = height / 10
                    const offset = 30 - card.samples.length
                    for (let x = 0; x < 30; x++) {
                        const sample = card.samples[x - offset]
                        const level = Math.round((sample ?? 0) / 100 * 9)
                        for (let y = 0; y < 10; y++) {
                            ctx.fillStyle = sample !== undefined && y === level ? "#eeeeee" : "#353535"
                            ctx.beginPath()
                            ctx.arc((x + 0.5) * dx, height - (y + 0.5) * dy,
                                    Math.min(dx, dy) * 0.24, 0, Math.PI * 2)
                            ctx.fill()
                        }
                    }
                }
            }
        }
    }
    component Metric: ColumnLayout {
        property string label
        property string value
        spacing: 2 * card.unit
        Text {
            text: parent.label
            color: "#a0a0a0"
            font.family: "monospace"
            font.pixelSize: Math.max(8, 11 * card.unit)
        }
        Text {
            text: parent.value
            color: "#eeeeee"
            font.family: "monospace"
            font.pixelSize: Math.max(10, 16 * card.unit)
        }
    }
}
