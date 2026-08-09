import QtQuick
import QtQuick.Layouts

import "../theme"

Rectangle {
	id: root
	width: Theme.launcherWidth
	height: Theme.launcherHeight
	radius: Theme.radius
	color: Theme.surface
	border.color: Theme.border
	border.width: Theme.borderWidth

	ColumnLayout {
		anchors.fill: parent
		anchors.margins: 12
		spacing: 10

		//--------------
		// search field
		//--------------
		SearchField {
			id: searchField
			Layout.fillWidth: true

			onMoveSelectionRequested: delta => resultsList.moveSelection(delta)
			onLaunchRequested: resultsList.launchSelected()
			onScrollToTopRequested: resultsList.resetScroll()
		}

		//--------------
		// results list
		//--------------
		ResultsList {
			id: resultsList
			Layout.fillWidth: true
			Layout.fillHeight: true
		}
	}

	// reset UI whenever opened
	Connections {
		target: LauncherState
		function onOpenChanged() {
			if (LauncherState.open) {
				LauncherState.selectedIndex = 0
				resultsList.resetScroll()
				Qt.callLater(() => searchField.clearAndFocus())
			}
		}
	}

	Component.onCompleted: {
		if (LauncherState.open)
			searchField.clearAndFocus()
	}
}
