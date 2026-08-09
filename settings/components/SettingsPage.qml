import QtQuick
import QtQuick.Controls
import QtQuick.Layouts

import "../../theme"

// scrollable shell shared by every settings page: a heading followed by a
// vertical stack of cards
Flickable {
	id: root

	property string title: ""
	property string description: ""
	default property alias content: body.data

	clip: true
	contentWidth: width
	contentHeight: layout.implicitHeight + 48
	boundsBehavior: Flickable.StopAtBounds

	ScrollBar.vertical: ScrollBar {
		width: 6

		contentItem: Rectangle {
			radius: 3
			color: Theme.alpha(Theme.text, 0.25)
		}
	}

	ColumnLayout {
		id: layout

		x: 24
		y: 24
		width: root.width - 48
		spacing: 16

		//--------------
		// page heading
		//--------------
		ColumnLayout {
			Layout.fillWidth: true
			Layout.bottomMargin: 4
			spacing: 2

			Text {
				text: root.title
				color: Theme.text
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(22)
				font.bold: true
			}

			Text {
				Layout.fillWidth: true
				visible: root.description.length > 0
				text: root.description
				color: Theme.textMuted
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(12)
				wrapMode: Text.WordWrap
			}
		}

		//-------
		// cards
		//-------
		ColumnLayout {
			id: body
			Layout.fillWidth: true
			spacing: 16
		}
	}
}
