import QtQuick
import QtQuick.Layouts
import Quickshell

import "../theme"
// the loader below picks a page by file name at runtime, so these directories
// are never reached by an import quickshell can see while it scans the config.
// importing them here is what makes their types resolvable.
import "pages"
import "components"

FloatingWindow {
	id: root

	title: "Settings"
	color: Theme.surface

	implicitWidth: 940
	implicitHeight: 640
	minimumSize: Qt.size(760, 520)

	visible: SettingsState.open

	// the window manager close button bypasses SettingsState, so mirror the
	// close back into state and restore the binding for the next open
	onClosed: {
		SettingsState.hide()
		root.visible = Qt.binding(() => SettingsState.open)
	}

	Shortcut {
		sequence: "Escape"
		context: Qt.WindowShortcut
		enabled: SettingsState.open
		onActivated: SettingsState.hide()
	}

	RowLayout {
		anchors.fill: parent
		spacing: 0

		SettingsSidebar {
			Layout.fillHeight: true
			Layout.preferredWidth: 200
		}

		// vertical rule between the nav and the current page
		Rectangle {
			Layout.fillHeight: true
			implicitWidth: 1
			color: Theme.alpha(Theme.text, 0.12)
		}

		//--------------
		// current page
		//--------------
		// unloading while hidden stops background work, most importantly the
		// wifi scan the network page keeps running
		Loader {
			Layout.fillWidth: true
			Layout.fillHeight: true

			active: root.visible
			source: SettingsState.pageSource
		}
	}
}
