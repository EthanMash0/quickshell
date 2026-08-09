import QtQuick
import QtQuick.Layouts
import Quickshell

import "../../theme"
import "../../bar/center"
import "../components"

SettingsPage {
	id: root

	title: "Dock"
	description: "Applications pinned to the middle of the bar. Running apps are always shown, pinned ones stay put when they are closed."

	//------------
	// pin list
	//------------
	readonly property var pins: DockState.pinnedEntries

	//------------
	// app picker
	//------------
	property string query: ""

	// everything installed that is not already pinned, filtered by the search
	readonly property var candidates: {
		const q = root.query.trim().toLowerCase()
		const apps = DesktopEntries.applications.values

		const matched = []
		for (let i = 0; i < apps.length; i++) {
			const app = apps[i]
			if (DockState.isPinned(app.id)) continue

			if (q.length > 0) {
				const name = (app.name || "").toLowerCase()
				const id = (app.id || "").toLowerCase()
				if (!name.includes(q) && !id.includes(q)) continue
			}

			matched.push(app)
		}

		matched.sort((a, b) =>
			(a.name || "").toLowerCase().localeCompare((b.name || "").toLowerCase()))

		// the full list is hundreds of entries, which is neither useful nor fast
		return matched.slice(0, 12)
	}

	//---------
	// helpers
	//---------
	function iconFor(entry) {
		return entry
				? Quickshell.iconPath(entry.icon, true)
				: ""
	}

	//---------------
	// pinned card
	//---------------
	Card {
		title: "PINNED"

		InfoText {
			visible: root.pins.length === 0
			text: "Nothing pinned yet. Add an app below, or right click one in the bar."
		}

		Repeater {
			model: root.pins

			ListRow {
				required property var modelData
				required property int index

				readonly property var entry: modelData.entry

				// a pin whose desktop file has gone away still occupies a slot, so
				// show it as broken rather than hiding it like the bar does
				readonly property bool broken: !entry

				iconSource: root.iconFor(entry)
				glyph: broken
						? "󰀦"
						: ""
				title: entry
						? (entry.name || entry.id)
						: modelData.id
				subtitle: broken
						? "Not installed"
						: modelData.id
				interactive: false

				ActionButton {
					label: "󰅃"
					enabled: index > 0
					onClicked: DockState.move(index, index - 1)
				}

				ActionButton {
					label: "󰅀"
					enabled: index < root.pins.length - 1
					onClicked: DockState.move(index, index + 1)
				}

				ActionButton {
					label: "Remove"
					destructive: true
					onClicked: DockState.unpin(modelData.id)
				}
			}
		}
	}

	//-------------
	// add an app
	//-------------
	Card {
		title: "ADD AN APP"

		InputField {
			Layout.fillWidth: true
			placeholderText: "Search applications..."
			onTextEdited: root.query = text
		}

		InfoText {
			visible: root.candidates.length === 0
			text: root.query.trim().length > 0
					? "No applications match that."
					: "Everything installed is already pinned."
		}

		Repeater {
			model: root.candidates

			ListRow {
				required property var modelData

				iconSource: root.iconFor(modelData)
				title: modelData.name || modelData.id
				subtitle: modelData.id

				onClicked: DockState.pin(modelData.id)

				ActionButton {
					label: "Pin"
					primary: true
					onClicked: DockState.pin(modelData.id)
				}
			}
		}
	}
}
