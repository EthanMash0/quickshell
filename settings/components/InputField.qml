import QtQuick
import QtQuick.Controls

import "../../theme"

// themed text entry, used for wifi passwords and the appearance fields
TextField {
	id: root

	implicitHeight: 30

	color: Theme.text
	placeholderTextColor: Theme.textFaint
	selectionColor: Theme.selection
	selectedTextColor: Theme.text
	font.family: Theme.labelFont
	font.pixelSize: Theme.fontSize(12)
	leftPadding: 8
	rightPadding: 8

	background: Rectangle {
		radius: Theme.radiusSmall
		color: Theme.inputBackground
		border.width: 1
		border.color: root.activeFocus
				? Theme.highlight
				: Theme.borderSoft
	}
}
