import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Pipewire

import "../../theme"
import "../components"

SettingsPage {
	id: root

	title: "Audio"
	description: "Pick the default devices and set a level for anything currently playing."

	//-----------
	// node data
	//-----------
	readonly property var allNodes: Pipewire.nodes.values

	readonly property var defaultSink: Pipewire.defaultAudioSink
	readonly property var defaultSource: Pipewire.defaultAudioSource

	// real devices, as opposed to the per application streams below
	readonly property var sinks: root.allNodes.filter(n => !n.isStream && n.isSink && !!n.audio)
	readonly property var sources: root.allNodes.filter(n => !n.isStream && !n.isSink && !!n.audio)

	readonly property var playbackStreams: root.allNodes.filter(n => root.isStreamOfKind(n, "Output"))
	readonly property var captureStreams: root.allNodes.filter(n => root.isStreamOfKind(n, "Input"))

	// volume, mute and metadata are only live for nodes that are bound
	PwObjectTracker {
		objects: root.allNodes
	}

	//---------
	// helpers
	//---------
	// pipewire tags application streams with a media.class of Stream/Output/Audio
	// for playback and Stream/Input/Audio for capture
	function isStreamOfKind(node, kind) {
		if (!node.isStream || !node.audio) return false

		const props = node.properties || ({})
		const mediaClass = props["media.class"] || ""

		// show streams we cannot classify as playback rather than hiding them
		if (!mediaClass.length) return kind === "Output"

		return mediaClass.indexOf(`Stream/${kind}/`) === 0
	}

	// streams are best identified by their application, devices by description
	function nodeLabel(node) {
		if (!node) return "None"

		const props = node.properties || ({})

		return props["application.name"]
				|| node.description
				|| node.nickname
				|| node.name
	}

	// for a stream this is usually the track or tab title
	function streamDetail(node) {
		const props = node.properties || ({})

		return props["media.name"] || ""
	}

	//-------------
	// output card
	//-------------
	Card {
		title: "OUTPUT"

		SettingRow {
			label: root.nodeLabel(root.defaultSink)
			description: root.defaultSink
					? "Default output device"
					: "No output device available"
		}

		VolumeControl {
			node: root.defaultSink
		}
	}

	Card {
		visible: root.sinks.length > 1
		title: "OUTPUT DEVICES"

		Repeater {
			model: root.sinks

			ListRow {
				required property var modelData

				glyph: modelData === root.defaultSink
						? "󰄬"
						: "󰕾"
				title: root.nodeLabel(modelData)
				subtitle: modelData === root.defaultSink
						? "Default"
						: ""
				highlighted: modelData === root.defaultSink

				onClicked: Pipewire.preferredDefaultAudioSink = modelData
			}
		}
	}

	//------------
	// input card
	//------------
	Card {
		title: "INPUT"

		SettingRow {
			label: root.nodeLabel(root.defaultSource)
			description: root.defaultSource
					? "Default input device"
					: "No input device available"
		}

		VolumeControl {
			node: root.defaultSource
		}
	}

	Card {
		visible: root.sources.length > 1
		title: "INPUT DEVICES"

		Repeater {
			model: root.sources

			ListRow {
				required property var modelData

				glyph: modelData === root.defaultSource
						? "󰄬"
						: "󰍬"
				title: root.nodeLabel(modelData)
				subtitle: modelData === root.defaultSource
						? "Default"
						: ""
				highlighted: modelData === root.defaultSource

				onClicked: Pipewire.preferredDefaultAudioSource = modelData
			}
		}
	}

	//-------------------
	// application mixer
	//-------------------
	Card {
		title: "PLAYING"

		InfoText {
			visible: root.playbackStreams.length === 0
			text: "Nothing is playing right now."
		}

		Repeater {
			model: root.playbackStreams

			ColumnLayout {
				required property var modelData

				Layout.fillWidth: true
				Layout.topMargin: 4
				spacing: 2

				Text {
					Layout.fillWidth: true
					text: root.nodeLabel(modelData)
					color: Theme.text
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(13)
					elide: Text.ElideRight
				}

				Text {
					Layout.fillWidth: true
					visible: root.streamDetail(modelData).length > 0
					text: root.streamDetail(modelData)
					color: Theme.textMuted
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(11)
					elide: Text.ElideRight
				}

				VolumeControl {
					node: modelData
				}
			}
		}
	}

	Card {
		visible: root.captureStreams.length > 0
		title: "RECORDING"

		Repeater {
			model: root.captureStreams

			ColumnLayout {
				required property var modelData

				Layout.fillWidth: true
				Layout.topMargin: 4
				spacing: 2

				Text {
					Layout.fillWidth: true
					text: root.nodeLabel(modelData)
					color: Theme.text
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(13)
					elide: Text.ElideRight
				}

				VolumeControl {
					node: modelData
				}
			}
		}
	}
}
