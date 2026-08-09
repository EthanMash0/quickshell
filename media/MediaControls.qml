import QtQuick
import QtQuick.Layouts

import "../theme"

// previous / play-pause / next for whichever player MediaState is following,
// centred in whatever width it is given. buttons grey out when the player says
// it cannot do that action
RowLayout {
	id: root

	Layout.fillWidth: true
	spacing: 18

	Item { Layout.fillWidth: true }

	Repeater {
		model: ["previous", "toggle", "next"]

		Text {
			id: button

			required property var modelData

			readonly property bool isToggle: modelData === "toggle"

			readonly property bool available: {
				if (!MediaState.hasPlayer) return false

				switch (modelData) {
					case "previous": return MediaState.active.canGoPrevious
					case "next": return MediaState.active.canGoNext
				}
				return MediaState.active.canTogglePlaying
			}

			// the middle button swaps glyph with the playback state
			text: {
				switch (modelData) {
					case "previous": return "󰒮"
					case "next": return "󰒭"
				}
				return MediaState.playing
						? "󰏤"
						: "󰐊"
			}

			color: button.available
					? Theme.text
					: Theme.textFaint
			font.pixelSize: Theme.fontSize(button.isToggle ? 22 : 18)

			HoverHandler {
				enabled: button.available
				cursorShape: Qt.PointingHandCursor
			}

			TapHandler {
				enabled: button.available
				onTapped: {
					switch (button.modelData) {
						case "previous": MediaState.previous(); break
						case "next": MediaState.next(); break
						default: MediaState.toggle()
					}
				}
			}
		}
	}

	Item { Layout.fillWidth: true }
}
