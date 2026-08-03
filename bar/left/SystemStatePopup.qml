import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
	id: root
	color: "transparent"
	implicitWidth: states.implicitWidth + 16
	implicitHeight: states.implicitHeight + 16

	function show(anchorItem) {
		anchor.item = anchorItem
		anchor.updateAnchor()
		cancelHide()
		visible = true
	}

	function hide() {
		hideTimer.stop()
		visible = false
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop() }

	anchor {
		edges: Edges.Bottom
		gravity: Edges.Bottom

		margins.top: 40
	}

	Timer {
		id: hideTimer
		interval: 400
		onTriggered: root.hide()
	}

	WrapperRectangle {
		id: states
		margin: 8
		radius: 8
		color: "#bb181818"

		HoverHandler {
			onHoveredChanged: {
				if (hovered) {
					root.cancelHide()
				} else {
					root.scheduleHide()
				}
			}
		}

		ColumnLayout {
			spacing: 8

			//--------------
			// sleep button
			//--------------
			WrapperMouseArea {
				id: sleepButton
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					root.hide()

					Quickshell.execDetached([
						"sh",
						"-c",
						"systemctl suspend"
					])
				}

				HoverHandler {
					id: sleepHover
				}

				Rectangle {
					radius: 4
					color: sleepHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: "#ebdbb2"
						font.pixelSize: 14
						text: "Sleep"
						leftPadding: 4
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}

			//----------------
			// restart button
			//----------------
			WrapperMouseArea {
				id: restartButton
				cursorShape: Qt.PointingHandCursor
				onClicked: Quickshell.execDetached(["systemctl", "reboot"])

				HoverHandler {
					id: restartHover
				}

				Rectangle {
					radius: 4
					color: restartHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: "#ebdbb2"
						font.pixelSize: 14
						text: "Restart"
						leftPadding: 4
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}

			//------------------
			// shut down button
			//------------------
			WrapperMouseArea {
				id: shutDownButton
				cursorShape: Qt.PointingHandCursor
				onClicked: Quickshell.execDetached(["systemctl", "poweroff"])

				HoverHandler {
					id: shutDownHover
				}

				Rectangle {
					radius: 4
					color: shutDownHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: "#ebdbb2"
						font.pixelSize: 14
						text: "Shut Down"
						leftPadding: 4
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}
		}
	}
}
