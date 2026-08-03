import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
	id: root
	spacing: 0

	//--------------------
	// system tray widget
	//--------------------
	WrapperItem {
		rightMargin: 8

		SystemTrayWidget {}
	}
	
	//---------------------
	// system usage widget
	//---------------------
	WrapperMouseArea {
		id: systemUsage
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])

		HoverHandler {
			id: systemUsageHover
		}

		// hover background
		Rectangle {
			color: systemUsageHover.hovered
					? "#22ebdbb2"
					: "transparent"
			radius: 8
			implicitWidth: stats.implicitWidth + 16
			implicitHeight: stats.implicitHeight + 6

			RowLayout {
				id: stats
				spacing: 16
				anchors.centerIn: parent
				GPUWidget {}
				CPUWidget {}
				RAMWidget {}
			}
		}
	}

	//-----------------------
	// control center widget
	//-----------------------
	ControlCenterPopup {
		id: controlCenterPopup
	}

	WrapperMouseArea {
		id: controlCenter
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			if (controlCenterPopup.visible) {
				controlCenterPopup.hide()
			} else {
				controlCenterPopup.show(controlCenter)	
			}
		}

		HoverHandler {
			id: controlCenterHover
			onHoveredChanged: {
				if (hovered) {
					controlCenterPopup.cancelHide()
				} else {
					controlCenterPopup.scheduleHide()
				}
			}
		}

		// hover background
		Rectangle {
			color: controlCenterHover.hovered
					? "#22ebdbb2"
					: "transparent"
			radius: 8
			implicitWidth: controls.implicitWidth + 16
			implicitHeight: controls.implicitHeight + 12

			RowLayout {
				id: controls
				spacing: 16
				anchors.centerIn: parent

				AudioWidget {}
				BluetoothWidget {}
				NetworkWidget {}
			}
		}
	}

	//--------------
	// clock widget
	//--------------
	WrapperMouseArea {
		id: dateTime
		rightMargin: 8
		cursorShape: Qt.PointingHandCursor
		onClicked: Quickshell.execDetached(["gnome-calendar"])

		HoverHandler {
			id: dateTimeHover
		}

		// hover background
		Rectangle {
			color: dateTimeHover.hovered
					? "#22ebdbb2"
					: "transparent"
			radius: 8
			implicitWidth: clock.implicitWidth + 16
			implicitHeight: clock.implicitHeight + 14

			// for future expansion (if desired)
			RowLayout {
				id: clock
				spacing: 16
				anchors.centerIn: parent

				ClockWidget {}
			}
		}
	}
}
