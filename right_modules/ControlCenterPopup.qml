import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
	id: root
	color: "transparent"
	implicitWidth: utilities.implicitWidth + 16
	implicitHeight: utilities.implicitHeight + 16

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

	MouseArea {
		anchors.fill: parent
		hoverEnabled: true
		acceptedButtons: Qt.NoButton
		onEntered: root.cancelHide()
		onExited: root.scheduleHide()
	}

	WrapperRectangle {
		id: utilities
		margin: 8
		radius: 8
		color: "#bb181818"

		RowLayout {
			spacing: 8

			WrapperMouseArea {
				onClicked: Quickshell.execDetached(["alacritty", "-e", "pipemixer"])

				WrapperRectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					Item {
						anchors.fill: parent

						AudioWidget {
							anchors.centerIn: parent
						}

						Text {
							color: "#ebdbb2"
							font.pixelSize: 12
							text: "Audio"
							anchors.bottom: parent.bottom
							anchors.horizontalCenter: parent.horizontalCenter
							bottomPadding: 4
						}
					}
				}
			}

			WrapperMouseArea {
				onClicked: Quickshell.execDetached(["alacritty", "-e", "bluetui"])

				WrapperRectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					Item {
						anchors.fill: parent

						BluetoothWidget {
							anchors.centerIn: parent
						}

						Text {
							color: "#ebdbb2"
							font.pixelSize: 12
							text: "Bluetooth"
							anchors.bottom: parent.bottom
							anchors.horizontalCenter: parent.horizontalCenter
							bottomPadding: 4
						}
					}
				}
			}

			WrapperMouseArea {
				onClicked: Quickshell.execDetached(["alacritty", "-e", "gazelle"])

				WrapperRectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					Item {
						anchors.fill: parent

						NetworkWidget {
							anchors.centerIn: parent
						}

						Text {
							color: "#ebdbb2"
							font.pixelSize: 12
							text: "Network"
							anchors.bottom: parent.bottom
							anchors.horizontalCenter: parent.horizontalCenter
							bottomPadding: 4
						}
					}
				}
			}
		}
	}
}
