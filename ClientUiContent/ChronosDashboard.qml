import QtQuick
import ClientUi

ChronosDashboardForm {
    id: root

    clockTextString: Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss") + " UTC"
    lteStatusText: "lte ok " + (root.store ? root.store.countOnline() : 0) + "/" + (root.store ? root.store.sites.length : 0)

    Timer {
        interval: 1000
        running: true
        repeat: true
        onTriggered: root.clockTextString = Qt.formatDateTime(new Date(), "yyyy-MM-dd hh:mm:ss") + " UTC"
    }



    Connections {
        target: root.gateway
        ignoreUnknownSignals: true
        function onShowNotification(message) {
            if (root.toast && message && message.length > 0)
                root.toast.show(message, "info")
        }
    }
}
