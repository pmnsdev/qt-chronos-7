import QtQuick
import QtQuick.Controls
import QtQuick.Layouts
import ClientUi

Rectangle {
    id: root
    width: 1600
    height: 950
    color: ChronosTokens.background

    property var store
    property var gateway
    property var toast
    property int activeTab: 0
    property string clockTextString: "Loading..."
    property string lteStatusText: "lte ok 0/0"
    property var tabLabels: ["OVERVIEW", "SITE FLEET", "MODBUS / LTE", "ALARMS", "AUDIT"]



    Rectangle {
        anchors.fill: parent
        color: ChronosTokens.background

        Repeater {
            model: (parent.width + 31) / 32
            Rectangle {
                x: index * 32
                width: 1
                height: parent.height
                color: ChronosTokens.backgroundGrid
                opacity: 0.5
            }
        }
        Repeater {
            model: (parent.height + 31) / 32
            Rectangle {
                y: index * 32
                width: parent.width
                height: 1
                color: ChronosTokens.backgroundGrid
                opacity: 0.5
            }
        }
    }

    ColumnLayout {
        anchors.fill: parent
        spacing: 0

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ChronosTokens.topBarHeight
            color: Qt.rgba(ChronosTokens.panel.r, ChronosTokens.panel.g, ChronosTokens.panel.b, 0.94)
            border.color: ChronosTokens.panelBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 18
                anchors.rightMargin: 18
                spacing: 16

                Rectangle {
                    Layout.preferredWidth: 36
                    Layout.preferredHeight: 36
                    radius: 18
                    color: "transparent"
                    border.color: ChronosTokens.ok
                    border.width: 1
                    Text { anchors.centerIn: parent; text: "C7"; color: ChronosTokens.ok; font.bold: true; font.pixelSize: 12; font.family: ChronosTokens.monoFont }
                }

                ColumnLayout {
                    spacing: 2
                    Text { text: ChronosTokens.title + " - MINUTE-SET"; color: ChronosTokens.mutedText; font.pixelSize: 10; font.letterSpacing: 2.5; font.family: ChronosTokens.monoFont }
                    Text { text: ChronosTokens.subtitle; color: ChronosTokens.foreground; font.pixelSize: 15; font.bold: true; font.family: ChronosTokens.monoFont }
                }

                SeverityTag { text: "FLEET " + (root.store ? root.store.sites.length : 0) + " SITES"; severity: "ok" }
                SeverityTag { text: "HR40001"; severity: "info" }

                Item { Layout.fillWidth: true }

                StatusLed { severity: root.gateway && root.gateway.isConnected ? "ok" : "crit"; label: root.gateway && root.gateway.isConnected ? "GATEWAY" : "OFFLINE" }
                StatusLed { severity: root.gateway && root.gateway.isAuthenticated ? "ok" : "warn"; label: root.gateway && root.gateway.isAuthenticated ? "AUTH" : "LOGIN" }
                StatusLed { severity: "warn"; label: "LTE" }

                Text {
                    id: clockText
                    color: ChronosTokens.info
                    font.pixelSize: 14
                    font.bold: true
                    font.family: ChronosTokens.monoFont
                    text: root.clockTextString
                }


            }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ChronosTokens.tabBarHeight
            color: Qt.rgba(ChronosTokens.panel.r, ChronosTokens.panel.g, ChronosTokens.panel.b, 0.82)
            border.color: ChronosTokens.panelBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 8
                anchors.rightMargin: 8
                spacing: 0

                Repeater {
                    model: root.tabLabels
                    Rectangle {
                        Layout.preferredWidth: 190
                        Layout.fillHeight: true
                        color: index === root.activeTab ? ChronosTokens.panelActive : "transparent"

                        Column {
                            anchors.centerIn: parent
                            spacing: 3
                            Text { text: "0" + (index + 1); anchors.horizontalCenter: parent.horizontalCenter; color: index === root.activeTab ? ChronosTokens.ok : ChronosTokens.faintText; font.pixelSize: 9; font.letterSpacing: 2; font.family: ChronosTokens.monoFont }
                            Text { text: modelData; anchors.horizontalCenter: parent.horizontalCenter; color: index === root.activeTab ? ChronosTokens.foreground : ChronosTokens.mutedText; font.pixelSize: 12; font.bold: index === root.activeTab; font.family: ChronosTokens.monoFont }
                        }

                        Rectangle {
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            height: 2
                            width: parent.width - 20
                            color: index === root.activeTab ? ChronosTokens.ok : "transparent"
                        }

                        MouseArea {
                            anchors.fill: parent
                            onClicked: root.activeTab = index
                        }
                    }
                }

                Item { Layout.fillWidth: true }
            }
        }

        StackLayout {
            Layout.fillWidth: true
            Layout.fillHeight: true
            currentIndex: root.activeTab

            OverviewScreen { store: root.store }
            SiteFleetScreen { store: root.store; gateway: root.gateway; toast: root.toast }
            ModbusLteScreen { store: root.store }
            AlarmsScreen { store: root.store }
            AuditScreen { store: root.store }
        }

        Rectangle {
            Layout.fillWidth: true
            Layout.preferredHeight: ChronosTokens.statusBarHeight
            color: Qt.rgba(ChronosTokens.panelDark.r, ChronosTokens.panelDark.g, ChronosTokens.panelDark.b, 0.96)
            border.color: ChronosTokens.panelBorder

            RowLayout {
                anchors.fill: parent
                anchors.leftMargin: 12
                anchors.rightMargin: 12
                spacing: 20

                StatusLed { severity: "ok"; label: "scheduler ARMED"; blinkOnCritical: false }
                Text { text: "modbus 119/128 acks"; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
                Text { text: root.lteStatusText; color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
                Text { text: "gateway " + (root.gateway ? root.gateway.gatewayUrl : "not attached"); color: ChronosTokens.mutedText; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
                Item { Layout.fillWidth: true }
                Text { text: "embedded .ui.qml display component"; color: ChronosTokens.faintText; font.pixelSize: 11; font.family: ChronosTokens.monoFont }
            }
        }
    }
}
