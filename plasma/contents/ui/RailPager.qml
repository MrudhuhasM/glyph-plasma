import QtQuick
import QtQuick.Controls as Controls
import QtQuick.Layouts
import plasma.applet.org.kde.plasma.pager as PlasmaPager

Item {
    id: pager
    Layout.minimumWidth: 22
    Layout.minimumHeight: dots.implicitHeight
    Layout.preferredHeight: dots.implicitHeight

    PlasmaPager.PagerModel {
        id: desktops
        pagerType: PlasmaPager.PagerModel.VirtualDesktops
        enabled: true
    }

    Column {
        id: dots
        anchors.centerIn: parent
        spacing: 2
        Repeater {
            model: desktops
            delegate: Controls.AbstractButton {
                id: dot
                required property int index
                required property string display
                readonly property bool current: index === desktops.currentPage
                width: 24
                height: 17
                hoverEnabled: true
                text: display || "Desktop " + (index + 1)
                onClicked: desktops.changePage(index)
                background: Rectangle {
                    anchors.centerIn: parent
                    width: dot.current ? 5 : 4
                    height: dot.current ? 13 : 4
                    radius: width / 2
                    color: dot.current || dot.hovered || dot.activeFocus ? "#f2f2f2" : "#6b6b6b"
                    Behavior on height { NumberAnimation { duration: 150 } }
                }
                Controls.ToolTip.visible: hovered
                Controls.ToolTip.text: text
            }
        }
    }
}
