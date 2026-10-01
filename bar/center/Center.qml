import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

import "../../prefs"

RowLayout {
	id: root
	spacing: 2
	visible: Prefs.barShowCenter && Prefs.barShowApps

	WrapperRectangle {
		id: center
		color: "#bb181818"
		rightMargin: 12
		leftMargin: 12
		implicitHeight: 40
		radius: center.implicitHeight / 2
		AppsWidget {}
	}
}
