pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// behaviour settings, as opposed to the styling ones in theme/Theme.qml.
// kept in a separate file so appearance and behaviour can be reset apart
Singleton {
	id: root

	//------------------------------
	// user values (from prefs.json)
	//------------------------------
	property alias clockUse24Hour: prefsJson.clockUse24Hour
	property alias clockShowDate: prefsJson.clockShowDate
	property alias clockShowSeconds: prefsJson.clockShowSeconds
	property alias clockCustomFormat: prefsJson.clockCustomFormat

	property alias calendarCommand: prefsJson.calendarCommand
	property alias systemMonitorCommand: prefsJson.systemMonitorCommand

	property alias mediaPreferredPlayer: prefsJson.mediaPreferredPlayer
	property alias mediaShowArt: prefsJson.mediaShowArt
	property alias mediaShowInControlCenter: prefsJson.mediaShowInControlCenter

	//--------------
	// clock format
	//--------------
	// a custom string wins outright, otherwise it is assembled from the toggles
	readonly property string clockFormat: {
		const custom = root.clockCustomFormat.trim()
		if (custom.length > 0) {
			return custom
		}

		let out = root.clockShowDate
				? "ddd MMM d  "
				: ""

		out += root.clockUse24Hour
				? "HH:mm"
				: "hh:mm"

		if (root.clockShowSeconds) {
			out += ":ss"
		}

		if (!root.clockUse24Hour) {
			out += " AP"
		}

		return out
	}

	// SystemClock only ticks as often as it is told to, so seconds need the
	// finer precision to actually advance
	readonly property bool clockNeedsSeconds: root.clockFormat.includes("ss")

	//---------
	// helpers
	//---------
	// commands go through a shell so users can write pipes, flags and quoting
	// in the settings field rather than a bare argv
	function run(command) {
		const cmd = (command || "").trim()
		if (!cmd.length) return

		Quickshell.execDetached(["sh", "-c", cmd])
	}

	function resetToDefaults() {
		root.clockUse24Hour = false
		root.clockShowDate = true
		root.clockShowSeconds = false
		root.clockCustomFormat = ""
		root.calendarCommand = "gnome-calendar"
		root.systemMonitorCommand = "alacritty -e btop"
		root.mediaPreferredPlayer = ""
		root.mediaShowArt = true
		root.mediaShowInControlCenter = true
	}

	//-------------------
	// prefs persistence
	//-------------------
	FileView {
		id: prefsFile
		path: `${Quickshell.configDir}/prefs.json`
		watchChanges: true
		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		onLoadFailed: error => {
			if (error === FileViewError.FileNotFound) {
				writeAdapter()
			}
		}

		JsonAdapter {
			id: prefsJson

			property bool clockUse24Hour: false
			property bool clockShowDate: true
			property bool clockShowSeconds: false
			// overrides the toggles above, uses Qt date format tokens
			property string clockCustomFormat: ""

			property string calendarCommand: "gnome-calendar"
			property string systemMonitorCommand: "alacritty -e btop"

			// empty means "whichever player is currently playing"
			property string mediaPreferredPlayer: ""
			property bool mediaShowArt: true
			property bool mediaShowInControlCenter: true
		}
	}
}
