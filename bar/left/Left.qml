import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"
import "../../prefs"

RowLayout {
	id: root
	spacing: 2
	visible: Prefs.barShowLeft && (Prefs.barShowPower || Prefs.barShowWorkspaces)

	function dismissPower() {
		if (!Prefs.barShowLeft || !Prefs.barShowPower)
			systemStatePopup.hide()
	}

	Connections {
		target: Prefs
		function onBarShowLeftChanged() { root.dismissPower() }
		function onBarShowPowerChanged() { root.dismissPower() }
	}

	//---------------------------
	// system power state widget
	//---------------------------
	SystemStatePopup {
		id: systemStatePopup
	}

	WrapperRectangle {
		visible: Prefs.barShowPower
		Layout.leftMargin: 8
		id: bg
		color: "#bb181818"
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
				// color: systemStateHover.hovered
				// 		? Theme.hover
				// 		: "transparent"
				color: "transparent"
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
		visible: Prefs.barShowWorkspaces
		id: workspaces
		color: "#bb181818"
		rightMargin: 12
		leftMargin: 12
		implicitHeight: 40
		radius: workspaces.implicitHeight / 2

		WorkspacesWidget {}
	}
}
