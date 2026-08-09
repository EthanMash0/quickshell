import QtQuick
import QtQuick.Layouts

import "../../theme"

// titled container that groups related controls
Rectangle {
	id: root

	property string title: ""
	// optional right aligned control in the title row, e.g. a toggle
	property alias trailing: trailingSlot.data
	default property alias content: body.data

	Layout.fillWidth: true
	implicitHeight: layout.implicitHeight + 24

	radius: Theme.radius
	color: Theme.alpha(Theme.text, 0.04)
	border.width: Theme.borderWidth
	border.color: Theme.alpha(Theme.text, 0.12)

	ColumnLayout {
		id: layout

		anchors.left: parent.left
		anchors.right: parent.right
		anchors.top: parent.top
		anchors.margins: 12
		spacing: 10

		//-----------
		// title row
		//-----------
		RowLayout {
			Layout.fillWidth: true
			visible: root.title.length > 0 || trailingSlot.children.length > 0
			spacing: 8

			Text {
				Layout.fillWidth: true
				text: root.title
				color: Theme.textMuted
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(11)
				font.bold: true
				elide: Text.ElideRight
			}

			Item {
				id: trailingSlot
				implicitWidth: childrenRect.width
				implicitHeight: childrenRect.height
			}
		}

		ColumnLayout {
			id: body
			Layout.fillWidth: true
			spacing: 8
		}
	}
}
