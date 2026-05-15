import QtQuick
import QtQuick.Layouts
import "."

Rectangle {
    id: root
    property string title: "Panel"
    property string kicker: ""
    default property alias content: body.data
    property alias rightContent: header.rightContent

    color: ChronosTokens.panel
    border.color: ChronosTokens.panelBorder
    border.width: 1
    radius: ChronosTokens.radiusSmall
    clip: true

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        ChronosPanelHeader {
            id: header
            Layout.fillWidth: true
            title: root.title
            kicker: root.kicker
        }

        Item {
            id: body
            Layout.fillWidth: true
            Layout.fillHeight: true
        }
    }
}
