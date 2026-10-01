import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"
import "../../prefs"

RowLayout {
	id: root
	spacing: 2
	visible: Prefs.barShowRight
			&& (Prefs.barShowUsage || Prefs.barShowTray || Prefs.barShowControlCenter || Prefs.barShowClock)

	function dismissControlCenter() {
		if (!Prefs.barShowRight || !Prefs.barShowControlCenter)
			controlCenterPopup.hide()
	}

	Connections {
		target: Prefs
		function onBarShowRightChanged() { root.dismissControlCenter() }
		function onBarShowControlCenterChanged() { root.dismissControlCenter() }
	}

	WrapperRectangle {
		visible: Prefs.barShowUsage
		id: systemUsageBG
		color: "#bb181818"
		rightMargin: 4
		leftMargin: 4
		// rightMargin: 12
		// leftMargin: 12
		implicitHeight: 40
		radius: systemUsageBG.implicitHeight / 2

		RowLayout {
			spacing: 0
			
			//---------------------
			// system usage widget
			//---------------------
			WrapperMouseArea {
				id: systemUsage
				implicitHeight: systemUsageBG.height - 8
				cursorShape: Qt.PointingHandCursor
				onClicked: Prefs.run(Prefs.systemMonitorCommand)

				HoverHandler {
					id: systemUsageHover
				}

				// hover background
				WrapperRectangle {
					// color: systemUsageHover.hovered
					// 		? Theme.hover
					// 		: "transparent"
					color: "transparent"
					// color: Theme.hover
					radius: systemUsageBG.radius
					rightMargin: 16
					leftMargin: 16
					// rightMargin: 8
					// leftMargin: 8

					RowLayout {
						id: stats
						spacing: 16

						GPUWidget {}
						VRAMWidget {}
						CPUWidget {}
						RAMWidget {}
					}
				}
			}
		}
	}

	WrapperRectangle {
		visible: Prefs.barShowTray || Prefs.barShowControlCenter || Prefs.barShowClock
		id: bg
		color: "#bb181818"
		Layout.rightMargin: 8
		rightMargin: 12
		leftMargin: 12
		implicitHeight: 40
		radius: bg.implicitHeight / 2
		RowLayout {
			spacing: 0

			//--------------------
			// system tray widget
			//--------------------
			WrapperItem {
				visible: Prefs.barShowTray
				rightMargin: 8

				SystemTrayWidget {}
			}
			
			//-----------------------
			// control center widget
			//-----------------------
			ControlCenterPopup {
				id: controlCenterPopup
			}

			WrapperMouseArea {
				id: controlCenter
				visible: Prefs.barShowControlCenter
				implicitHeight: bg.height - 8
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
				WrapperRectangle {
					color: controlCenterHover.hovered
							? Theme.hover
							: "transparent"
					radius: Theme.radiusSmall
					rightMargin: 8
					leftMargin: 8

					RowLayout {
						id: controls
						spacing: 16

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
				visible: Prefs.barShowClock
				implicitHeight: bg.height - 8
				cursorShape: Qt.PointingHandCursor
				onClicked: Prefs.run(Prefs.calendarCommand)

				HoverHandler {
					id: dateTimeHover
				}

				// hover background
				WrapperRectangle {
					color: dateTimeHover.hovered
							? Theme.hover
							: "transparent"
					radius: Theme.radiusSmall
					rightMargin: 8
					leftMargin: 8
					implicitHeight: bg.height

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
	}
}
