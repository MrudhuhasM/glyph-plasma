import QtQuick

Canvas {
    id: canvas
    property string text
    readonly property var digits: ({
        "0": [14, 17, 17, 17, 17, 17, 14],
        "1": [4, 12, 4, 4, 4, 4, 14],
        "2": [14, 17, 1, 2, 4, 8, 31],
        "3": [30, 1, 1, 14, 1, 1, 30],
        "4": [2, 6, 10, 18, 31, 2, 2],
        "5": [31, 16, 16, 30, 1, 1, 30],
        "6": [14, 16, 16, 30, 17, 17, 14],
        "7": [31, 1, 2, 4, 8, 8, 8],
        "8": [14, 17, 17, 14, 17, 17, 14],
        "9": [14, 17, 17, 15, 1, 1, 14],
        ":": [0, 0, 4, 0, 4, 0, 0]
    })

    onTextChanged: requestPaint()
    onWidthChanged: requestPaint()
    onHeightChanged: requestPaint()
    onPaint: {
        const ctx = getContext("2d")
        ctx.clearRect(0, 0, width, height)
        if (!text.length || width <= 0 || height <= 0)
            return
        const columns = text.length * 6 - 1
        const pitch = Math.min(width / columns, height / 7)
        const left = (width - columns * pitch) / 2
        const top = (height - 7 * pitch) / 2
        ctx.fillStyle = "#f2f2f2"
        for (let n = 0; n < text.length; n++) {
            const rows = digits[text[n]]
            if (!rows)
                continue
            for (let row = 0; row < rows.length; row++) {
                for (let col = 0; col < 5; col++) {
                    if ((rows[row] & (1 << (4 - col))) === 0)
                        continue
                    ctx.beginPath()
                    ctx.arc(left + (n * 6 + col + 0.5) * pitch, top + (row + 0.5) * pitch,
                            pitch * 0.39, 0, 2 * Math.PI)
                    ctx.fill()
                }
            }
        }
    }
}
