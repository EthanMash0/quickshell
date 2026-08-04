import QtQuick
import QtQuick.Layouts

Rectangle {
	id: root
	width: 480
	height: 560
	radius: 8
	color: "#181818"
	border.color: "#ebdbb2"
	border.width: 1

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

			onFocusListRequested: resultsList.forceActiveFocus()
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

			onFocusSearchRequested: searchField.forceActiveFocus()
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
