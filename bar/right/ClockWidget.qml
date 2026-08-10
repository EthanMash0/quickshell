import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../prefs"

ColumnLayout {
	spacing: -2

	Text {
		Layout.alignment: Qt.AlignHCenter
		color: Theme.text
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(13)
		text: Time.time
		font.bold: true
		topPadding: 1
	}
	
	Text {
		Layout.alignment: Qt.AlignHCenter
		visible: Prefs.clockShowDate
		color: Theme.textMuted
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(11)
		text: Time.date
	}
}
