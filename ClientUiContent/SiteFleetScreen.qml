import QtQuick
import ClientUi

SiteFleetScreenForm {
    id: root

    minuteSliderText: ":" + String(minuteSliderValueRounded).padStart(2, "0")
    writeCommandText: selectedSite ? "> write_register\n  device_id=" + selectedSite.deviceId + "\n  unit_id=" + selectedSite.unitId + "\n  address=" + selectedSite.backendAddress + " // HR40001\n  value=" + minuteSliderValueRounded + "\n  data_type=uint16" : "select a site"
    confirmDialogText: selectedSite ? "Write HR40001 value :" + String(minuteSliderValueRounded).padStart(2, "0") + " to " + selectedSite.siteId + "?\n\nThe UI should show success only after the backend returns confirmed read-back." : "No site selected."

    function updateFiltered() {
        visibleSites = store ? store.filteredSites(searchFieldText, regionFilterCurrentText, stateFilterCurrentText) : []
        if (!selectedSite && visibleSites.length > 0) selectedSite = visibleSites[0]
    }

    function sendWriteCommand() {
        if (!selectedSite || !gateway) return
        commandState = "busy"
        pendingSiteId = selectedSite.siteId
        pendingMinute = Math.round(minuteSliderValue)
        pendingCorrelationId = gateway.sendCommand(selectedSite.deviceId, "write_register", selectedSite.unitId, selectedSite.backendAddress, pendingMinute, "uint16")
        if (store) store.appendAudit("info", "ui", pendingSiteId + " write requested HR40001 value=" + pendingMinute)
    }

    onUpdateFilteredSignal: updateFiltered()
    onSendWriteCommandSignal: sendWriteCommand()
    onSyncToUtcClicked: minuteSliderValue = selectedSite.refMinute
    onWriteAndVerifyClicked: confirmDialog.open()

    onSearchFieldTextChanged: updateFiltered()
    onRegionFilterCurrentTextChanged: updateFiltered()
    onStateFilterCurrentTextChanged: updateFiltered()

    Component.onCompleted: updateFiltered()

    Connections {
        target: root.store
        ignoreUnknownSignals: true
        function onSitesChanged() { root.updateFiltered() }
    }

    Connections {
        target: root.gateway
        ignoreUnknownSignals: true
        function onCommandResult(correlationId, success, status, error) {
            if (correlationId !== root.pendingCorrelationId) return

            if (status === "accepted") {
                // Keep the state busy until it's confirmed or timed out
                return
            }

            if (status === "confirmed" || status === "timeout" || status === "error") {
                root.commandState = "ready"
                if (success) {
                    if (root.toast) root.toast.show("Successfully verified PLC time on " + root.pendingSiteId, "ok")
                    if (root.store) {
                        root.store.appendAudit("ok", "ui", root.pendingSiteId + " write confirmed via read-back")
                        root.store.applyWriteResult(root.pendingSiteId, root.pendingMinute)
                    }
                } else {
                    if (root.toast) root.toast.show("Failed to verify PLC time on " + root.pendingSiteId + " - " + error, "crit")
                    if (root.store) root.store.appendAudit("crit", "ui", root.pendingSiteId + " write failed: " + error)
                }
                root.updateFiltered()
            }
        }
    }
}
