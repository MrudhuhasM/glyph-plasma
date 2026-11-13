import QtQuick
import QtQuick.Layouts

Item {
    id: clock
    required property date now
    Layout.minimumWidth: 23
    Layout.minimumHeight: 46
    Layout.preferredHeight: 52

    Column {
        width: Math.min(27, clock.width - 4)
        anchors.centerIn: parent
        spacing: 2
        DotText { width: parent.width; height: 15; text: Qt.formatTime(clock.now, "HH") }
        DotText { width: parent.width; height: 15; text: Qt.formatTime(clock.now, "mm") }
        Text {
            width: parent.width
            horizontalAlignment: Text.AlignHCenter
            text: Qt.formatDate(clock.now, "dd")
            color: "#a0a0a0"
            font.family: "monospace"
            font.pixelSize: 9
        }
    }
}
