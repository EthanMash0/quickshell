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

	// the pin list in order, resolved to desktop entries. entries that no longer
	// resolve are kept with a null entry so the settings page can show them as
	// broken rather than silently dropping them like `items` above does
	readonly property var pinnedEntries: {
		const result = []

		for (let i = 0; i < root.pinnedIds.length; i++) {
			const id = root.pinnedIds[i]
			result.push({ id: id, entry: root.entryForId(id) })
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

	// moves the pin at `from` to `to`, clamping rather than wrapping so the
	// buttons at either end of the settings list simply do nothing
	function move(from, to) {
		const next = root.pinnedIds.slice()

		if (from < 0 || from >= next.length) return
		if (to < 0 || to >= next.length) return
		if (from === to) return

		const [moved] = next.splice(from, 1)
		next.splice(to, 0, moved)

		root.pinnedIds = next
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
