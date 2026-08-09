import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
	id: root

	color: Theme.alpha(Theme.text, 0.04)

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: 12
		spacing: 4

		Text {
			Layout.fillWidth: true
			Layout.bottomMargin: 8
			leftPadding: 10
			text: "Settings"
			color: Theme.text
			font.family: Theme.labelFont
			font.pixelSize: Theme.fontSize(18)
			font.bold: true
		}

		//--------------
		// page entries
		//--------------
		Repeater {
			model: SettingsState.pages

			Rectangle {
				required property var modelData

				readonly property bool current: SettingsState.page === modelData.id

				Layout.fillWidth: true
				implicitHeight: 36
				radius: Theme.radiusSmall
				color: current
						? Theme.selection
						: navHover.hovered
							? Theme.hoverFaint
							: "transparent"

				HoverHandler {
					id: navHover
					cursorShape: Qt.PointingHandCursor
				}

				TapHandler {
					onTapped: SettingsState.page = modelData.id
				}

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 10
					anchors.rightMargin: 10
					spacing: 10

					Text {
						text: modelData.glyph
						color: current
								? Theme.highlight
								: Theme.text
						font.pixelSize: Theme.fontSize(16)
					}

					Text {
						Layout.fillWidth: true
						text: modelData.label
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(13)
						elide: Text.ElideRight
					}
				}
			}
		}

		// keeps the entries packed at the top
		Item {
			Layout.fillHeight: true
		}
	}
}
