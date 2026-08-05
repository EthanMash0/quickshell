pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io
import Quickshell.Wayland

Singleton {
	id: root

	// public properties
	property alias pinnedIds: dockJson.pinnedIds

	readonly property var items: {
		const pins = root.pinnedIds
		const tops = ToplevelManager.toplevels.values

		const result = []
		const seen = {}

		for (let i = 0; i < pins.length; i++) {
			const entry = root.entryForId(pins[i])
			if (!entry) continue

			const key = entry.id.toLowerCase()
			if (seen[key]) continue
			seen[key] = true

			result.push({ entry: entry, pinned: true })
		}

		for (let i = 0; i < tops.length; i++) {
			const top = tops[i]
			const entry = root.entryForId(top.appId || "")
			if (!entry) continue

			const key = entry.id.toLowerCase()
			if (seen[key]) continue
			seen[key] = true

			result.push({ entry: entry, pinned: false })
		}

		return result
	}

	//-----------------
	// pin persistence
	//-----------------
	FileView {
		id: dockFile
		path: `${Quickshell.configDir}/dock.json`
		watchChanges: true
		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		onLoadFailed: error => {
			if (error === FileViewError.FileNotFound) {
				writeAdapter()
			}
		}

		JsonAdapter {
			id: dockJson

			property list<string> pinnedIds: [
			]
		}
	}

	//---------
	// helpers
	//---------
	function entryForId(id) {
		if (!id || !id.length) return null

		return DesktopEntries.byId(id) || DesktopEntries.heuristicLookup(id)
	}

	function isPinned(id) {
		if (!id) return false

		const key = id.toLowerCase()
		for (let i = 0; i < root.pinnedIds.length; i++) {
			if ((root.pinnedIds[i] || "").toLowerCase() === key) {
				return true
			}
		}
		return false
	}

	function pin(id) {
		if (!id || root.isPinned(id)) return

		const next = root.pinnedIds.slice()
		next.push(id)
		root.pinnedIds = next
	}

	function unpin(id) {
		if (!id) return

		const key = id.toLowerCase()
		root.pinnedIds = root.pinnedIds.filter(p => (p || "").toLowerCase() !== key)
	}

	function windowsFor(entry) {
		if (!entry) return []

		const entryId = (entry.id || "").toLowerCase()
		const startup = (entry.startupClass || "").toLowerCase()

		return ToplevelManager.toplevels.values.filter(top => {
			const id = (top.appId || "").toLowerCase()

			return id === entryId || (startup.length > 0 && id === startup)
		})
	}

	function closeAll(windows) {
		for (let i = 0; i < windows.length; i++) {
			windows[i].close()
		}
	}
}
