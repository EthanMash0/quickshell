import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../theme"
import "../system"

RowLayout {
	visible: SystemUsage.hasVram

	Text {
		color: Theme.text
		font.pixelSize: Theme.fontSize(16)
		text: "󰚗"
	}

	ColumnLayout {
		spacing: -3

		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(12)
			font.bold: true
			text: `${SystemUsage.vramPercent}%`
			topPadding: 1
		}

		Text {
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(9)
			text: "VRAM"
			rightPadding: 5
		}
	}
}
