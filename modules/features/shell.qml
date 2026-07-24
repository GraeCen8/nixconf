import Quickshell
import Quickshell.Wayland
import Quickshell.Services.Pipewire
import Quickshell.Services.UPower
import Quickshell.Io
import QtQuick
import QtQuick.Layouts

PanelWindow {
    id: root

    anchors.top: true
    anchors.left: true
    anchors.right: true
    implicitHeight: 32
    color: "transparent"

    property string fontFamily: "JetBrainsMono Nerd Font"
    property int fontSize: 14

    PwObjectTracker {
        objects: [Pipewire.defaultAudioSink]
    }

    property bool wifiConnected: false

    Process {
        id: wifiStatus
        command: ["nmcli", "-t", "-f", "WIFI", "general"]

        stdout: StdioCollector {
            onStreamFinished: {
                root.wifiConnected = text.trim() === "enabled"
            }
        }

        onRunningChanged: {
            if (!running && wifiPoll.running) {
                wifiPoll.restart()
            }
        }
    }

    Timer {
        id: wifiPoll
        interval: 5000
        running: true
        repeat: true
        onTriggered: wifiStatus.running = true
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: 8
        spacing: 18

        //left icons

        Rectangle {
		width: 50
		height: 24
		radius: 4
		color: "#333333"

		Rectangle {
			width: parent.width * UPower.displayDevice.percentage
			height: parent.height
			radius: parent.radius
			color: "#ffffff"
		}

		Text {
			anchors.centerIn: parent
			text: Math.round(UPower.displayDevice.percentage*100) + "%"
			color: "black"
		}
	}

        Text {
            id: clock
            text: Qt.formatDateTime(new Date(), "HH:mm")

            color: "white"
            font.family: root.fontFamily
            font.pixelSize: root.fontSize

            Timer {
                interval: 1000
                running: true
                repeat: true
                onTriggered: clock.text = Qt.formatDateTime(new Date(), "HH:mm")
            }
        }

        Item { Layout.fillWidth: true }

        //right icons

        Text {
            text: "󰂯"
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Quickshell.execDetached(["alacritty", "--class", "centre-float", "-e", "bluetuith"])
                }
            }
        }

        Text {
            property var sink: Pipewire.defaultAudioSink
            property real volume: sink?.audio?.volume ?? 0
            property bool muted: sink?.audio?.muted ?? false

            text: muted
                ? "󰝟"
                : volume <= 0.01
                    ? "󰖁"
                    : volume < 0.34
                        ? "󰕿"
                        : volume < 0.67
                            ? "󰖀"
                            : "󰕾"

            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Quickshell.execDetached(["alacritty", "--class", "centre-float", "-e", "wiremix"])
                }
            }
        }

        Text {
            text: ""
            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Quickshell.execDetached(["alacritty", "--class", "centre-float", "-e", "btop"])
                }
            }
        }

        Text {
            id: wifi
            text: root.wifiConnected ? "󰖩" : "󰖪"

            color: "white"
            font.family: root.fontFamily
            font.pixelSize: 16

            MouseArea {
                anchors.fill: parent
                onClicked: {
                    Quickshell.execDetached(["alacritty", "--class", "centre-float", "-e", "nmtui"])
                }
            }
        }
    }
}
