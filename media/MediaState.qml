pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Services.Mpris

import "../prefs"

// picks which mpris player the shell should follow and exposes it as one
// stable object, so widgets do not each have to reimplement the choice
Singleton {
	id: root

	readonly property var players: Mpris.players.values

	// players that can actually be driven, anything else is noise in a picker
	readonly property var controllable: root.players.filter(p => p.canControl)

	//---------------
	// active player
	//---------------
	// an explicit preference wins whenever that player is running, otherwise
	// follow whatever is playing, falling back to the first thing available
	readonly property var active: {
		const list = root.players
		if (list.length === 0) return null

		const preferred = Prefs.mediaPreferredPlayer
		if (preferred.length > 0) {
			for (let i = 0; i < list.length; i++) {
				if (root.identityOf(list[i]) === preferred) {
					return list[i]
				}
			}
		}

		for (let i = 0; i < list.length; i++) {
			if (list[i].isPlaying) return list[i]
		}

		return list[0]
	}

	readonly property bool hasPlayer: !!root.active
	readonly property bool playing: root.hasPlayer && root.active.isPlaying

	readonly property string title: root.hasPlayer
			? (root.active.trackTitle || "")
			: ""

	readonly property string artist: root.hasPlayer
			? (root.active.trackArtist || root.active.trackAlbumArtist || "")
			: ""

	readonly property string album: root.hasPlayer
			? (root.active.trackAlbum || "")
			: ""

	readonly property string artUrl: root.hasPlayer && Prefs.mediaShowArt
			? (root.active.trackArtUrl || "")
			: ""

	// something worth showing, as opposed to a player sitting idle with no track
	readonly property bool hasTrack: root.hasPlayer
			&& (root.title.length > 0 || root.artist.length > 0)

	//----------
	// position
	//----------
	// mpris does not push position updates, so it has to be pulled. the tick
	// exists purely to give the bindings below something to invalidate on
	property int positionTick: 0

	readonly property bool seekable: root.hasPlayer
			&& root.active.lengthSupported
			&& root.active.length > 0

	readonly property real position: {
		root.positionTick
		return root.hasPlayer && root.active.positionSupported
				? root.active.position
				: 0
	}

	readonly property real length: root.seekable
			? root.active.length
			: 0

	Timer {
		interval: 1000
		repeat: true
		running: root.playing && root.seekable
		onTriggered: root.positionTick++
	}

	//----------
	// controls
	//----------
	function toggle() {
		if (root.hasPlayer && root.active.canTogglePlaying) {
			root.active.togglePlaying()
		}
	}

	function next() {
		if (root.hasPlayer && root.active.canGoNext) {
			root.active.next()
		}
	}

	function previous() {
		if (root.hasPlayer && root.active.canGoPrevious) {
			root.active.previous()
		}
	}

	function seekTo(seconds) {
		if (root.hasPlayer && root.active.canSeek) {
			root.active.position = seconds
			root.positionTick++
		}
	}

	//---------
	// helpers
	//---------
	function identityOf(player) {
		if (!player) return ""

		return player.identity || player.dbusName || ""
	}

	// mm:ss, or h:mm:ss once a track runs past an hour
	function formatTime(seconds) {
		if (!(seconds > 0)) return "0:00"

		const total = Math.floor(seconds)
		const s = total % 60
		const m = Math.floor(total / 60) % 60
		const h = Math.floor(total / 3600)

		const ss = `${s}`.padStart(2, "0")

		return h > 0
				? `${h}:${`${m}`.padStart(2, "0")}:${ss}`
				: `${m}:${ss}`
	}

	// one line summary used by the bar and the control center
	function summary() {
		if (!root.hasTrack) return ""

		return root.artist.length > 0
				? `${root.title} — ${root.artist}`
				: root.title
	}
}
