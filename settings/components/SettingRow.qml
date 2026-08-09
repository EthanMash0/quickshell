import QtQuick
import QtQuick.Layouts

import "../../theme"

// label (with optional hint) on the left, a control on the right
RowLayout {
	id: root

	property string label: ""
	property string description: ""

	default property alias control: controlSlot.data

	Layout.fillWidth: true
	spacing: 12

	ColumnLayout {
		Layout.fillWidth: true
		spacing: 0

		Text {
			Layout.fillWidth: true
			text: root.label
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(13)
			elide: Text.ElideRight
		}

		Text {
			Layout.fillWidth: true
			visible: root.description.length > 0
			text: root.description
			color: Theme.textMuted
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(11)
			wrapMode: Text.WordWrap
		}
	}

	RowLayout {
		id: controlSlot
		spacing: 8
	}
}
