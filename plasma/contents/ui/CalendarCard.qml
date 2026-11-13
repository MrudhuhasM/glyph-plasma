import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts

GlyphCard {
    id: calendar
    property date monthShown: new Date()
    radius: 13

    function changeMonth(offset) {
        monthShown = new Date(monthShown.getFullYear(), monthShown.getMonth() + offset, 1)
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 10
        spacing: 4
        RowLayout {
            Layout.fillWidth: true
            Controls.ToolButton {
                text: "Previous month"
                display: Controls.AbstractButton.IconOnly
                icon.name: "go-previous"
                onClicked: calendar.changeMonth(-1)
            }
            Text {
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignHCenter
                text: monthGrid.title
                color: "#eeeeee"
                font.family: "monospace"
            }
            Controls.ToolButton {
                text: "Next month"
                display: Controls.AbstractButton.IconOnly
                icon.name: "go-next"
                onClicked: calendar.changeMonth(1)
            }
        }
        Controls.DayOfWeekRow {
            Layout.fillWidth: true
            locale: monthGrid.locale
        }
        Controls.MonthGrid {
            id: monthGrid
            Layout.fillWidth: true
            Layout.fillHeight: true
            month: calendar.monthShown.getMonth()
            year: calendar.monthShown.getFullYear()
            delegate: Text {
                required property var model
                horizontalAlignment: Text.AlignHCenter
                verticalAlignment: Text.AlignVCenter
                text: model.day
                opacity: model.month === monthGrid.month ? 1 : 0.35
                color: model.today ? "#ff5360" : "#eeeeee"
                font.bold: model.today
                font.family: "monospace"
            }
        }
    }
}
