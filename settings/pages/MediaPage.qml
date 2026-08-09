import QtQuick
import QtQuick.Layouts
import Quickshell.Services.Mpris

import "../../theme"
import "../../prefs"
import "../../media"
import "../components"

SettingsPage {
	id: root

	title: "Media"
	description: "Controls whichever MPRIS player the shell is following, and the media row in the control center."

	readonly property var player: MediaState.active

	//------------------
	// now playing card
	//------------------
	Card {
		title: "NOW PLAYING"

		InfoText {
			visible: !MediaState.hasPlayer
			text: "No media player is running. Start one and it will show up here."
		}

		RowLayout {
			Layout.fillWidth: true
			visible: MediaState.hasPlayer
			spacing: 14

			// album art
			Rectangle {
				visible: Prefs.mediaShowArt
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
					font.pixelSize: Theme.fontSize(26)
				}
			}

			ColumnLayout {
				Layout.fillWidth: true
				spacing: 2

				Text {
					Layout.fillWidth: true
					text: MediaState.hasTrack
							? MediaState.title
							: "Nothing playing"
					color: Theme.text
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(15)
					font.bold: true
					elide: Text.ElideRight
				}

				Text {
					Layout.fillWidth: true
					visible: MediaState.artist.length > 0
					text: MediaState.artist
					color: Theme.textMuted
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(12)
					elide: Text.ElideRight
				}

				Text {
					Layout.fillWidth: true
					visible: MediaState.album.length > 0
					text: MediaState.album
					color: Theme.textFaint
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(11)
					elide: Text.ElideRight
				}

				Text {
					Layout.topMargin: 2
					text: MediaState.hasPlayer
							? MediaState.identityOf(root.player)
							: ""
					color: Theme.textFaint
					font.family: Theme.labelFont
					font.pixelSize: Theme.fontSize(11)
				}
			}
		}

		//-----------
		// seek bar
		//-----------
		RowLayout {
			Layout.fillWidth: true
			visible: MediaState.seekable
			spacing: 10

			Text {
				Layout.preferredWidth: 44
				text: MediaState.formatTime(MediaState.position)
				color: Theme.textMuted
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(11)
			}

			LevelSlider {
				id: seekSlider

				Layout.fillWidth: true
				enabled: MediaState.hasPlayer && root.player.canSeek
				from: 0
				to: Math.max(1, MediaState.length)
				value: MediaState.position

				onMoved: MediaState.seekTo(value)

				// the position ticks on a timer, so pull it in whenever the user
				// is not the one holding the handle
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
				Layout.preferredWidth: 44
				horizontalAlignment: Text.AlignRight
				text: MediaState.formatTime(MediaState.length)
				color: Theme.textMuted
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(11)
			}
		}

		//------------
		// transport
		//------------
		RowLayout {
			Layout.fillWidth: true
			visible: MediaState.hasPlayer
			spacing: 8

			ActionButton {
				label: "󰒮"
				enabled: MediaState.hasPlayer && root.player.canGoPrevious
				onClicked: MediaState.previous()
			}

			ActionButton {
				label: MediaState.playing
						? "󰏤"
						: "󰐊"
				primary: true
				enabled: MediaState.hasPlayer && root.player.canTogglePlaying
				onClicked: MediaState.toggle()
			}

			ActionButton {
				label: "󰒭"
				enabled: MediaState.hasPlayer && root.player.canGoNext
				onClicked: MediaState.next()
			}

			ActionButton {
				visible: MediaState.hasPlayer && root.player.shuffleSupported
				label: "󰒝"
				primary: MediaState.hasPlayer && root.player.shuffle
				onClicked: root.player.shuffle = !root.player.shuffle
			}

			ActionButton {
				visible: MediaState.hasPlayer && root.player.loopSupported
				label: "󰑖"
				primary: MediaState.hasPlayer && root.player.loopState !== MprisLoopState.None
				onClicked: {
					// cycle none -> playlist -> track -> none
					switch (root.player.loopState) {
						case MprisLoopState.None:
							root.player.loopState = MprisLoopState.Playlist
							break
						case MprisLoopState.Playlist:
							root.player.loopState = MprisLoopState.Track
							break
						default:
							root.player.loopState = MprisLoopState.None
					}
				}
			}

			Item {
				Layout.fillWidth: true
			}

			ActionButton {
				visible: MediaState.hasPlayer && root.player.canRaise
				label: "Open"
				onClicked: root.player.raise()
			}
		}

		//------------------
		// player volume
		//------------------
		SettingRow {
			visible: MediaState.hasPlayer && root.player.volumeSupported
			label: "Player volume"
			description: "Separate from the system volume on the audio page."

			LevelSlider {
				id: volumeSlider

				Layout.preferredWidth: 200
				from: 0
				to: 1
				value: MediaState.hasPlayer
						? root.player.volume
						: 0

				onMoved: root.player.volume = value
			}
		}
	}

	//---------------
	// player choice
	//---------------
	Card {
		title: "PLAYER"

		SettingRow {
			label: "Follow"
			description: "Automatic uses whichever player is currently playing."
		}

		ListRow {
			glyph: "󰑫"
			title: "Automatic"
			subtitle: "Whichever player is playing"
			highlighted: Prefs.mediaPreferredPlayer.length === 0
			onClicked: Prefs.mediaPreferredPlayer = ""
		}

		Repeater {
			model: MediaState.players

			ListRow {
				required property var modelData

				readonly property string identity: MediaState.identityOf(modelData)

				glyph: "󰝚"
				title: identity
				subtitle: modelData.isPlaying
						? "Playing"
						: "Paused"
				highlighted: Prefs.mediaPreferredPlayer === identity
				onClicked: Prefs.mediaPreferredPlayer = identity
			}
		}

		InfoText {
			visible: MediaState.players.length === 0
			text: "No players are running, so there is nothing to choose between yet."
		}

		InfoText {
			visible: Prefs.mediaPreferredPlayer.length > 0
					&& !MediaState.players.some(p => MediaState.identityOf(p) === Prefs.mediaPreferredPlayer)
			text: `"${Prefs.mediaPreferredPlayer}" is not running, so the shell is following whatever is playing instead.`
		}
	}

	//----------
	// options
	//----------
	Card {
		title: "OPTIONS"

		SettingRow {
			label: "Show in control center"
			description: "Adds the media row to the control center popup."

			Toggle {
				checked: Prefs.mediaShowInControlCenter
				onToggled: value => Prefs.mediaShowInControlCenter = value
			}
		}

		SettingRow {
			label: "Show album art"
			description: "Turn off for a more compact row."

			Toggle {
				checked: Prefs.mediaShowArt
				onToggled: value => Prefs.mediaShowArt = value
			}
		}
	}
}
