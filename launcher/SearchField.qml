import QtQuick
import QtQuick.Controls

TextField {
	id: root

	//------------------------
	// signals to parent card
	//------------------------
	signal moveSelectionRequested(int delta)
	signal launchRequested()
	signal scrollToTopRequested()

	//---------------
	// field styling
	//---------------
	implicitHeight: 36

	placeholderText: "Search apps..."
	placeholderTextColor: "#88ebdbb2"
	color: "#ebdbb2"
	font.pixelSize: 14
	rightPadding: 8
	leftPadding: 8

	background: Rectangle {
		radius: 6
		color: "#33181818"
		border.color: "#66ebdbb2"
		border.width: 1
	}

	//-------------
	// query state
	//-------------
	text: LauncherState.query
	onTextChanged: {
		if (text !== LauncherState.query) {
			LauncherState.query = text
			LauncherState.selectedIndex = 0
			root.scrollToTopRequested()
		}
	}

	//----------
	// keybinds
	//----------
	Keys.onPressed: event => {
		if (event.key === Qt.Key_Tab) {
			root.moveSelectionRequested(1)
			event.accepted = true
		} else if (event.key === Qt.Key_Backtab) {
			root.moveSelectionRequested(-1)
			event.accepted = true
		} else if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
			root.launchRequested()
			event.accepted = true
		}
	}

	function clearAndFocus() {
		root.text = ""
		LauncherState.query = ""
		forceActiveFocus()
	}
}
