import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {

	//---------------------------
	// system power state widget
	//---------------------------
	SystemStatePopup {
		id: systemStatePopup
	}

	WrapperMouseArea {
		id: systemStateButton
		leftMargin: 8
		cursorShape: Qt.PointingHandCursor
		onClicked: {
			if (systemStatePopup.visible) {
				systemStatePopup.hide()
			} else {
				systemStatePopup.show(systemStateButton)	
			}
		}

		HoverHandler {
			id: systemStateHover
			onHoveredChanged: {
				if (hovered) {
					systemStatePopup.cancelHide()
				} else {
					systemStatePopup.scheduleHide()
				}
			}
		}

		// hover background
		Rectangle {
			color: systemStateHover.hovered
					? "#22ebdbb2"
					: "transparent"
			radius: 8
			implicitWidth: icon.implicitWidth + 16
			implicitHeight: icon.implicitHeight + 14

			// for future expansion (if desired)
			RowLayout {
				id: icon
				spacing: 16
				anchors.centerIn: parent

				SystemStateWidget {}
			}
		}
	}

	//-------------------
	// workspaces widget
	//-------------------
	WrapperItem {
		leftMargin: 8

		WorkspacesWidget {}
	}
}
