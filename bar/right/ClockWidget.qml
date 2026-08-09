import QtQuick

import "../../theme"

Text {
	color: Theme.text
	font.family: Theme.labelFont
	font.pixelSize: Theme.fontSize(16)
	text: Time.time
}
