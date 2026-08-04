pragma Singleton

import Quickshell

Singleton {
	//-------------------
	// public properties
	//-------------------
	property bool open: false
	property string query: ""
	property int selectedIndex: 0

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
		query = ""
		selectedIndex = 0
		open = true
	}

	function hide() {
		open = false
		query = ""
		selectedIndex = 0
	}
}
