import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets

import "../../theme"

// one device, network, stream or app in a list: an icon or glyph, title,
// subtitle, then any buttons the caller adds
Rectangle {
	id: root

	property string glyph: ""
	// takes the glyph's place when set, for rows that represent an application
	property string iconSource: ""
	property string title: ""
	property string subtitle: ""
	property bool highlighted: false
	property bool interactive: true

	default property alias actions: actionRow.data

	signal clicked()

	Layout.fillWidth: true
	implicitHeight: 48
	radius: Theme.radiusSmall

	color: {
		if (root.highlighted) return Theme.selectionSoft

		return rowHover.hovered && root.interactive
				? Theme.hoverFaint
				: "transparent"
	}

	HoverHandler {
		id: rowHover
		enabled: root.interactive
		cursorShape: Qt.PointingHandCursor
	}

	TapHandler {
		enabled: root.interactive
		onTapped: root.clicked()
	}

	RowLayout {
		anchors.fill: parent
		anchors.leftMargin: 10
		anchors.rightMargin: 10
		spacing: 12

		IconImage {
			visible: root.iconSource.length > 0
			source: root.iconSource
			implicitSize: 28
		}

		Text {
			visible: root.glyph.length > 0 && root.iconSource.length === 0
			text: root.glyph
			color: root.highlighted
					? Theme.highlight
					: Theme.text
			font.pixelSize: Theme.fontSize(18)
		}

		ColumnLayout {
			Layout.fillWidth: true
			spacing: 0

			Text {
				Layout.fillWidth: true
				text: root.title
				color: Theme.text
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(13)
				elide: Text.ElideRight
			}

			Text {
				Layout.fillWidth: true
				visible: root.subtitle.length > 0
				text: root.subtitle
				color: Theme.textMuted
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(11)
				elide: Text.ElideRight
			}
		}

		RowLayout {
			id: actionRow
			spacing: 6
		}
	}
}
