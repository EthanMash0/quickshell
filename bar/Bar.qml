import Quickshell

import "right"
import "center"
import "left"

Scope {
	Variants {
		model: Quickshell.screens

		PanelWindow {
			required property var modelData
			screen: modelData

			anchors {
				top: true
				left: true
				right: true
			}

			implicitHeight: 40

			color: "#bb181818"

			Right {
				anchors.right: parent.right
				anchors.verticalCenter: parent.verticalCenter
			}

			Center {
				anchors.centerIn: parent
			}

			Left {
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
			}
		}
	}
}
