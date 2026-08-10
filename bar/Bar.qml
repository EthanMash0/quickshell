import Quickshell

import "right"
import "center"
import "left"
import "../theme"

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

			implicitHeight: Theme.barHeight
			color: Theme.barBackground

			Right {
				anchors.right: parent.right
				// anchors.verticalCenter: parent.verticalCenter
				anchors.bottom: parent.bottom
			}

			Center {
				// anchors.centerIn: parent
				anchors.horizontalCenter: parent.horizontalCenter
				anchors.bottom: parent.bottom
			}

			Left {
				anchors.left: parent.left
				// anchors.verticalCenter: parent.verticalCenter
				anchors.bottom: parent.bottom
			}
		}
	}
}
