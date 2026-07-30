import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
	id: root

	Repeater {
		model: SystemTray.items

		WrapperMouseArea {
			id: trayBtn
			rightMargin: 4
			leftMargin: 4
			cursorShape: Qt.PointingHandCursor

			// --------------
			// tray button
			// --------------
			required property var modelData
			acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

			onClicked: (mouse) => {
				if (mouse.button === Qt.LeftButton) {
					modelData.activate()
				} else if (mouse.button === Qt.MiddleButton) {
					modelData.secondaryActivate()
					} else if (mouse.button === Qt.RightButton) {
						modelData.display()
				}
			}

			// draw app icon image and running indicator
			Item {
				implicitWidth: icon.implicitWidth
				implicitHeight: 36

				IconImage {
					id: icon
					source: modelData.icon
					implicitSize: 16
					anchors.verticalCenter: parent.verticalCenter
				}
			}
		}
	}
}
