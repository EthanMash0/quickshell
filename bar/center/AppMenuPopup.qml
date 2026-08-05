import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland

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
	property var windows: []
	property var entry: null // selected desktop entry
	property bool pinned: false // entry pinned status

	//-------------
	// show / hide
	//-------------
	function show(anchorItem, windows, entry, pinned) {
		root.anchorItem = anchorItem
		root.windows = windows
		root.entry = entry
		root.pinned = pinned

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
		root.entry = null
		root.windows = []
		root.anchorItem = null
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop()
	}

	// accounts for selecting a different app icon
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

	// dismiss
	Shortcut {
		sequence: "Escape"
		enabled: root.visible
		context: Qt.WindowShortcut
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
		border.color: "#ebdbb2"
		border.width: 1

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
			spacing: 4

			// app name header
			Text {
				Layout.fillWidth: true
				rightPadding: 4
				leftPadding: 4
				color: "#88ebdbb2"
				font.pixelSize: 11
				elide: Text.ElideRight
				text: root.entry 
						? (root.entry.name || root.entry.id) 
						: ""
			}

			//-----------
			// close all
			//-----------
			WrapperMouseArea {
				visible: root.windows.length > 0
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					DockState.closeAll(root.windows)
					root.hide()
				}

				HoverHandler {
					id: closeHover
				}

				Rectangle {
					radius: 4
					color: closeHover.hovered
							? "#22ebdbb2"
							: "transparent"
					implicitWidth: 160
					implicitHeight: 24

					Text {
						anchors.verticalCenter: parent.verticalCenter
						leftPadding: 4
						color: "#ebdbb2"
						font.pixelSize: 14
						text: "   Close all windows"
					}
				}
			}

			//-------------
			// pin / unpin
			//-------------
			WrapperMouseArea {
				cursorShape: Qt.PointingHandCursor
				onClicked: {
					if (!root.entry) return

					if (root.pinned) {
						DockState.unpin(root.entry.id)
					} else {
						DockState.pin(root.entry.id)
					}
					root.hide()
				}

				HoverHandler {
					id: pinHover
				}

				Rectangle {
					radius: 4
					color: pinHover.hovered
								? "#22ebdbb2"
								: "transparent"
					implicitWidth: 160
					implicitHeight: 24

					Text {
						anchors.verticalCenter: parent.verticalCenter
						leftPadding: 4
						color: "#ebdbb2"
						font.pixelSize: 14
						text: root.pinned
								? "󰐄   Remove from bar"
								: "󰐃   Keep in bar"
					}
				}
			}
		}
	}
}
