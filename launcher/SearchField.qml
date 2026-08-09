import QtQuick
import QtQuick.Controls

import "../theme"

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
	placeholderTextColor: Theme.textMuted
	color: Theme.text
	font.family: Theme.labelFont
	font.pixelSize: Theme.fontSize(14)
	rightPadding: 8
	leftPadding: 8

	background: Rectangle {
		radius: Theme.radiusSmall
		color: Theme.inputBackground
		border.color: Theme.borderSoft
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
