import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
	id: root
	spacing: 0

	WrapperItem {
		rightMargin: 8

		SystemTrayWidget {}
	}
	
	WrapperMouseArea {
		id: systemUsage
		property string backgroundColor: "transparent"

		hoverEnabled: true
		onEntered: systemUsage.backgroundColor = "#22ebdbb2"
		onExited: systemUsage.backgroundColor = "transparent"
		onClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])

		Rectangle {
			color: systemUsage.backgroundColor
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

	ControlCenterPopup {
		id: controlCenterPopup
	}

	WrapperMouseArea {
		id: controlCenter
		property string backgroundColor: "transparent"

		hoverEnabled: true
		onEntered: {
			controlCenter.backgroundColor = "#22ebdbb2"
			controlCenterPopup.cancelHide()
		}
		onExited: {
			controlCenter.backgroundColor = "transparent"
			controlCenterPopup.scheduleHide()
		}
		onClicked: {
			if (controlCenterPopup.visible) {
				controlCenterPopup.hide()
			} else {
				controlCenterPopup.show(controlCenter)	
			}
		}

		Rectangle {
			color: controlCenter.backgroundColor
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

	WrapperMouseArea {
		id: dateTime
		rightMargin: 8
		property string backgroundColor: "transparent"

		hoverEnabled: true
		onEntered: dateTime.backgroundColor = "#22ebdbb2"
		onExited: dateTime.backgroundColor = "transparent"
		onClicked: Quickshell.execDetached(["gnome-calendar"])

		Rectangle {
			color: dateTime.backgroundColor
			radius: 8
			implicitWidth: clock.implicitWidth + 16
			implicitHeight: clock.implicitHeight + 14

			RowLayout {
				id: clock
				spacing: 16
				anchors.centerIn: parent

				ClockWidget {}
			}
		}
	}
}
