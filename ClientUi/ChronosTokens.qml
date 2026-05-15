pragma Singleton
import QtQuick

QtObject {
    readonly property color background: "#101820"
    readonly property color backgroundGrid: "#18242D"
    readonly property color panel: "#141D24"
    readonly property color panelDark: "#0B1319"
    readonly property color panelHover: "#1D2A34"
    readonly property color panelActive: "#22323D"
    readonly property color panelBorder: "#31424C"
    readonly property color panelBorderDim: "#22313A"

    readonly property color foreground: "#E6EEF2"
    readonly property color mutedText: "#8A9AA5"
    readonly property color faintText: "#5E707A"

    readonly property color ok: "#35D07F"
    readonly property color warn: "#E3B341"
    readonly property color crit: "#EF5B45"
    readonly property color info: "#5DA9E9"
    readonly property color terminalBackground: "#071015"

    readonly property int radiusSmall: 2
    readonly property int radiusMedium: 4
    readonly property int spacingXs: 4
    readonly property int spacingSm: 8
    readonly property int spacingMd: 12
    readonly property int spacingLg: 16
    readonly property int spacingXl: 24

    readonly property int topBarHeight: 64
    readonly property int tabBarHeight: 56
    readonly property int statusBarHeight: 32
    readonly property int rowHeight: 42

    readonly property string monoFont: "monospace"
    readonly property string title: "CHRONOS-7"
    readonly property string subtitle: "PLC Minute Operations - Modbus TCP / 4G"
}
