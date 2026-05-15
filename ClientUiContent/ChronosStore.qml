import QtQuick

QtObject {
    id: root

    property int referenceMinute: 27
    property int revision: 0
    property string selectedSiteId: sites.length > 0 ? sites[0].siteId : ""

    property var sites: makeSites()

    property var gateways: [
        { id: "GW-A", role: "Time Master Primary", state: "ACTIVE", utcSrc: "GNSS", sites: 128, health: "ok" },
        { id: "GW-B", role: "Time Master Standby", state: "STANDBY", utcSrc: "GNSS", sites: 0, health: "ok" },
        { id: "MX-1", role: "Modbus Broker North", state: "ACTIVE", utcSrc: "GW-A", sites: 41, health: "ok" },
        { id: "MX-2", role: "Modbus Broker South", state: "ACTIVE", utcSrc: "GW-A", sites: 37, health: "warn" },
        { id: "MX-3", role: "Modbus Broker East/West", state: "ACTIVE", utcSrc: "GW-A", sites: 50, health: "ok" }
    ]

    property var alarms: [
        { ts: "2026-05-14 09:42", severity: "crit", code: "MINUTE-DRIFT", source: "SITE-0042", message: "PLC minute HR40001 differs from reference by -8 min." },
        { ts: "2026-05-14 09:41", severity: "crit", code: "MODBUS-TIMEOUT", source: "SITE-0091", message: "Write to Modbus device timed out after 3 attempts." },
        { ts: "2026-05-14 09:39", severity: "warn", code: "LTE-RSRP-LOW", source: "SITE-0017", message: "RSRP below warning threshold. Cellular link may be unstable." },
        { ts: "2026-05-14 09:36", severity: "warn", code: "MINUTE-DRIFT", source: "SITE-0103", message: "PLC minute drift +2 min." },
        { ts: "2026-05-14 09:31", severity: "warn", code: "PDP-FLAP", source: "SITE-0058", message: "PDP context re-established multiple times in 10 minutes." }
    ]

    property var auditEvents: [
        { ts: "09:42:18", severity: "crit", source: "modbus-tx", message: "SITE-0042 FC=06 HR40001 <- 27, expected ack" },
        { ts: "09:42:18", severity: "crit", source: "modbus-rx", message: "SITE-0042 EXCEPTION 0x0B gateway target device failed to respond" },
        { ts: "09:42:17", severity: "warn", source: "lte-mon", message: "SITE-0042 RSRP=-117 dBm RSRQ=-16 dB SINR=-2 dB" },
        { ts: "09:41:58", severity: "crit", source: "modbus-rx", message: "SITE-0091 TIMEOUT after 3000 ms, attempt 3/3" },
        { ts: "09:41:43", severity: "ok", source: "modbus-rx", message: "119/128 acks received in window 800 ms" },
        { ts: "09:36:44", severity: "info", source: "scheduler", message: "next sync window in 60s" }
    ]

    signal siteUpdated(string siteId)
    signal auditAppended()

    function makeSites() {
        var out = []
        var regions = ["North", "South", "East", "West", "Central"]
        var carriers = ["AIS-NB", "DTAC-M2M", "TRUE-IoT", "Vodafone", "Telia-IoT", "Orange-M2M"]
        var techs = ["LTE", "LTE-A", "LTE-M", "NB-IoT"]
        var apns = ["scada.iot", "m2m.private", "plc-vpn", "ot.apn"]

        for (var i = 1; i <= 128; i++) {
            var region = regions[i % regions.length]
            var drift = 0
            if (i % 47 === 0) drift = -8
            else if (i % 31 === 0) drift = 6
            else if (i % 17 === 0) drift = -2
            else if (i % 11 === 0) drift = 2
            else if (i % 7 === 0) drift = 1

            var plcMinute = (referenceMinute + drift + 60) % 60
            var rsrp = -70 - (i % 52)
            var sinr = 20 - (i % 28)
            var bars = rsrp > -85 ? 5 : rsrp > -95 ? 4 : rsrp > -105 ? 3 : rsrp > -115 ? 2 : 1
            var health = "ok"
            var link = "ONLINE"
            if (Math.abs(drift) >= 5 || rsrp < -116) {
                health = "crit"
                link = rsrp < -116 ? "OFFLINE" : "DEGRADED"
            } else if (Math.abs(drift) >= 1 || rsrp < -105 || sinr < 0) {
                health = "warn"
                link = "DEGRADED"
            }
            if (i % 59 === 0) {
                link = "FLAPPING"
                health = "warn"
            }

            out.push({
                siteId: "SITE-" + String(i).padStart(4, "0"),
                name: region + " Pump " + String(i).padStart(3, "0"),
                region: region,
                deviceId: i,
                host: "10." + (21 + (i % 5)) + "." + (10 + (i % 240)) + "." + (1 + (i % 250)),
                port: 502,
                unitId: 1 + (i % 32),
                humanRegister: 40001,
                backendAddress: 1,
                plcMinute: plcMinute,
                plcMinuteText: String(plcMinute).padStart(2, "0"),
                refMinute: referenceMinute,
            refMinuteText: String(referenceMinute).padStart(2, "0"),
                refMinuteText: String(referenceMinute).padStart(2, "0"),
                driftMin: normalizeDrift(plcMinute, referenceMinute),
                lastWriteUtc: "09:" + String((10 + i) % 60).padStart(2, "0") + ":" + String((20 + i) % 60).padStart(2, "0"),
                carrier: carriers[i % carriers.length],
                tech: techs[i % techs.length],
                rsrp: rsrp,
                rsrq: -6 - (i % 12),
                sinr: sinr,
                bars: bars,
                cellId: "0x" + (4096 + i * 73).toString(16).toUpperCase(),
                apn: apns[i % apns.length],
                rttMs: 80 + (i % 480),
                link: link,
                health: health
            })
        }
        return out
    }

    function normalizeDrift(plcMinute, refMinute) {
        var raw = plcMinute - refMinute
        return ((raw + 30 + 60) % 60) - 30
    }

    function healthFor(site) {
        if (site.link === "OFFLINE") return "crit"
        if (Math.abs(site.driftMin) >= 5) return "crit"
        if (Math.abs(site.driftMin) >= 1 || site.rsrp < -105 || site.sinr < 0) return "warn"
        return "ok"
    }

    function siteById(siteId) {
        for (var i = 0; i < sites.length; i++) {
            if (sites[i].siteId === siteId) return sites[i]
        }
        return null
    }

    function updateSite(siteId, patch) {
        var next = sites.slice()
        for (var i = 0; i < next.length; i++) {
            if (next[i].siteId === siteId) {
                var updated = {}
                for (var key in next[i]) updated[key] = next[i][key]
                for (var p in patch) updated[p] = patch[p]
                updated.driftMin = normalizeDrift(updated.plcMinute, updated.refMinute)
                updated.health = healthFor(updated)
                next[i] = updated
                break
            }
        }
        sites = next
        revision++
        siteUpdated(siteId)
    }

    function applyWriteResult(siteId, minuteValue) {
        var now = new Date()
        updateSite(siteId, {
            plcMinute: minuteValue,
            plcMinuteText: String(minuteValue).padStart(2, "0"),
            lastWriteUtc: String(now.getUTCHours()).padStart(2, "0") + ":" + String(now.getUTCMinutes()).padStart(2, "0") + ":" + String(now.getUTCSeconds()).padStart(2, "0")
        })
        appendAudit("ok", "audit", siteId + " HR40001 confirmed value=" + minuteValue)
    }

    function appendAudit(severity, source, message) {
        var now = new Date()
        auditEvents = auditEvents.concat([{ ts: String(now.getUTCHours()).padStart(2, "0") + ":" + String(now.getUTCMinutes()).padStart(2, "0") + ":" + String(now.getUTCSeconds()).padStart(2, "0"), severity: severity, source: source, message: message }])
        revision++
        auditAppended()
    }

    function filteredSites(searchText, regionFilter, stateFilter) {
        var text = searchText ? searchText.toLowerCase() : ""
        var out = []
        for (var i = 0; i < sites.length; i++) {
            var s = sites[i]
            if (regionFilter && regionFilter !== "all regions" && s.region !== regionFilter) continue
            if (stateFilter === "drift != 0" && s.driftMin === 0) continue
            if (stateFilter === "offline" && s.link !== "OFFLINE") continue
            if (stateFilter === "low RSRP" && s.rsrp >= -105) continue
            if (text.length > 0) {
                var hay = (s.siteId + " " + s.name + " " + s.host).toLowerCase()
                if (hay.indexOf(text) < 0) continue
            }
            out.push(s)
        }
        return out
    }

    function countHealth(h) {
        var c = 0
        for (var i = 0; i < sites.length; i++) if (sites[i].health === h) c++
        return c
    }

    function countOnline() {
        var c = 0
        for (var i = 0; i < sites.length; i++) if (sites[i].link === "ONLINE") c++
        return c
    }

    function driftValues() {
        var out = []
        for (var i = 0; i < sites.length; i++) out.push(sites[i].driftMin)
        return out
    }

    function worstSites(limit) {
        var copy = sites.slice()
        copy.sort(function(a, b) { return Math.abs(b.driftMin) - Math.abs(a.driftMin) })
        return copy.slice(0, limit || 6)
    }
}
