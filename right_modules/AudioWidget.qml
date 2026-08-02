import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

RowLayout {
	id: root

	readonly property var sink: Pipewire.defaultAudioSink
	readonly property bool ready: sink && sink.ready && sink.audio
	readonly property bool muted: ready ? sink.audio.muted : false
	readonly property real volume: ready ? sink.audio.volume : 0

	PwObjectTracker {
		objects: root.sink
						? [root.sink]
						: []
	}

	Text {
		color: "#ebdbb2"
		font.pixelSize: 16
		anchors.centerIn: parent
		text: {
			if (!root.ready) {
				return "󰖁"
			}
			if (root.muted || root.volume <= 0) {
				return "󰝟"
			}
			if (root.volume < 0.33) {
				return "󰕿"
			}
			if (root.volume < 0.66) {
				return "󰖀"
			}
			return "󰕾"
		}
	}
}
