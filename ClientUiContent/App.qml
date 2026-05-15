import QtQuick
import QtQuick.Controls
import QtQuick.Window
import ClientUi

Window {
    id: appWindow
    width: 1920
    height: 1080
    minimumWidth: 1180
    minimumHeight: 720
    visible: true
    title: "CHRONOS-7 Display - Qt Design Studio Project"
    color: ChronosTokens.background

    ChronosStore { id: demoStore }
    GatewayStub { id: demoGateway }

    ChronosDashboard {
        id: dashboard
        anchors.fill: parent
        store: demoStore
        gateway: demoGateway
        toast: toast
    }

    CommandToast {
        id: toast
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: 48
    }
}
