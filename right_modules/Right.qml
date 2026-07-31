import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {

	WrapperItem {
		rightMargin: 16

		SystemTrayWidget {}
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
