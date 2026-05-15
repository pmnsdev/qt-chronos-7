import QtQuick
import ClientUi

ChronosDashboardForm {
    id: root

    onTabSelected: function(index) {
        root.activeTab = index
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
