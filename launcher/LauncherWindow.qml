import QtQuick
import Quickshell
import Quickshell.Wayland

PanelWindow {
	id: root

	required property var modelData
	screen: modelData

	// Exclusive keyboard focus while open so Esc and typing stay on the launcher
	visible: LauncherState.open
	focusable: true
	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.keyboardFocus: WlrKeyboardFocus.Exclusive

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	color: "transparent"

	// closes even when the search field is focused
	Shortcut {
		sequence: "Escape"
		context: Qt.WindowShortcut
		enabled: LauncherState.open
		onActivated: LauncherState.hide()
	}

	// allows clicking outside the launcher to close it
	MouseArea {
		anchors.fill: parent
		onClicked: LauncherState.hide()
	}

	LauncherContent {
		anchors.centerIn: parent
	}
}
