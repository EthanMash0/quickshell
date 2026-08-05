import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

ListView {
	id: root

	//---------
	// styling
	//---------
	clip: true
	spacing: 4
	model: root.results

	//----------------------------
	// filter + sort applications
	//----------------------------
	readonly property var results: {
		const q = LauncherState.query.trim().toLowerCase()
		const apps = DesktopEntries.applications.values
		const byName = (a, b) =>
			(a.name || "").toLowerCase().localeCompare((b.name || "").toLowerCase())

		// empty query: alphabetical, capped for performance
		if (!q.length) {
			return apps.slice().sort(byName).slice(0, 40)
		}

		const matched = []
		for (let i = 0; i < apps.length; i++) {
			const app = apps[i]
			const name = (app.name || "").toLowerCase()
			const generic = (app.genericName || "").toLowerCase()
			const id = (app.id || "").toLowerCase()
			if (name.includes(q) || generic.includes(q) || id.includes(q)) {
				matched.push(app)
			}
		}

		// prefix matches first, then alphabetical
		matched.sort((a, b) => {
			const an = (a.name || "").toLowerCase()
			const bn = (b.name || "").toLowerCase()
			const ap = an.startsWith(q) ? 0 : 1
			const bp = bn.startsWith(q) ? 0 : 1
			if (ap !== bp) return ap - bp
			return an.localeCompare(bn)
		})

		return matched.slice(0, 40)
	}

	//-------------------
	// selection helpers
	//-------------------
	function launchIndex(index) {
		const app = root.results[index]
		if (!app) return
		app.execute()
		LauncherState.hide()
	}

	function launchSelected() {
		root.launchIndex(LauncherState.selectedIndex)
	}

	function moveSelection(delta) {
		const count = root.results.length
		if (count <= 0) {
			LauncherState.selectedIndex = 0
			return
		}
		// clamp, do not wrap around the list
		LauncherState.selectedIndex = Math.max(0, Math.min(count - 1, LauncherState.selectedIndex + delta))
		root.ensureSelectionVisible()
	}

	function setSelection(index) {
		const count = root.results.length
		if (count <= 0) {
			LauncherState.selectedIndex = 0
			return
		}
		LauncherState.selectedIndex = Math.max(0, Math.min(count - 1, index))
		root.ensureSelectionVisible()
	}

	function resetScroll() {
		root.contentY = 0
	}

	// nudge contentY only when the selected row is off-screen
	function ensureSelectionVisible() {
		const index = LauncherState.selectedIndex
		if (index < 0 || index >= root.results.length)
			return

		const item = root.itemAtIndex(index)
		if (!item) {
			root.positionViewAtIndex(index, ListView.Visible)
			return
		}

		const top = root.contentY
		const bottom = top + root.height
		const y = item.y
		const h = item.height
		const maxY = Math.max(0, root.contentHeight - root.height)

		if (y < top)
			root.contentY = Math.max(0, Math.min(maxY, y))
		else if (y + h > bottom)
			root.contentY = Math.max(0, Math.min(maxY, y + h - root.height))
	}

	//----------
	// app rows
	//----------
	// selection is keyboard-driven only, hover does not change selectedIndex
	delegate: WrapperMouseArea {
		id: row
		required property var modelData
		required property int index

		implicitWidth: root.width
		cursorShape: Qt.PointingHandCursor
		hoverEnabled: true

		onClicked: {
			LauncherState.selectedIndex = index
			root.launchIndex(index)
		}

		Rectangle {
			implicitWidth: root.width
			implicitHeight: 44
			radius: 6
			color: index === LauncherState.selectedIndex
				? (root.activeFocus ? "#33ebdbb2" : "#22ebdbb2")
				: row.containsMouse
					? "#12ebdbb2"
					: "transparent"

			RowLayout {
				anchors.fill: parent
				anchors.leftMargin: 10
				anchors.rightMargin: 10
				spacing: 10

				IconImage {
					source: Quickshell.iconPath(modelData.icon, true)
					implicitSize: 28
				}

				ColumnLayout {
					Layout.fillWidth: true
					spacing: 0

					Text {
						Layout.fillWidth: true
						color: "#ebdbb2"
						font.pixelSize: 14
						elide: Text.ElideRight
						text: modelData.name || modelData.id
					}

					Text {
						Layout.fillWidth: true
						visible: !!(modelData.genericName && modelData.genericName.length)
						color: "#88ebdbb2"
						font.pixelSize: 11
						elide: Text.ElideRight
						text: modelData.genericName || ""
					}
				}
			}
		}
	}
}
