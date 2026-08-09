import QtQuick
import QtQuick.Layouts

import "../../theme"

// muted note used for empty lists, hints and error messages
Text {
	Layout.fillWidth: true

	color: Theme.textMuted
	font.family: Theme.labelFont
	font.pixelSize: Theme.fontSize(12)
	wrapMode: Text.WordWrap
	topPadding: 2
	bottomPadding: 2
}
