pragma Singleton

import Quickshell

Singleton {
	id: root

	//-------------------
	// public properties
	//-------------------
	// sidebar order, and the page each entry loads
	readonly property var pages: [
		{ id: "general", label: "General", glyph: "󰒓", source: "pages/GeneralPage.qml" },
		{ id: "network", label: "Network", glyph: "󰤨", source: "pages/NetworkPage.qml" },
		{ id: "bluetooth", label: "Bluetooth", glyph: "󰂯", source: "pages/BluetoothPage.qml" },
		{ id: "audio", label: "Audio", glyph: "󰕾", source: "pages/AudioPage.qml" },
		{ id: "media", label: "Media", glyph: "󰝚", source: "pages/MediaPage.qml" },
		{ id: "dock", label: "Dock", glyph: "󰀻", source: "pages/DockPage.qml" },
		{ id: "appearance", label: "Appearance", glyph: "󰏘", source: "pages/AppearancePage.qml" }
	]

	property bool open: false
	property string page: "general"

	readonly property string pageSource: root.sourceFor(root.page)

	//----------
	// controls
	//----------
	function toggle() {
		if (open) {
			hide()
		} else {
			show()
		}
	}

	function show() {
		open = true
	}

	function hide() {
		open = false
	}

	// opens the window directly on a page, used by the control center buttons
	function showPage(page) {
		if (root.sourceFor(page).length) {
			root.page = page
		}
		root.show()
	}

	//---------
	// helpers
	//---------
	function sourceFor(page) {
		for (let i = 0; i < root.pages.length; i++) {
			if (root.pages[i].id === page) {
				return root.pages[i].source
			}
		}
		return ""
	}
}
