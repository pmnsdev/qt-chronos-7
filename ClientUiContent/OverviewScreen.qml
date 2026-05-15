import QtQuick
import ClientUi

OverviewScreenForm {
    id: root

    driftValues: root.store ? root.store.driftValues() : []
    countHealthOk: String(root.store ? root.store.countHealth("ok") : 0)
    countHealthWarn: String(root.store ? root.store.countHealth("warn") : 0)
    countHealthCrit: String(root.store ? root.store.countHealth("crit") : 0)
    countOnline: String(root.store ? root.store.countOnline() : 0)
    referenceMinuteStr: String(root.store ? root.store.referenceMinute : 0).padStart(2, "0")
    worstSites: root.store ? root.store.worstSites(6, root.store.revision) : []
    gatewaysList: root.store ? root.store.gateways : []
}
