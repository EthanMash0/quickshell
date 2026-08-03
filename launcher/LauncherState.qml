pragma Singleton

import Quickshell

Singleton {
	property bool open: false
	property string query: ""

	function toggle() {
		open = !open

		if (!open) {
			query = ""
		}
	}

	function show() {
		open = true
	}

	function hide() {
		open = false
		query = ""
	}
}
