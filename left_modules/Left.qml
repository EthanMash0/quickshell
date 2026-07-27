import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
	WrapperMouseArea {
		leftMargin: 16
		cursorShape: Qt.PointingHandCursor

		onClicked: Quickshell.execDetached(["alacritty", "-e", "btop"])

		BtopWidget {}
	}

	WrapperItem {
		leftMargin: 16

		WorkspacesWidget {}
	}
}
