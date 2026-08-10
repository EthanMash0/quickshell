import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

import "../../theme"

RowLayout {
	id: root
	// spacing: 16
	spacing: 0

	AppPreviewPopup { 
		id: previewPopup 
	}

	AppMenuPopup {
		id: appMenu
	}

	Repeater {
		model: DockState.items

		WrapperMouseArea {
			id: appBtn
			// rightMargin: 4
			// leftMargin: 4
			cursorShape: Qt.PointingHandCursor

			required property var modelData

			readonly property var entry: modelData.entry
			readonly property bool pinned: modelData.pinned

			readonly property var windows: DockState.windowsFor(entry)
			readonly property int instanceCount: windows.length
			readonly property bool appRunning: instanceCount > 0

			//---------------
			// click actions
			//---------------
			acceptedButtons: Qt.LeftButton | Qt.RightButton 

			onClicked: (mouse) => {
				if (mouse.button === Qt.RightButton) {
					previewPopup.hide()
					// test.restart()
					appMenu.show(appBtn, windows, entry, pinned)
					return
				}

				entry.execute()
				previewPopup.scheduleHide()
				appMenu.scheduleHide()
			}

			// ------
			// hover
			// ------
			HoverHandler {
				id: appHover
				onHoveredChanged: {
					if (hovered) {
						previewTimer.restart()
					} else {
						previewTimer.stop()
						exitTimer.restart()

						appMenu.scheduleHide()
					}
				}
			}

			Timer {
				id: previewTimer
				interval: 1500
				onTriggered: if (appRunning && !appMenu.visible) {
					previewPopup.show(appBtn, windows)
				}
			}

			Timer {
				id: exitTimer
				interval: 400
				onTriggered: {
					if (!previewPopup.isHovered) {
						previewPopup.scheduleHide()
					}
				}
			}

			// hover background
			WrapperRectangle {
				color: appHover.hovered
						? Theme.hover
						: "transparent"
				radius: Theme.radiusSmall
				rightMargin: 8
				leftMargin: 8
				implicitHeight: 34

				//----------------------------
				// icon and running indicator
				//----------------------------
				ColumnLayout {
					Item {
						id: iconWrapper
						implicitWidth: icon.implicitWidth
						implicitHeight: 30
						// anchors.verticalCenter: parent.verticalCenter

						IconImage {
							id: icon
							source: Quickshell.iconPath(entry.icon, true)
							implicitSize: 22
							anchors.verticalCenter: parent.verticalCenter
						}

						WrapperRectangle {
							visible: appRunning
							anchors.horizontalCenter: parent.horizontalCenter
							anchors.bottom: iconWrapper.bottom

							width: 24
							height: 1.5
							radius: 1
							color: Theme.highlight
						}
					}
				}
			}
		}
	}
}
