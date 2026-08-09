import QtQuick
import QtQuick.Layouts

import "../../theme"

// mute button, volume slider and percentage for a single pipewire node
RowLayout {
	id: root

	property var node: null

	readonly property bool ready: !!root.node && !!root.node.audio
	readonly property bool muted: root.ready && root.node.audio.muted
	readonly property real volume: root.ready
			? root.node.audio.volume
			: 0

	Layout.fillWidth: true
	spacing: 10

	//-------------
	// mute toggle
	//-------------
	Text {
		Layout.preferredWidth: 22

		text: {
			if (!root.ready) return "󰖁"
			if (root.muted || root.volume <= 0) return "󰝟"
			if (root.volume < 0.33) return "󰕿"
			if (root.volume < 0.66) return "󰖀"
			return "󰕾"
		}
		color: root.muted
				? Theme.textFaint
				: Theme.text
		font.pixelSize: Theme.fontSize(18)

		HoverHandler {
			enabled: root.ready
			cursorShape: Qt.PointingHandCursor
		}

		TapHandler {
			enabled: root.ready
			onTapped: root.node.audio.muted = !root.node.audio.muted
		}
	}

	LevelSlider {
		id: slider

		Layout.fillWidth: true
		enabled: root.ready
		from: 0
		to: 1
		value: root.volume

		// only user drags write back, so a bound volume cannot fight the handle
		onMoved: root.node.audio.volume = value

		// dragging breaks the binding above, so pull the value back in whenever
		// something else changes the volume
		Connections {
			target: root
			function onVolumeChanged() {
				if (!slider.pressed && Math.abs(slider.value - root.volume) > 0.001) {
					slider.value = root.volume
				}
			}
		}
	}

	Text {
		Layout.preferredWidth: 38
		horizontalAlignment: Text.AlignRight
		text: `${Math.round(root.volume * 100)}%`
		color: Theme.textMuted
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(12)
	}
}
