import QtQuick
import QtQuick.Layouts
import "."

Item {
    id: root
    property var values: []
    property int binsMin: -10
    property int binsMax: 10
    implicitHeight: 220

    function counts() {
        var out = []
        for (var b = binsMin; b <= binsMax; b++) out.push(0)
        for (var i = 0; i < values.length; i++) {
            var v = Math.max(binsMin, Math.min(binsMax, values[i]))
            out[v - binsMin]++
        }
        return out
    }

    function maxCount(arr) {
        var m = 1
        for (var i = 0; i < arr.length; i++) if (arr[i] > m) m = arr[i]
        return m
    }

    ColumnLayout {
        anchors.fill: parent
        anchors.margins: 12
        spacing: 6

        Item {
            id: chartArea
            Layout.fillWidth: true
            Layout.fillHeight: true

            property var localCounts: root.counts()
            property int localMax: root.maxCount(localCounts)

            Row {
                anchors.fill: parent
                spacing: 3

                Repeater {
                    model: chartArea.localCounts.length
                    delegate: Item {
                        width: Math.max(8, (chartArea.width - 3 * 20) / 21)
                        height: chartArea.height
                        property int bin: root.binsMin + index
                        property int count: chartArea.localCounts[index]
                        property string severity: bin === 0 ? "ok" : Math.abs(bin) >= 5 ? "crit" : "warn"
                        property color barColor: severity === "crit" ? ChronosTokens.crit : severity === "warn" ? ChronosTokens.warn : ChronosTokens.ok

                        Rectangle {
                            width: parent.width
                            height: Math.max(2, parent.count / chartArea.localMax * (parent.height - 24))
                            anchors.bottom: label.top
                            radius: 1
                            color: Qt.rgba(parent.barColor.r, parent.barColor.g, parent.barColor.b, 0.75)
                        }

                        Text {
                            id: label
                            anchors.bottom: parent.bottom
                            anchors.horizontalCenter: parent.horizontalCenter
                            text: parent.bin === 0 ? "0" : parent.bin > 0 ? "+" + parent.bin : parent.bin
                            color: ChronosTokens.faintText
                            font.pixelSize: 8
                            font.family: ChronosTokens.monoFont
                        }
                    }
                }
            }
        }

        Text {
            Layout.alignment: Qt.AlignHCenter
            text: "DRIFT MINUTES - PLC MINUS UTC"
            color: ChronosTokens.faintText
            font.pixelSize: 9
            font.letterSpacing: 2
            font.family: ChronosTokens.monoFont
        }
    }

    onValuesChanged: chartArea.localCounts = root.counts()
}
