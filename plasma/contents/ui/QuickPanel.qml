import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.private.brightnesscontrolplugin as Brightness
import org.kde.plasma.private.volume as Audio

GlyphCard {
    id: panel
    property string focusUntil: "0"
    signal focusRequested(string deadline)
    property double now: Date.now()
    readonly property int remaining: Math.max(0, Math.ceil((Number(focusUntil) - now) / 1000)) || 0
    readonly property var sink: Audio.PreferredDevice.sink
    readonly property bool hasOutput: !!sink && sink.name !== "auto_null"
    readonly property int volume: hasOutput ? Math.round(sink.volume * 100 / Audio.PulseAudio.NormalVolume) : 0
    radius: 16

    Audio.SinkModel { id: outputs }
    Brightness.ScreenBrightnessControl {
        id: brightnessControl
        isSilent: true
    }

    onVisibleChanged: if (visible) now = Date.now()
    Timer {
        interval: 250
        running: panel.remaining > 0
        repeat: true
        onTriggered: panel.now = Date.now()
    }

    Controls.ScrollView {
        id: scroll
        anchors.fill: parent
        anchors.margins: 15
        contentWidth: availableWidth
        Controls.ScrollBar.horizontal.policy: Controls.ScrollBar.AlwaysOff

        ColumnLayout {
            width: scroll.availableWidth
            spacing: 9
            Text {
                text: "QUICK"
                font.family: "monospace"
                font.letterSpacing: 3
                font.pixelSize: 13
                color: "#e8e8e8"
            }
            GlyphCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 92
                radius: 13
                ColumnLayout {
                    anchors.fill: parent
                    anchors.margins: 12
                    Text {
                        Layout.fillWidth: true
                        text: panel.hasOutput ? (panel.sink.description || panel.sink.name) : "No audio output"
                        textFormat: Text.PlainText
                        elide: Text.ElideRight
                        color: "#eeeeee"
                    }
                    RowLayout {
                        Controls.ToolButton {
                            enabled: panel.hasOutput
                            text: panel.hasOutput && panel.sink.muted ? "Unmute" : "Mute"
                            icon.name: panel.hasOutput && panel.sink.muted ? "audio-volume-muted" : "audio-volume-high"
                            display: Controls.AbstractButton.IconOnly
                            onClicked: panel.sink.muted = !panel.sink.muted
                        }
                        Controls.Slider {
                            Layout.fillWidth: true
                            enabled: panel.hasOutput
                            Accessible.name: "Output volume"
                            from: 0
                            to: 100
                            stepSize: 1
                            value: panel.volume
                            onMoved: panel.sink.volume = Math.round(value / 100 * Audio.PulseAudio.NormalVolume)
                        }
                        Text {
                            text: panel.hasOutput ? panel.volume + "%" : "—"
                            color: "#eeeeee"
                            font.family: "monospace"
                        }
                    }
                }
            }
            Repeater {
                model: brightnessControl.displays
                delegate: RowLayout {
                    id: display
                    required property string displayName
                    required property string label
                    required property int brightness
                    required property int maxBrightness
                    Layout.fillWidth: true
                    Text {
                        text: display.label
                        color: "#eeeeee"
                        elide: Text.ElideRight
                        Layout.preferredWidth: 105
                        textFormat: Text.PlainText
                    }
                    Controls.Slider {
                        Accessible.name: "Brightness for " + display.label
                        Layout.fillWidth: true
                        from: 0
                        to: display.maxBrightness
                        value: display.brightness
                        onMoved: brightnessControl.setBrightness(display.displayName, Math.round(value))
                    }
                }
            }
            MediaCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 105
                unit: 0.85
                radius: 13
            }
            GlyphCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 85
                radius: 13
                RowLayout {
                    anchors.fill: parent
                    anchors.margins: 13
                    ColumnLayout {
                        Layout.fillWidth: true
                        Text {
                            text: "FOCUS"
                            color: "#aaaaaa"
                            font.family: "monospace"
                            font.pixelSize: 11
                        }
                        DotText {
                            Layout.preferredWidth: 90
                            Layout.preferredHeight: 25
                            text: String(Math.floor(panel.remaining / 60)).padStart(2, "0")
                                  + ":" + String(panel.remaining % 60).padStart(2, "0")
                        }
                    }
                    Controls.Button {
                        text: panel.remaining > 0 ? "Reset" : "Start 25 min"
                        onClicked: {
                            panel.now = Date.now()
                            panel.focusRequested(panel.remaining > 0 ? "0" : String(panel.now + 25 * 60 * 1000))
                        }
                    }
                }
            }
            CalendarCard {
                Layout.fillWidth: true
                Layout.preferredHeight: 215
            }
        }
    }
}
