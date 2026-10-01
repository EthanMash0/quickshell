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
	// empty means automatic: prefer a dedicated gpu over an integrated one
	property alias gpuPciSlot: prefsJson.gpuPciSlot

	property alias mediaPreferredPlayer: prefsJson.mediaPreferredPlayer
	property alias mediaShowArt: prefsJson.mediaShowArt
	property alias mediaShowInControlCenter: prefsJson.mediaShowInControlCenter

	property alias barShowLeft: prefsJson.barShowLeft
	property alias barShowCenter: prefsJson.barShowCenter
	property alias barShowRight: prefsJson.barShowRight
	property alias barShowPower: prefsJson.barShowPower
	property alias barShowWorkspaces: prefsJson.barShowWorkspaces
	property alias barShowApps: prefsJson.barShowApps
	property alias barShowUsage: prefsJson.barShowUsage
	property alias barShowTray: prefsJson.barShowTray
	property alias barShowControlCenter: prefsJson.barShowControlCenter
	property alias barShowClock: prefsJson.barShowClock

	// the panel itself goes away when every section or every widget in it is off
	readonly property bool barVisible: {
		if (root.barShowLeft && (root.barShowPower || root.barShowWorkspaces))
			return true
		if (root.barShowCenter && root.barShowApps)
			return true
		if (root.barShowRight && (root.barShowUsage || root.barShowTray || root.barShowControlCenter || root.barShowClock))
			return true
		return false
	}

	//--------------
	// clock format
	//--------------
	// a custom string wins outright, otherwise it is assembled from the toggles
	readonly property string clockTimeFormat: {
		const custom = root.clockCustomFormat.trim()
		if (custom.length > 0) return custom

		let out = root.clockUse24Hour
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

	readonly property string clockDateFormat: "ddd MMM d"

	// SystemClock only ticks as often as it is told to, so seconds need the
	// finer precision to actually advance
	readonly property bool clockNeedsSeconds: root.clockTimeFormat.includes("ss")

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
		root.gpuPciSlot = ""
		root.mediaPreferredPlayer = ""
		root.mediaShowArt = true
		root.mediaShowInControlCenter = true
		root.barShowLeft = true
		root.barShowCenter = true
		root.barShowRight = true
		root.barShowPower = true
		root.barShowWorkspaces = true
		root.barShowApps = true
		root.barShowUsage = true
		root.barShowTray = true
		root.barShowControlCenter = true
		root.barShowClock = true
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
			// pci slot such as 0000:04:00.0. empty prefers a dedicated gpu
			property string gpuPciSlot: ""

			// empty means "whichever player is currently playing"
			property string mediaPreferredPlayer: ""
			property bool mediaShowArt: true
			property bool mediaShowInControlCenter: true

			property bool barShowLeft: true
			property bool barShowCenter: true
			property bool barShowRight: true
			property bool barShowPower: true
			property bool barShowWorkspaces: true
			property bool barShowApps: true
			property bool barShowUsage: true
			property bool barShowTray: true
			property bool barShowControlCenter: true
			property bool barShowClock: true
		}
	}
}
