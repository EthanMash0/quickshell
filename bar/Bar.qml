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
