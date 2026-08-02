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
			anchors.verticalCenter: parent.verticalCenter

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

	WrapperMouseArea {
		id: controlCenter
		property string backgroundColor: "transparent"

		hoverEnabled: true
		onEntered: controlCenter.backgroundColor = "#22ebdbb2"
		onExited: controlCenter.backgroundColor = "transparent"
		onClicked: {
			Quickshell.execDetached(["alacritty", "-e", "pipemixer"])
			Quickshell.execDetached(["alacritty", "-e", "bluetui"])
			Quickshell.execDetached(["alacritty", "-e", "gazelle"])
		}

		Rectangle {
			color: controlCenter.backgroundColor
			radius: 8
			implicitWidth: controls.implicitWidth + 16
			implicitHeight: controls.implicitHeight + 12
			anchors.verticalCenter: parent.verticalCenter

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
			anchors.verticalCenter: parent.verticalCenter

			RowLayout {
				id: clock
				spacing: 16
				anchors.centerIn: parent

				ClockWidget {}
			}
		}
	}
}
