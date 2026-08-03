import QtQuick
import QtQuick.Layouts
import Quickshell.Widgets
import Quickshell.Hyprland

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
				radius: 4
				color: focused 
					? "#ebdbb2" 
					: "transparent"

				Text {
					color: focused
						? "#181818"
						: "#ebdbb2"
					font.pixelSize: 16
					text: `${index + 1}`
				}
			}
		}
	}
}
