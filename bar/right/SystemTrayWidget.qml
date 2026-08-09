import QtQuick
import QtQuick.Layouts
import QtQuick.Controls
import Quickshell
import Quickshell.Services.SystemTray
import Quickshell.Widgets

import "../../theme"

RowLayout {
	id: root
	property bool isOpen: true

	function trayIconCandidates(src, px = 16) {
		if (!src) return [""]
		if (src.indexOf("?path=") === -1) return [src]

		const s = src.replace(/^image:\/\/icon\//, "")
		const i = s.indexOf("?path=")
		const name = s.slice(0, i)
		const themeRoot = s.slice(i + 6)

		return [
			// flat IconThemePath (Spotify, many Electron apps)
			`file://${themeRoot}/${name}.png`,
			`file://${themeRoot}/${name}.svg`,
			// Freedesktop theme tree (Dropbox, etc.)
			`file://${themeRoot}/hicolor/${px}x${px}/status/${name}.png`,
			`file://${themeRoot}/hicolor/${px}x${px}/apps/${name}.png`,
			`file://${themeRoot}/hicolor/scalable/status/${name}.svg`,
			// Quickshell default provider
			src
		]
	}

	WrapperMouseArea {
		onClicked: root.isOpen = !root.isOpen

		Text {
			color: Theme.text
			font.pixelSize: Theme.fontSize(16)
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
				IconImage {
					id: icon
					implicitSize: 16
					width: 16
					height: 16

					property int candidateIndex: 0
					property var candidates: []

					function resetCandidates() {
						candidates = root.trayIconCandidates(modelData.icon, 16)
						candidateIndex = 0
						source = candidates[0] || ""
					}

					function advanceCandidate() {
						if (candidateIndex >= candidates.length - 1) return
						candidateIndex++
						source = candidates[candidateIndex]
					}

					Component.onCompleted: resetCandidates()

					onStatusChanged: {
						if (status === Image.Error) {
							Qt.callLater(advanceCandidate)
						}
					}

					// reset when the tray item's icon changes (e.g. for state changes)
					Connections {
						target: modelData
						function onIconChanged() {
							icon.resetCandidates()
						}
					}
				}
			}
		}
	}
}
