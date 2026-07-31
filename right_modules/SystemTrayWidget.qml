import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

RowLayout {
	id: root
	property bool isOpen: true

	// to find icons for apps that use non-quickshell-supported paths
	function resolveTrayIcon(src, px = 16) {
		if (!src || src.indexOf("?path=") === -1) return src

		const s = src.replace(/^image:\/\/icon\//, "")
		const i = s.indexOf("?path=")
		const name = s.slice(0, i)
		const themeRoot = s.slice(i + 6)

		return `file://${themeRoot}/hicolor/${px}x${px}/status/${name}.png`
	}

	WrapperMouseArea {
		onClicked: root.isOpen = !root.isOpen

		Text {
			color: "#ebdbb2"
			font.pixelSize: 16
			text: root.isOpen 
				? ">" 
				: "<"
		}
	}

	RowLayout {
		visible: root.isOpen

		Repeater {
			model: SystemTray.items

			WrapperMouseArea {
				id: trayBtn
				leftMargin: 8
				cursorShape: Qt.PointingHandCursor

				required property var modelData

				//---------------
				// click actions
				//---------------
				QsMenuAnchor {
					id: menuAnchor
					menu: modelData.menu
					anchor.item: trayBtn
					anchor.edges: Edges.Bottom
					anchor.gravity: Edges.Bottom
				}

				acceptedButtons: Qt.LeftButton | Qt.MiddleButton | Qt.RightButton

				onClicked: (mouse) => {
					if (mouse.button === Qt.LeftButton) {
						if (modelData.onlyMenu && modelData.hasMenu) {
							menuAnchor.open()
						} else {
							modelData.activate()
						}
					} else if (mouse.button === Qt.MiddleButton) {
						modelData.secondaryActivate()
					} else if (mouse.button === Qt.RightButton) {
						if (modelData.hasMenu) {
							menuAnchor.open()
						}
					}
				}

				//---------
				// tooltip
				//---------
				hoverEnabled: true

				ToolTip.visible: containsMouse && !!(modelData.tooltipTitle || modelData.tooltipDescription || modelData.title)
				ToolTip.text: {
					const t = modelData.tooltipTitle || modelData.title
					const d = modelData.tooltipDescription
					return d ? `${t}\n${d}` : t
				}
				ToolTip.delay: 1000

				//----------------
				// scroll actions
				//----------------
				onWheel: (wheel) => {
					modelData.scroll(wheel.angleDelta.y, false)
				}

				//-------
				// image
				//-------
				Image {
					id: icon
					width: 16
					height: 16
					sourceSize: Qt.size(16, 16)
					fillMode: Image.PreserveAspectFit
					source: resolveTrayIcon(modelData.icon, 16)
				}
			}
		}
	}
}
