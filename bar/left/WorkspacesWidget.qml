import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland

import "../../theme"

RowLayout {
	spacing: 8

	Repeater {
		model: 5

		WrapperMouseArea {
			required property int index
			cursorShape: Qt.PointingHandCursor

			readonly property bool focused: {
				Hyprland.focusedWorkspace?.id === index + 1
			}

			HoverHandler {
				id: hover
			}

			onClicked: {
				Hyprland.dispatch(`hl.dsp.focus({ workspace = "${index + 1}" }) `)
			}  

			WrapperRectangle {
				implicitWidth: 20
				radius: Theme.radiusSmall
				color: focused 
					? Theme.highlight 
					: hover.hovered
						? Theme.hover
						: "transparent"

				Text {
					color: focused
						? Theme.onHighlight
						: Theme.text
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(16)
					horizontalAlignment: Text.AlignHCenter
					text: `${index + 1}`
				}
			}
		}
	}
}
