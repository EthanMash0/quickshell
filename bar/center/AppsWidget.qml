import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

RowLayout {
	id: root

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
			rightMargin: 4
			leftMargin: 4
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

			//----------------------------
			// icon and running indicator
			//----------------------------
			Item {
				implicitWidth: icon.implicitWidth
				implicitHeight: 36

				IconImage {
					id: icon
					source: Quickshell.iconPath(entry.icon, true)
					implicitSize: 24
					anchors.verticalCenter: parent.verticalCenter
				}

				WrapperRectangle {
					visible: appRunning
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.bottom: parent.bottom

					width: 28
					height: 1.5
					radius: 1
					color: "#ebdbb2"
				}
			}
		}
	}
}
