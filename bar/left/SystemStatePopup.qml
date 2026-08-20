import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "../../theme"

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

		const screen = anchorItem.Window.window?.screen
		if (screen) {
			root.screen = screen
		}

		cancelHide()
		root.visible = true
		Qt.callLater(root.reposition)
	}

	function hide() {
		root.visible = false
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

		menu.x = local.x
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
		radius: Theme.radius
		color: Theme.surface
		border.color: Theme.border
		border.width: Theme.borderWidth

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
					radius: Theme.radiusSmall
					color: sleepHover.hovered
							? Theme.hover
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(14)
						text: "Sleep"
						leftPadding: 4
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}

			//--------------
			// hibernate button
			//--------------
			WrapperMouseArea {
				id: hibernateButton
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					root.hide()

					Quickshell.execDetached([
						"sh",
						"-c",
						"systemctl hibernate"
					])
				}

				HoverHandler {
					id: hibernateHover
				}

				Rectangle {
					radius: Theme.radiusSmall
					color: hibernateHover.hovered
							? Theme.hover
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(14)
						text: "Hibernate"
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
					radius: Theme.radiusSmall
					color: restartHover.hovered
							? Theme.hover
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(14)
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
					radius: Theme.radiusSmall
					color: shutDownHover.hovered
							? Theme.hover
							: "transparent"
					implicitWidth: 80
					implicitHeight: 24

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(14)
						text: "Shut Down"
						leftPadding: 4
						anchors.verticalCenter: parent.verticalCenter
					}
				}
			}
		}
	}
}
