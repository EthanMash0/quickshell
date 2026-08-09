import QtQuick
import QtQuick.Controls

// themed replacement for the default Controls slider styling. bind `value` to
// the backend and act on `moved`, which only fires for user drags.
// lives beside the theme singleton because the bar uses it too, not just the
// settings window
Slider {
	id: root

	implicitHeight: 20

	background: Rectangle {
		x: root.leftPadding
		y: root.topPadding + root.availableHeight / 2 - height / 2
		width: root.availableWidth
		height: 4
		radius: 2
		color: Theme.alpha(Theme.text, 0.15)

		// filled portion up to the handle
		Rectangle {
			width: root.visualPosition * parent.width
			height: parent.height
			radius: parent.radius
			color: Theme.highlight
		}
	}

	handle: Rectangle {
		x: root.leftPadding + root.visualPosition * (root.availableWidth - width)
		y: root.topPadding + root.availableHeight / 2 - height / 2
		implicitWidth: 14
		implicitHeight: 14
		radius: width / 2
		color: Theme.highlight
		border.width: 2
		border.color: Theme.surface
	}
}
