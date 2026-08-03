import QtQuick
import Quickshell
import Quickshell.Io

Scope {
	// Hyprland / CLI: qs ipc call launcher toggle
	IpcHandler {
		target: "launcher"

		function toggle(): void {
			LauncherState.toggle()
		}

		function show(): void {
			LauncherState.show()
		}

		function hide(): void {
			LauncherState.hide()
		}
	}

	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			screen: modelData

			// show on every monitor for now, later will be focused-only
			visible: LauncherState.open

			anchors {
				top: true
				bottom: true
				left: true
				right: true
			}

			color: "transparent"

			MouseArea {
				anchors.fill: parent
				onClicked: LauncherState.hide()
			}

			Rectangle {
				anchors.centerIn: parent
				width: 800
				height: 600
				radius: 8
				color: "#bb181818"
				border.color: "#ebdbb2"
				border.width: 1

				MouseArea {
					anchors.fill: parent
				}
			}
		}
	}
}
