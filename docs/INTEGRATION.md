# Integration Notes for qt-display-client + MultiThread

## Why the previous export could create duplicate windows

The earlier project used `Main.qml` as an `ApplicationWindow`. If that file is loaded inside the existing `qt-display-client` `Loader`, every load creates another native window. That is why multiple display windows can appear.

This version fixes that by making the display an embeddable item:

```text
ChronosDashboardForm.ui.qml  -> visual root Rectangle/Item, no Window
ChronosDashboard.qml         -> behavior wrapper
App.qml                      -> standalone preview Window only
```

## Correct integration into qt-display-client

In the existing `ClientUiContent/App.qml`, add a component like this:

```qml
Component {
    id: chronosComp

    ChronosDashboard {
        anchors.fill: parent
        store: chronosStore      // replace with real C++/QML model later
        gateway: gatewayService  // existing context property from main.cpp
        toast: chronosToast
    }
}
```

Then navigate with:

```qml
host.sourceComponent = chronosComp
```

Do not use `App.qml` from this export inside the existing application. The existing `qt-display-client` `App.qml` must remain the only top-level `Window`.

## Backend command path

Use the existing `gatewayService.sendCommand(...)` path:

```qml
gatewayService.sendCommand(deviceId, "write_register", unitId, 1, minute, "uint16")
```

For HR40001, send backend address `1`. MultiThread converts the 1-based command address to the Qt Modbus zero-based address internally.

## Recommended status handling

Treat backend statuses like this:

```text
accepted        -> command accepted, keep UI busy/verifying
confirmed       -> write succeeded and read-back matched
readback_failed -> error
 timeout         -> error
```
