import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"

RowLayout {
	Text {
		color: Theme.text
		font.pixelSize: Theme.fontSize(18)
		text: ""
	}

	ColumnLayout {
		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(12)
			font.bold: true
			text: `${SystemUsage.ramPercent}%`
			bottomPadding: -6
		}

		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(10)
			text: "RAM  "
		}
	}
}
