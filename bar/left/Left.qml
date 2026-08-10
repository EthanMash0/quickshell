import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"

RowLayout {
	id: root
	spacing: 2

	//---------------------------
	// system power state widget
	//---------------------------
	SystemStatePopup {
		id: systemStatePopup
	}

	WrapperRectangle {
		id: bg
		color: "#bb181818"
		Layout.leftMargin: 8
		margin: 4
		implicitWidth: 40
		implicitHeight: 40
		radius: bg.implicitHeight / 2

		WrapperMouseArea {
			id: systemStateButton
			anchors.centerIn: parent
			cursorShape: Qt.PointingHandCursor
			onClicked: {
				if (systemStatePopup.visible) {
					systemStatePopup.hide()
				} else {
					systemStatePopup.show(systemStateButton)
				}
			}

			HoverHandler {
				id: systemStateHover
				onHoveredChanged: {
					if (hovered) {
						systemStatePopup.cancelHide()
					} else {
						systemStatePopup.scheduleHide()
					}
				}
			}

			// hover background
			Rectangle {
				color: systemStateHover.hovered
						? Theme.hover
						: "transparent"
				radius: systemStateButton.height / 2

				// for future expansion (if desired)
				RowLayout {
					id: icon
					spacing: 16
					anchors.centerIn: parent

					SystemStateWidget {}
				}
			}
		}
	}
	
	//-------------------
	// workspaces widget
	//-------------------
	WrapperRectangle {
		id: workspaces
		color: "#bb181818"
		rightMargin: 16
		leftMargin: 16
		implicitHeight: 40
		radius: workspaces.implicitHeight / 2

		WorkspacesWidget {}
	}
}
