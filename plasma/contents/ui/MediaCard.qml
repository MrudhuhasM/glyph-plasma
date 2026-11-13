import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.private.mpris as Mpris

GlyphCard {
    id: card
    readonly property var player: players.currentPlayer
    readonly property bool playing: player?.playbackStatus === Mpris.PlaybackStatus.Playing

    Mpris.Mpris2Model { id: players }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 13 * card.unit
        spacing: 13 * card.unit

        Canvas {
            id: matrix
            Layout.preferredWidth: 95 * card.unit
            Layout.preferredHeight: width
            property bool active: card.playing
            property int phase: 0
            onActiveChanged: requestPaint()
            onWidthChanged: requestPaint()
            onHeightChanged: requestPaint()
            onPhaseChanged: requestPaint()
            Timer {
                interval: 180
                running: matrix.active && card.visible
                repeat: true
                onTriggered: matrix.phase = (matrix.phase + 1) % 40
            }
            onPaint: {
                const ctx = getContext("2d")
                ctx.clearRect(0, 0, width, height)
                const pitch = width / 23
                for (let y = -10; y <= 10; y++) {
                    for (let x = -10; x <= 10; x++) {
                        if (x * x + y * y > 108)
                            continue
                        const wave = Math.sin(x * 0.7 + phase * Math.PI / 20)
                        const band = active && Math.abs(y - wave * 4) < 2
                        ctx.fillStyle = band ? "#eeeeee" : "#464646"
                        ctx.beginPath()
                        ctx.arc(width / 2 + x * pitch, height / 2 + y * pitch,
                                pitch * 0.28, 0, Math.PI * 2)
                        ctx.fill()
                    }
                }
            }
        }

        ColumnLayout {
            Layout.fillWidth: true
            spacing: 2 * card.unit
            Text {
                Layout.fillWidth: true
                text: card.player?.identity ? card.player.identity.toUpperCase() : "NOW PLAYING"
                font.family: "monospace"
                font.pixelSize: Math.max(8, 11 * card.unit)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: "#ababab"
            }
            Text {
                Layout.fillWidth: true
                text: card.player?.track || "No media playing"
                font.pixelSize: Math.max(10, 16 * card.unit)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: "#eeeeee"
            }
            Text {
                Layout.fillWidth: true
                visible: text.length > 0
                text: card.player?.artist || ""
                font.pixelSize: Math.max(8, 12 * card.unit)
                textFormat: Text.PlainText
                elide: Text.ElideRight
                color: "#ababab"
            }
            RowLayout {
                MediaButton {
                    text: "Previous track"
                    icon.name: "media-skip-backward"
                    enabled: card.player?.canGoPrevious ?? false
                    onClicked: card.player.Previous()
                }
                MediaButton {
                    text: card.playing ? "Pause" : "Play"
                    icon.name: card.playing ? "media-playback-pause" : "media-playback-start"
                    enabled: (card.playing ? card.player?.canPause : card.player?.canPlay) ?? false
                    highlighted: true
                    onClicked: {
                        if (card.playing)
                            card.player.Pause()
                        else
                            card.player.Play()
                    }
                }
                MediaButton {
                    text: "Next track"
                    icon.name: "media-skip-forward"
                    enabled: card.player?.canGoNext ?? false
                    onClicked: card.player.Next()
                }
            }
        }
    }
    component MediaButton: Controls.ToolButton {
        display: Controls.AbstractButton.IconOnly
        Layout.preferredWidth: Math.max(22, 34 * card.unit)
        Layout.preferredHeight: Math.max(22, 29 * card.unit)
        icon.width: Math.max(12, 16 * card.unit)
        icon.height: icon.width
        Controls.ToolTip.visible: hovered
        Controls.ToolTip.text: text
        background: Rectangle {
            radius: height / 2
            color: parent.highlighted && parent.enabled ? "#b82132"
                : parent.hovered ? "#303030" : "transparent"
        }
    }
}
