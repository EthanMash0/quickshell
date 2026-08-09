import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland

import "../../theme"

RowLayout {
	Repeater {
		model: 5

		WrapperMouseArea {
			required property int index
			leftMargin: 4
			cursorShape: Qt.PointingHandCursor

			readonly property bool focused: Hyprland.focusedWorkspace?.id === index + 1

			onClicked: {
				Hyprland.dispatch(`hl.dsp.focus({ workspace = "${index + 1}" }) `)
			}  

			WrapperRectangle {
				implicitWidth: 16
				leftMargin: 4
				radius: Theme.radiusSmall
				color: focused 
					? Theme.highlight 
					: "transparent"

				Text {
					color: focused
						? Theme.onHighlight
						: Theme.text
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(16)
					text: `${index + 1}`
				}
			}
		}
	}
}
