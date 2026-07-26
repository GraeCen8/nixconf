import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick
import QtQuick.Layouts
import QtQuick.Window

PanelWindow {
    id: root

    implicitWidth: 600
    implicitHeight: 32
    color: "transparent"
    exclusionMode: ExclusionMode.Ignore

    x: (Screen.width - width) / 2
    y: 6

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    property color bg: "#2e3440"
    property color surface: "#3b4252"
    property color dim: "#4c566a"
    property color fg: "#d8dee9"
    property color accent: "#81a1c1"
    property color green: "#a3be8c"
    property color red: "#bf616a"
    property color yellow: "#ebcb8b"

    property var rawWorkspaces: []
    property int activeWorkspace: -1
    property int cpuUsage: 0
    property var lastCpuIdle: 0
    property var lastCpuTotal: 0
    property int diskUsagePercent: 0

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    Process {
        id: workspaceProc
        command: ["niri", "msg", "-j", "workspaces"]
        stdout: StdioCollector {
            onStreamFinished: {
                try {
                    var data = JSON.parse(text)
                    rawWorkspaces = data
                    for (var i = 0; i < data.length; i++) {
                        if (data[i].is_focused) {
                            activeWorkspace = data[i].idx
                            break
                        }
                    }
                } catch (e) {}
            }
        }
        onRunningChanged: {
            if (!running && workspaceTimer.running)
                workspaceTimer.restart()
        }
    }

    Timer {
        id: workspaceTimer
        interval: 500
        running: true
        repeat: true
        onTriggered: workspaceProc.running = true
    }

    FileView {
        id: cpuStatFile
        path: "/proc/stat"
        watchChanges: true
        onFileChanged: reload()
    }

    Timer {
        interval: 2000
        running: true
        repeat: true
        onTriggered: {
            var lines = cpuStatFile.text().split("\n")
            if (lines.length < 1) return
            var parts = lines[0].trim().split(/\s+/)
            if (parts.length < 5) return
            var idle = parseInt(parts[4]) + parseInt(parts[5])
            var total = 0
            for (var i = 1; i < 8; i++)
                total += parseInt(parts[i]) || 0
            if (lastCpuTotal > 0) {
                var dIdle = idle - lastCpuIdle
                var dTotal = total - lastCpuTotal
                if (dTotal > 0) {
                    cpuUsage = Math.round(100 * (1 - dIdle / dTotal))
                    if (cpuUsage < 0) cpuUsage = 0
                    if (cpuUsage > 100) cpuUsage = 100
                }
            }
            lastCpuTotal = total
            lastCpuIdle = idle
        }
    }

    Process {
        id: diskProc
        command: ["df", "--output=pcent", "/"]
        stdout: SplitParser {
            onRead: data => {
                if (!data || data.startsWith("Use")) return
                diskUsagePercent = parseInt(data.trim().replace("%", "")) || 0
            }
        }
        onRunningChanged: {
            if (!running && diskTimer.running)
                diskTimer.restart()
        }
    }

    Timer {
        id: diskTimer
        interval: 10000
        running: true
        repeat: true
        onTriggered: diskProc.running = true
    }

    Component.onCompleted: {
        workspaceProc.running = true
        diskProc.running = true
    }

    Rectangle {
        anchors.fill: parent
        color: bg
        radius: 10

        Rectangle {
            anchors.fill: parent
            anchors.margins: -1
            color: "transparent"
            radius: 12
            border.color: "#15ffffff"
            border.width: 1
            z: -1
        }

        RowLayout {
            anchors.fill: parent
            anchors.leftMargin: 12
            anchors.rightMargin: 12
            spacing: 12

            RowLayout {
                spacing: 6
                Layout.alignment: Qt.AlignVCenter

                Repeater {
                    model: rawWorkspaces.length

                    Rectangle {
                        width: 24
                        height: 24
                        radius: 6
                        color: rawWorkspaces[index].idx === activeWorkspace ? accent : dim

                        Behavior on color {
                            ColorAnimation { duration: 200 }
                        }

                        Text {
                            anchors.centerIn: parent
                            text: rawWorkspaces[index].idx
                            color: rawWorkspaces[index].idx === activeWorkspace ? bg : fg
                            font.family: root.fontFamily
                            font.pixelSize: 12
                            font.bold: rawWorkspaces[index].idx === activeWorkspace

                            Behavior on color {
                                ColorAnimation { duration: 200 }
                            }
                        }

                        MouseArea {
                            anchors.fill: parent
                            cursorShape: Qt.PointingHandCursor
                            onClicked: {
                                Quickshell.execDetachable(["niri", "msg", "action", "focus-workspace", String(rawWorkspaces[index].idx)])
                            }
                        }
                    }
                }
            }

            Item { Layout.fillWidth: true }

            Text {
                id: clockDisplay
                text: Qt.formatDateTime(new Date(), "HH:mm")
                color: fg
                font.family: root.fontFamily
                font.pixelSize: root.fontSize + 2

                Timer {
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: clockDisplay.text = Qt.formatDateTime(new Date(), "HH:mm")
                }
            }

            Item { Layout.fillWidth: true }

            RowLayout {
                spacing: 12
                Layout.alignment: Qt.AlignVCenter

                Text {
                    property var battery: UPower.displayDevice
                    property real pct: battery.percentage ?? 0
                    property bool charging: battery.state === 1
                    text: {
                        var icon
                        if (charging) icon = "\uf0e7"
                        else if (pct <= 0.1) icon = "\uf5d0"
                        else if (pct <= 0.2) icon = "\uf579"
                        else if (pct <= 0.3) icon = "\uf57a"
                        else if (pct <= 0.4) icon = "\uf57b"
                        else if (pct <= 0.5) icon = "\uf57c"
                        else if (pct <= 0.6) icon = "\uf57d"
                        else if (pct <= 0.7) icon = "\uf57e"
                        else if (pct <= 0.8) icon = "\uf57f"
                        else if (pct <= 0.9) icon = "\uf580"
                        else icon = "\uf581"
                        return icon + " " + Math.round(pct * 100) + "%"
                    }
                    color: charging ? green : pct <= 0.2 ? red : fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize
                    visible: UPower.available
                }

                Text {
                    text: "\uf57f " + cpuUsage + "%"
                    color: cpuUsage > 80 ? red : cpuUsage > 60 ? yellow : fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetachable(["alacritty", "--class", "centre-float", "-e", "btop"])
                    }
                }

                Text {
                    text: "\uf2d1 " + diskUsagePercent + "%"
                    color: diskUsagePercent > 85 ? red : diskUsagePercent > 70 ? yellow : fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetachable(["alacritty", "--class", "centre-float", "-e", "btop"])
                    }
                }

                Text {
                    property var sink: Pipewire.defaultAudioSink
                    property real vol: sink?.audio?.volume ?? 0
                    property bool muted: sink?.audio?.muted ?? false
                    text: {
                        var icon
                        if (muted) icon = "\uf58d"
                        else if (vol <= 0.01) icon = "\uf581"
                        else if (vol < 0.34) icon = "\uf57f"
                        else if (vol < 0.67) icon = "\uf580"
                        else icon = "\uf581"
                        return icon + " " + Math.round(vol * 100) + "%"
                    }
                    color: muted ? red : fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetachable(["alacritty", "--class", "centre-float", "-e", "wiremix"])
                    }
                }

                Text {
                    text: "\uf5af"
                    color: fg
                    font.family: root.fontFamily
                    font.pixelSize: root.fontSize

                    MouseArea {
                        anchors.fill: parent
                        cursorShape: Qt.PointingHandCursor
                        onClicked: Quickshell.execDetachable(["alacritty", "--class", "centre-float", "-e", "bluetuith"])
                    }
                }
            }
        }
    }
}
