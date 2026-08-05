import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PanelWindow {
	id: root

	color: "transparent"
	visible: false

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay

	onWidthChanged: if (visible) root.reposition()
	onHeightChanged: if (visible) root.reposition()

	//-------------------
	// public properties
	//-------------------
	property var anchorItem: null
	
	//-------------
	// show / hide
	//-------------
	function show(anchorItem) {
		root.anchorItem = anchorItem

		cancelHide()
		visible = true
		Qt.callLater(root.reposition)
	}

	function hide() {
		visible = false
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop() 
	}

	function reposition() {
		if (!root.anchorItem || !root.visible) {
			return
		}

		const item = root.anchorItem
		// below the icon, horizontally centered on it
		const g = item.mapToGlobal(0, item.height)
		const local = root.contentItem.mapFromGlobal(g.x, g.y) 

		menu.x = local.x + (item.width - menu.width) / 2
		menu.y = local.y + 8
	}

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	Timer {
		id: hideTimer
		interval: 400
		onTriggered: root.hide()
	}
	
	// close menu on outside click
	MouseArea {
		anchors.fill: parent
		onClicked: root.hide()
	}

	WrapperRectangle {
		id: menu
		margin: 8
		radius: 8
		color: "#181818"
		// border.color: "#ebdbb2"
		// border.width: 1

		HoverHandler {
			onHoveredChanged: {
				if (hovered) {
					root.cancelHide()
				} else {
					root.scheduleHide()
				}
			}
		}

		RowLayout {
			spacing: 8

			//--------------
			// audio button
			//--------------
			WrapperMouseArea {
				cursorShape: Qt.PointingHandCursor
				onClicked: Quickshell.execDetached(["alacritty", "-e", "pipemixer"])

				HoverHandler {
					id: audioHover
				}

				// border and hover background
				Rectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: audioHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					// rectangle type only supports one child
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

			//------------------
			// bluetooth button
			//------------------
			WrapperMouseArea {
				cursorShape: Qt.PointingHandCursor
				onClicked: Quickshell.execDetached(["alacritty", "-e", "bluetui"])

				HoverHandler {
					id: bluetoothHover
				}

				// border and hover background
				Rectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: bluetoothHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					// rectangle type only supports one child
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

			//-------------
			// wifi button
			//-------------
			WrapperMouseArea {
				cursorShape: Qt.PointingHandCursor
				onClicked: Quickshell.execDetached(["alacritty", "-e", "gazelle"])

				HoverHandler {
					id: wifiHover
				}

				// border and hover background
				Rectangle {
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1
					color: wifiHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 64
					implicitHeight: 48

					// rectangle type only supports one child
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
