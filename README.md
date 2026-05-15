# CHRONOS-7 Display - Qt Design Studio Project

This is the corrected Qt Design Studio export for the CHRONOS-7 display.

## Important change from the previous export

The display screen is no longer a top-level `ApplicationWindow`/`Window` component.
The runtime window is only in:

```text
ClientUiContent/App.qml
```

The actual display is an embeddable component:

```text
ClientUiContent/ChronosDashboard.qml
ClientUiContent/ChronosDashboardForm.ui.qml
```

This matches the `qt-display-client` pattern: `.ui.qml` files hold the visual form, while `.qml` files wrap the form and add behavior.

## Open in Qt Design Studio

Open:

```text
ChronosDisplay.qmlproject
```

The project declares:

```qml
mainFile: "ClientUiContent/App.qml"
mainUiFile: "ClientUiContent/ChronosDashboardForm.ui.qml"
```

## Build standalone preview

```bash
cmake -S . -B build -DCMAKE_PREFIX_PATH=/path/to/Qt/6.x
cmake --build build
./build/appChronosDisplay
```

## Integration into qt-display-client

Copy these folders into `qt-display-client`:

```text
ClientUi/Chronos*.qml
ClientUi/StatusLed.qml
ClientUi/SeverityTag.qml
ClientUi/SignalBars.qml
ClientUi/MinuteDial.qml
ClientUi/DriftHistogram.qml
ClientUi/*Card.qml
ClientUi/SiteRow.qml
ClientUi/AlarmRow.qml
ClientUi/AuditLine.qml
ClientUi/CommandToast.qml
ClientUiContent/Chronos*.qml
ClientUiContent/*Screen.qml
ClientUiContent/*ScreenForm.ui.qml
```

Do not copy/replace `ClientUiContent/App.qml` unless you want to run this as a standalone preview. In the real `qt-display-client`, the existing `App.qml` should remain the only `Window`.
