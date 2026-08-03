import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets

RowLayout {
	id: root

	AppPreviewPopup { 
		id: previewPopup 
	}

	Repeater {
		model: DesktopEntries.applications

		WrapperMouseArea {
			id: appBtn
			rightMargin: 4
			leftMargin: 4
			cursorShape: Qt.PointingHandCursor

			// --------------
			// app button
			// --------------
			required property var modelData
			// acceptedButtons: Qt.LeftButton | Qt.RightButton 

			onClicked: (mouse) => {
				if (mouse.button === Qt.RightButton) {
					modelData.execute()
				}

				if (mouse.button === Qt.LeftButton) {
					modelData.execute()
				}
			}

			// find all top level application instances using Quickshell.Wayland
			readonly property var windows: ToplevelManager.toplevels.values.filter(app => {
				const id = (app.appId || "").toLowerCase()
				return id === modelData.id?.toLowerCase()
					|| id === modelData.startupClass?.toLowerCase()
			})

			readonly property int instanceCount: windows.length
			readonly property bool isOpen: instanceCount > 0
			// readonly property bool isFocused: windows.some(app => app.activated)


			// draw app icon image and running indicator
			Item {
				implicitWidth: icon.implicitWidth
				implicitHeight: 36

				IconImage {
					id: icon
					source: Quickshell.iconPath(modelData.icon, true)
					implicitSize: 24
					anchors.verticalCenter: parent.verticalCenter
				}

				WrapperRectangle {
					visible: isOpen
					anchors.horizontalCenter: parent.horizontalCenter
					anchors.bottom: parent.bottom
					// bottomMargin: 2

					width: 28
					height: 1.5
					radius: 1
					color: "#ebdbb2"
				}
			}

			// --------------
			// hover preview
			// --------------
			hoverEnabled: true

			Timer {
				id: previewTimer
				interval: 1000
				onTriggered: if (isOpen) previewPopup.show(windows, appBtn)
			}

			Timer {
				id: exitTimer
				interval: 200
				onTriggered: if (!previewPopup.isHovered) previewPopup.scheduleHide()
			}

			onEntered: {
				if (!isOpen) return
				previewPopup.cancelHide()

				if (previewPopup.isOpen) {
					previewPopup.show(windows, appBtn)
				} else {
					previewTimer.restart()
				}
			}

			onExited: {
				previewTimer.stop()
				exitTimer.restart()
			}
		}
	}
}
