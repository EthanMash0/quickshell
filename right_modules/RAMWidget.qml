import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
	Text {
		color: "#ebdbb2"
		font.pixelSize: 18
		text: ""
	}

	ColumnLayout {
		Text {
			color: "#ebdbb2"
			font.pixelSize: 12
			font.bold: true
			text: "100%"
			bottomPadding: -6
		}

		Text {
			color: "#ebdbb2"
			font.pixelSize: 10
			text: "RAM"
		}
	}
}
