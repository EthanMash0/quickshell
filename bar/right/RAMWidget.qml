import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"

RowLayout {
	Text {
		color: Theme.text
		font.pixelSize: Theme.fontSize(16)
		text: ""
	}

	ColumnLayout {
		spacing: -3

		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(12)
			font.bold: true
			text: `${SystemUsage.ramPercent}%`
			topPadding: 1
		}

		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(9)
			text: "RAM"
			rightPadding: 5
		}
	}
}
