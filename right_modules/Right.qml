import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {

	WrapperItem {
		rightMargin: 8

		SystemTrayWidget {}
	}
	
	WrapperMouseArea {
		id: root
		rightMargin: 8
		property string backgroundColor: "transparent"

		hoverEnabled: true
		onEntered: root.backgroundColor = "#22ebdbb2"
		onExited: root.backgroundColor = "transparent"
		onClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])

		Rectangle {
			id: hoverBackground
			color: root.backgroundColor
			radius: 8
			implicitWidth: systemStats.implicitWidth + 16
			implicitHeight: systemStats.implicitHeight + 8

			RowLayout {
				id: systemStats
				spacing: 16
				anchors.centerIn: parent

				GPUWidget {}
				CPUWidget {}
				RAMWidget {}
			}
		}
	}

	WrapperMouseArea {
		rightMargin: 16
		cursorShape: Qt.PointingHandCursor

		onClicked: Quickshell.execDetached(["alacritty", "-e", "pipemixer"])

		AudioWidget {}
	}

	WrapperMouseArea {
		rightMargin: 16
		cursorShape: Qt.PointingHandCursor

		onClicked: Quickshell.execDetached(["alacritty", "-e", "bluetui"])

		BluetoothWidget {}
	}

	WrapperMouseArea {
		rightMargin: 16
		cursorShape: Qt.PointingHandCursor

		onClicked: Quickshell.execDetached(["alacritty", "-e", "gazelle"])

		NetworkWidget {}
	}

	WrapperItem {
		rightMargin: 16

		ClockWidget {}
	}
}
