import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

PopupWindow {
	id: root
	color: "transparent"
	implicitWidth: previews.implicitWidth + 16
	implicitHeight: previews.implicitHeight + 16

	property var windows: []

	function show(wins, anchorItem) {
		root.windows = wins
		anchor.item = anchorItem
		anchor.updateAnchor()
		cancelHide()
		visible = true
	}

	function hide() {
		hideTimer.stop()
		visible = false
		windows = []
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop()
	}

	anchor {
		edges: Edges.Bottom
		gravity: Edges.Bottom

		margins.top: 40
	}

	Timer {
		id: hideTimer
		interval: 200
		onTriggered: root.hide()
	}

	WrapperRectangle {
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

		RowLayout {
			id: previews

			Repeater {
				model: windows

				// adds radius to child
				ClippingWrapperRectangle {
					required property var modelData // passed from repeater to child
					radius: 4
					border.color: "#ebdbb2"
					border.width: 1

					ScreencopyView {
						captureSource: modelData
						live: true
						constraintSize: Qt.size(500, 300)

						MouseArea {
							cursorShape: Qt.PointingHandCursor
							anchors.fill: parent
							onClicked: modelData.activate()
						}
					}
				}
			}
		}
	}
}
