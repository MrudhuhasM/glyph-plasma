import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import org.kde.plasma.core as PlasmaCore
import org.kde.plasma.plasmoid

PlasmoidItem {
    id: root
    readonly property bool inPanel: Plasmoid.location === PlasmaCore.Types.LeftEdge
        || Plasmoid.location === PlasmaCore.Types.RightEdge
        || Plasmoid.location === PlasmaCore.Types.TopEdge
        || Plasmoid.location === PlasmaCore.Types.BottomEdge
    Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    Plasmoid.icon: "view-dashboard"
    activationTogglesExpanded: inPanel
    toolTipMainText: inPanel ? "Glyph Quick" : "Glyph Home"
    preferredRepresentation: inPanel ? compactRepresentation : fullRepresentation
    compactRepresentation: Controls.ToolButton {
        text: "Glyph Quick"
        display: Controls.AbstractButton.IconOnly
        icon.name: "view-dashboard"
        onClicked: root.expanded = !root.expanded
    }

    property date now: new Date()
    readonly property var locale: Qt.locale()
    readonly property string clock: Qt.formatTime(now, "HH:mm")
    readonly property string dateLine: now.toLocaleDateString(locale, "dddd  ·  dd MMMM").toUpperCase()
    readonly property string greeting: now.getHours() < 12 ? "Good morning,"
        : now.getHours() < 18 ? "Good afternoon," : "Good evening,"

    Timer {
        interval: 1000
        running: !root.inPanel
        repeat: true
        onTriggered: root.now = new Date()
    }

    fullRepresentation: Loader {
        Layout.minimumWidth: root.inPanel ? 360 : 270
        Layout.minimumHeight: root.inPanel ? 340 : 140
        Layout.preferredWidth: root.inPanel ? 405 : 1050
        Layout.preferredHeight: root.inPanel ? 450 : 490
        sourceComponent: root.inPanel ? quickView : homeView
    }

    Component {
        id: quickView
        QuickPanel {
            focusUntil: Plasmoid.configuration.focusUntil
            onFocusRequested: function(deadline) {
                Plasmoid.configuration.focusUntil = deadline
            }
        }
    }

    Component {
        id: homeView
        Item {
            id: dashboard
            readonly property real unit: Math.min(width / 1050, height / 490)

            Item {
                width: 1050 * dashboard.unit
                height: 490 * dashboard.unit
                anchors.left: parent.left
                anchors.top: parent.top

                DotText {
                    text: root.clock
                    x: 0
                    y: 24 * dashboard.unit
                    width: 590 * dashboard.unit
                    height: 130 * dashboard.unit
                }
                Text {
                    y: 177 * dashboard.unit
                    text: root.dateLine
                    font.family: "monospace"
                    font.pixelSize: Math.max(1, 15 * dashboard.unit)
                    font.letterSpacing: 2 * dashboard.unit
                    color: "#ababab"
                }
                Text {
                    y: 254 * dashboard.unit
                    text: root.greeting
                    font.pixelSize: Math.max(1, 38 * dashboard.unit)
                    font.weight: Font.Light
                    color: "#f5f5f5"
                }
                Text {
                    y: 304 * dashboard.unit
                    text: "nothing."
                    font.pixelSize: Math.max(1, 38 * dashboard.unit)
                    font.weight: Font.Light
                    color: "#999999"
                }

                GlyphCard {
                    id: calendar
                    unit: dashboard.unit
                    x: 645 * dashboard.unit
                    y: 12 * dashboard.unit
                    width: 230 * dashboard.unit
                    height: 176 * dashboard.unit

                    Text {
                        x: 20 * dashboard.unit
                        y: 16 * dashboard.unit
                        text: root.now.toLocaleDateString(root.locale, "MMMM").toUpperCase()
                        font.family: "monospace"
                        font.letterSpacing: dashboard.unit
                        font.pixelSize: Math.max(1, 13 * dashboard.unit)
                        color: "#aaaaaa"
                    }
                    DotText {
                        text: Qt.formatDate(root.now, "dd")
                        anchors.centerIn: parent
                        width: 108 * dashboard.unit
                        height: 66 * dashboard.unit
                    }
                    Row {
                        anchors.horizontalCenter: parent.horizontalCenter
                        anchors.bottom: parent.bottom
                        anchors.bottomMargin: 15 * dashboard.unit
                        Repeater {
                            model: 7
                            Text {
                                required property int index
                                readonly property bool today: index === (root.now.getDay() + 6) % 7
                                width: 26 * dashboard.unit
                                horizontalAlignment: Text.AlignHCenter
                                text: root.locale.dayName((index + 1) % 7, Locale.NarrowFormat)
                                color: today ? "#ff5360" : "#aaaaaa"
                                font.bold: today
                                font.pixelSize: Math.max(1, 13 * dashboard.unit)
                            }
                        }
                    }
                }

                GlyphCard {
                    x: 893 * dashboard.unit
                    y: calendar.y
                    width: 156 * dashboard.unit
                    height: width
                    radius: width / 2

                    Canvas {
                        id: secondsRing
                        anchors.fill: parent
                        property int seconds: root.now.getSeconds()
                        onSecondsChanged: requestPaint()
                        onWidthChanged: requestPaint()
                        onHeightChanged: requestPaint()
                        onPaint: {
                            const ctx = getContext("2d")
                            const center = width / 2
                            const radius = width * 0.42
                            ctx.clearRect(0, 0, width, height)
                            for (let i = 0; i < 60; i++) {
                                const angle = (i / 60 - 0.25) * 2 * Math.PI
                                ctx.fillStyle = i < seconds ? "#dddddd" : "#393939"
                                ctx.beginPath()
                                ctx.arc(center + radius * Math.cos(angle), center + radius * Math.sin(angle),
                                        width * 0.009, 0, 2 * Math.PI)
                                ctx.fill()
                            }
                        }
                    }
                    DotText {
                        text: Qt.formatTime(root.now, "ss")
                        anchors.centerIn: parent
                        width: 62 * dashboard.unit
                        height: 38 * dashboard.unit
                    }
                }
                MediaCard {
                    x: 645 * dashboard.unit
                    y: 201 * dashboard.unit
                    width: 405 * dashboard.unit
                    height: 125 * dashboard.unit
                    unit: dashboard.unit
                }
                SystemCard {
                    x: 645 * dashboard.unit
                    y: 339 * dashboard.unit
                    width: 405 * dashboard.unit
                    height: 135 * dashboard.unit
                    unit: dashboard.unit
                }
            }
        }
    }
}
