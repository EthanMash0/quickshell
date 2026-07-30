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
	}

	/* 
	 * Offsets y position from the top of the screen by the height 
	 * of the PanelWindow in Bar.qml 
	 */
	anchor.rect.y: parentWindow.height

	Timer {
		id: hideTimer
		interval: 200
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
		margin: 8
		radius: 8
		color: "#ee181818"

		RowLayout {
			id: previews

			Repeater {
				model: windows

				ScreencopyView {
					required property var modelData
					captureSource: modelData
					live: true
					constraintSize: Qt.size(500, 300)

					MouseArea {
						anchors.fill: parent
						onClicked: modelData.activate()
					}
				}
			}
		}

	}
}


