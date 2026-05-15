import QtQuick

QtObject {
    id: root
    property bool isConnected: true
    property bool isAuthenticated: true
    property string gatewayUrl: "wss://localhost:8443"
    property int counter: 0

    signal authResult(bool success, string error)
    signal commandResult(string correlationId, bool success, string status, string error)
    signal showNotification(string message)
    signal connectionStatusChanged()
    signal authStatusChanged()

    function connectToGateway() {
        isConnected = true
        connectionStatusChanged()
        showNotification("Gateway connected")
    }

    function disconnectFromGateway() {
        isConnected = false
        isAuthenticated = false
        connectionStatusChanged()
        authStatusChanged()
        showNotification("Gateway disconnected")
    }

    function login(username, password) {
        isAuthenticated = username.length > 0 && password.length > 0
        authStatusChanged()
        authResult(isAuthenticated, isAuthenticated ? "" : "Missing credentials")
    }

    function sendCommand(deviceId, command, unitId, address, value, dataType) {
        if (!isConnected) {
            commandResult("", false, "disconnected", "Gateway is not connected")
            return ""
        }
        if (!isAuthenticated) {
            commandResult("", false, "auth_required", "Login required")
            return ""
        }
        var correlationId = "demo-" + (++counter) + "-" + Date.now()
        commandResult(correlationId, true, "accepted", "")
        showNotification("Command accepted. Waiting for read-back.")

        var t = Qt.createQmlObject('import QtQuick; Timer { interval: 950; repeat: false }', root, "commandTimer")
        t.triggered.connect(function() {
            if (value < 0 || value > 59) {
                commandResult(correlationId, false, "value_out_of_range", "Minute must be 0..59")
            } else if (deviceId % 37 === 0) {
                commandResult(correlationId, false, "timeout", "Worker / 4G timeout")
            } else if (deviceId % 29 === 0) {
                commandResult(correlationId, false, "readback_failed", "Read-back value does not match written value")
            } else {
                commandResult(correlationId, true, "confirmed", "")
                showNotification("Write confirmed by read-back")
            }
            t.destroy()
        })
        t.start()
        return correlationId
    }
}
