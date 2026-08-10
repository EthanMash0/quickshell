import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Services.Pipewire

import "../../theme"
import "../../prefs"
import "../../media"
import "../../settings"

PanelWindow {
	id: root

	color: "transparent"
	visible: false

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay

	onWidthChanged: if (visible) root.reposition()
	onHeightChanged: if (visible) root.reposition()

	//-------------------
	// public properties
	//-------------------
	property var anchorItem: null
	
	//-------------
	// show / hide
	//-------------
	function show(anchorItem) {
		root.anchorItem = anchorItem

		cancelHide()
		visible = true
		Qt.callLater(root.reposition)
	}

	function hide() {
		visible = false
		root.closeMenus()
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop() 
	}

	function reposition() {
		if (!root.anchorItem || !root.visible) {
			return
		}

		const item = root.anchorItem
		// below the icon, horizontally centered on it
		const g = item.mapToGlobal(0, item.height)
		const local = root.contentItem.mapFromGlobal(g.x, g.y) 

		// the popup is far wider than the icon it hangs off, so centering alone
		// pushes it past the edge of the screen on a right aligned bar
		const centered = local.x + (item.width - menu.width) / 2
		const maxX = root.width - menu.width - 8

		menu.x = Math.max(8, Math.min(centered, maxX))
		menu.y = local.y + 8
	}

	// opens the settings app on a page and dismisses the popup
	function openSettings(page) {
		root.hide()
		SettingsState.showPage(page)
	}

	//------------
	// audio sink
	//------------
	readonly property var sink: Pipewire.defaultAudioSink

	readonly property bool sinkReady: !!root.sink && root.sink.ready && !!root.sink.audio
	readonly property bool sinkMuted: root.sinkReady && root.sink.audio.muted
	readonly property real sinkVolume: root.sinkReady
			? root.sink.audio.volume
			: 0

	// every output the picker can switch to, streams excluded
	readonly property var sinks: Pipewire.nodes.values
			.filter(n => !n.isStream && n.isSink && !!n.audio)

	// pipewire only populates volume and description for tracked objects, and
	// the picker needs a name for every output, not just the current one
	PwObjectTracker {
		objects: root.sinks
	}

	function nodeLabel(node) {
		if (!node) return "None"

		return node.description
				|| node.nickname
				|| node.name
				|| "Unknown output"
	}

	//-----------------
	// inline pickers
	//-----------------
	property bool audioMenuOpen: false
	property bool mediaMenuOpen: false

	function closeMenus() {
		root.audioMenuOpen = false
		root.mediaMenuOpen = false
	}

	// only one picker at a time, otherwise the popup grows taller than the screen
	function toggleAudioMenu() {
		const next = !root.audioMenuOpen
		root.closeMenus()
		root.audioMenuOpen = next
	}

	function toggleMediaMenu() {
		const next = !root.mediaMenuOpen
		root.closeMenus()
		root.mediaMenuOpen = next
	}

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	Timer {
		id: hideTimer
		interval: 400
		onTriggered: root.hide()
	}
	
	// close on outside click.
	// the tap handlers inside the menu only take a passive grab, so presses
	// reach this area too and it has to reject the ones that landed on the menu
	// itself, or acting on a control would dismiss the popup underneath it
	MouseArea {
		anchors.fill: parent

		onClicked: event => {
			if (!menu.contains(mapToItem(menu, event.x, event.y))) root.hide()
		}
	}

	WrapperRectangle {
		id: menu
		margin: 8
		radius: Theme.radius
		color: Theme.surface
		// border.color: Theme.border
		// border.width: 1

		HoverHandler {
			onHoveredChanged: {
				if (hovered) {
					root.cancelHide()
				} else {
					root.scheduleHide()
				}
			}
		}

		ColumnLayout {
			id: content
			spacing: 10

			// the wrapper sizes itself to this layout, and a layout only knows
			// how wide its children want to be, so one of them has to say
			readonly property int rowWidth: 300

			//------------------------
			// bluetooth and network
			//------------------------
			RowLayout {
				Layout.fillWidth: true
				spacing: 8

				//------------------
				// bluetooth button
				//------------------
				Rectangle {
					Layout.fillWidth: true
					implicitHeight: 48
					radius: Theme.radiusSmall
					border.color: Theme.border
					border.width: Theme.borderWidth
					color: bluetoothHover.hovered
							? Theme.hover
							: "transparent"

					HoverHandler {
						id: bluetoothHover
						cursorShape: Qt.PointingHandCursor
					}

					TapHandler {
						onTapped: root.openSettings("bluetooth")
					}

					BluetoothWidget {
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.top: parent.top
						anchors.topMargin: 6
					}

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(12)
						text: "Bluetooth"
						anchors.bottom: parent.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						bottomPadding: 4
					}
				}

				//-------------
				// wifi button
				//-------------
				Rectangle {
					Layout.fillWidth: true
					implicitHeight: 48
					radius: Theme.radiusSmall
					border.color: Theme.border
					border.width: Theme.borderWidth
					color: wifiHover.hovered
							? Theme.hover
							: "transparent"

					HoverHandler {
						id: wifiHover
						cursorShape: Qt.PointingHandCursor
					}

					TapHandler {
						onTapped: root.openSettings("network")
					}

					NetworkWidget {
						anchors.horizontalCenter: parent.horizontalCenter
						anchors.top: parent.top
						anchors.topMargin: 6
					}

					Text {
						color: Theme.text
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(12)
						text: "Network"
						anchors.bottom: parent.bottom
						anchors.horizontalCenter: parent.horizontalCenter
						bottomPadding: 4
					}
				}
			}

			//-----------
			// audio row
			//-----------
			Rectangle {
				Layout.fillWidth: true
				implicitWidth: content.rowWidth
				implicitHeight: 44
				radius: Theme.radiusSmall
				border.color: Theme.border
				border.width: Theme.borderWidth
				color: "transparent"

				RowLayout {
					anchors.fill: parent
					anchors.leftMargin: 10
					anchors.rightMargin: 10
					spacing: 10

					// mute toggle, doubles as the level indicator
					Text {
						Layout.preferredWidth: 22
						color: root.sinkMuted
								? Theme.textFaint
								: Theme.text
						font.pixelSize: Theme.fontSize(18)
						text: {
							if (!root.sinkReady) return "󰖁"
							if (root.sinkMuted || root.sinkVolume <= 0) return "󰝟"
							if (root.sinkVolume < 0.33) return "󰕿"
							if (root.sinkVolume < 0.66) return "󰖀"
							return "󰕾"
						}

						HoverHandler {
							enabled: root.sinkReady
							cursorShape: Qt.PointingHandCursor
						}

						TapHandler {
							enabled: root.sinkReady
							onTapped: root.sink.audio.muted = !root.sink.audio.muted
						}
					}

					LevelSlider {
						id: volumeSlider

						Layout.fillWidth: true
						enabled: root.sinkReady
						from: 0
						to: 1
						value: root.sinkVolume

						onMoved: root.sink.audio.volume = value

						// dragging breaks the binding above, so pull the value back
						// in whenever something else changes the volume
						Connections {
							target: root
							function onSinkVolumeChanged() {
								if (!volumeSlider.pressed
										&& Math.abs(volumeSlider.value - root.sinkVolume) > 0.001) {
									volumeSlider.value = root.sinkVolume
								}
							}
						}
					}

					Text {
						Layout.preferredWidth: 34
						horizontalAlignment: Text.AlignRight
						text: `${Math.round(root.sinkVolume * 100)}%`
						color: Theme.textMuted
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(12)
					}

					// output picker, kept off the slider so dragging cannot open it.
					// padded because a bare glyph is a hard target to hit
					Text {
						padding: 6
						text: root.audioMenuOpen
								? "󰅃"
								: "󰅀"
						color: audioMenuHover.hovered || root.audioMenuOpen
								? Theme.highlight
								: Theme.textMuted
						font.pixelSize: Theme.fontSize(14)

						HoverHandler {
							id: audioMenuHover
							cursorShape: Qt.PointingHandCursor
						}

						TapHandler {
							onTapped: root.toggleAudioMenu()
						}
					}
				}
			}

			//---------------------
			// audio output picker
			//---------------------
			Rectangle {
				Layout.fillWidth: true
				visible: root.audioMenuOpen
				implicitWidth: content.rowWidth
				implicitHeight: audioMenu.implicitHeight + 16
				radius: Theme.radiusSmall
				color: Theme.alpha(Theme.text, 0.05)
				border.color: Theme.borderSoft
				border.width: Theme.borderWidth

				ColumnLayout {
					id: audioMenu

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 8
					spacing: 2

					Text {
						Layout.fillWidth: true
						leftPadding: 8
						bottomPadding: 2
						text: "OUTPUT"
						color: Theme.textMuted
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(10)
						font.bold: true
					}

					Repeater {
						model: root.sinks

						PickerRow {
							required property var modelData

							label: root.nodeLabel(modelData)
							selected: modelData === root.sink
							glyph: "󰓃"
							onPicked: Pipewire.preferredDefaultAudioSink = modelData
						}
					}

					PickerRow {
						label: "Audio settings"
						glyph: "󰒓"
						onPicked: root.openSettings("audio")
					}
				}
			}

			//-----------
			// media row
			//-----------
			Rectangle {
				Layout.fillWidth: true
				visible: Prefs.mediaShowInControlCenter
				implicitWidth: content.rowWidth
				implicitHeight: 112
				radius: Theme.radiusSmall
				border.color: Theme.border
				border.width: Theme.borderWidth
				color: "transparent"

				RowLayout {
					anchors.fill: parent
					anchors.margins: 10
					spacing: 10

					//------------
					// album art
					//------------
					Rectangle {
						visible: Prefs.mediaShowArt
						Layout.alignment: Qt.AlignVCenter
						implicitWidth: 72
						implicitHeight: 72
						radius: Theme.radiusSmall
						color: Theme.alpha(Theme.text, 0.08)
						clip: true

						Image {
							anchors.fill: parent
							source: MediaState.artUrl
							fillMode: Image.PreserveAspectCrop
							asynchronous: true
							visible: status === Image.Ready
						}

						Text {
							anchors.centerIn: parent
							visible: MediaState.artUrl.length === 0
							text: "󰝚"
							color: Theme.textMuted
							font.pixelSize: Theme.fontSize(24)
						}
					}

					ColumnLayout {
						Layout.fillWidth: true
						spacing: 4

						//---------------------
						// title, artist, menu
						//---------------------
						RowLayout {
							Layout.fillWidth: true
							spacing: 8

							ColumnLayout {
								Layout.fillWidth: true
								spacing: 0

								Text {
									Layout.fillWidth: true
									text: MediaState.hasTrack
											? MediaState.title
											: "Nothing playing"
									color: MediaState.hasTrack
											? Theme.text
											: Theme.textMuted
									font.family: Theme.labelFont
									font.pixelSize: Theme.fontSize(13)
									elide: Text.ElideRight
								}

								Text {
									Layout.fillWidth: true
									visible: MediaState.artist.length > 0
									text: MediaState.artist
									color: Theme.textMuted
									font.family: Theme.labelFont
									font.pixelSize: Theme.fontSize(11)
									elide: Text.ElideRight
								}
							}

							Text {
								Layout.alignment: Qt.AlignTop
								padding: 6
								text: root.mediaMenuOpen
										? "󰅃"
										: "󰅀"
								color: mediaMenuHover.hovered || root.mediaMenuOpen
										? Theme.highlight
										: Theme.textMuted
								font.pixelSize: Theme.fontSize(14)

								HoverHandler {
									id: mediaMenuHover
									cursorShape: Qt.PointingHandCursor
								}

								TapHandler {
									onTapped: root.toggleMediaMenu()
								}
							}
						}

						//-----------
						// seek bar
						//-----------
						RowLayout {
							Layout.fillWidth: true
							spacing: 8

							Text {
								Layout.preferredWidth: 34
								text: MediaState.formatTime(MediaState.position)
								color: Theme.textMuted
								font.family: Theme.labelFont
								font.pixelSize: Theme.fontSize(10)
							}

							LevelSlider {
								id: seekSlider

								Layout.fillWidth: true
								enabled: MediaState.seekable
										&& MediaState.hasPlayer
										&& MediaState.active.canSeek
								from: 0
								// a zero length track would collapse the track to a
								// point and make the handle jump around
								to: Math.max(1, MediaState.length)
								value: MediaState.position

								onMoved: MediaState.seekTo(value)

								// position advances on a timer, so only follow it
								// while the user is not holding the handle
								Connections {
									target: MediaState
									function onPositionChanged() {
										if (!seekSlider.pressed) {
											seekSlider.value = MediaState.position
										}
									}
								}
							}

							Text {
								Layout.preferredWidth: 34
								horizontalAlignment: Text.AlignRight
								text: MediaState.formatTime(MediaState.length)
								color: Theme.textMuted
								font.family: Theme.labelFont
								font.pixelSize: Theme.fontSize(10)
							}
						}

						//------------
						// transport
						//------------
						MediaControls {
							Layout.fillWidth: true
						}
					}
				}
			}

			//---------------------
			// media source picker
			//---------------------
			Rectangle {
				Layout.fillWidth: true
				visible: root.mediaMenuOpen
				implicitWidth: content.rowWidth
				implicitHeight: mediaMenu.implicitHeight + 16
				radius: Theme.radiusSmall
				color: Theme.alpha(Theme.text, 0.05)
				border.color: Theme.borderSoft
				border.width: Theme.borderWidth

				ColumnLayout {
					id: mediaMenu

					anchors.left: parent.left
					anchors.right: parent.right
					anchors.top: parent.top
					anchors.margins: 8
					spacing: 2

					Text {
						Layout.fillWidth: true
						leftPadding: 8
						bottomPadding: 2
						text: "SOURCE"
						color: Theme.textMuted
						font.family: Theme.labelFont
						font.pixelSize: Theme.fontSize(10)
						font.bold: true
					}

					PickerRow {
						label: "Automatic"
						detail: "Whatever is playing"
						glyph: "󰑫"
						selected: Prefs.mediaPreferredPlayer.length === 0
						onPicked: Prefs.mediaPreferredPlayer = ""
					}

					Repeater {
						model: MediaState.players

						PickerRow {
							required property var modelData

							readonly property string identity: MediaState.identityOf(modelData)

							label: identity
							detail: modelData.isPlaying
									? "Playing"
									: "Paused"
							glyph: "󰝚"
							selected: Prefs.mediaPreferredPlayer === identity
							onPicked: Prefs.mediaPreferredPlayer = identity
						}
					}

					PickerRow {
						label: "Media settings"
						glyph: "󰒓"
						onPicked: root.openSettings("media")
					}
				}
			}
		}
	}

	//-------------------
	// picker menu entry
	//-------------------
	// one line in either of the inline pickers. it reports `picked` rather than
	// acting itself so the same row works for outputs, players and the links
	// through to the settings window
	component PickerRow: Rectangle {
		id: pick

		property string label: ""
		property string detail: ""
		property string glyph: ""
		property bool selected: false

		signal picked()

		Layout.fillWidth: true
		implicitHeight: 28
		radius: Theme.radiusSmall

		color: pick.selected
				? Theme.selectionSoft
				: pickHover.hovered
					? Theme.hoverFaint
					: "transparent"

		HoverHandler {
			id: pickHover
			cursorShape: Qt.PointingHandCursor
		}

		TapHandler {
			onTapped: pick.picked()
		}

		RowLayout {
			anchors.fill: parent
			anchors.leftMargin: 8
			anchors.rightMargin: 8
			spacing: 8

			Text {
				visible: pick.glyph.length > 0
				text: pick.glyph
				color: pick.selected
						? Theme.highlight
						: Theme.textMuted
				font.pixelSize: Theme.fontSize(13)
			}

			Text {
				Layout.fillWidth: true
				text: pick.label
				color: Theme.text
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(12)
				elide: Text.ElideRight
			}

			Text {
				visible: pick.detail.length > 0
				text: pick.detail
				color: Theme.textFaint
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(10)
			}
		}
	}
}
