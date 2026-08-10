import QtQuick
import QtQuick.Layouts
import Quickshell
import Quickshell.Widgets

RowLayout {
	id: root
	spacing: 2

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
