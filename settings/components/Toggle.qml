import QtQuick

import "../../theme"

// on/off switch. it reports the requested value rather than flipping itself so
// the caller can keep it bound to the real backend state
Rectangle {
	id: root

	property bool checked: false

	signal toggled(bool value)

	implicitWidth: 40
	implicitHeight: 22
	radius: height / 2

	opacity: root.enabled
			? 1
			: 0.4

	color: root.checked
			? Theme.highlight
			: Theme.alpha(Theme.text, 0.15)
	border.width: 1
	border.color: root.checked
			? Theme.highlight
			: Theme.borderSoft

	HoverHandler {
		enabled: root.enabled
		cursorShape: Qt.PointingHandCursor
	}

	TapHandler {
		enabled: root.enabled
		onTapped: root.toggled(!root.checked)
	}

	Rectangle {
		width: root.height - 6
		height: width
		radius: width / 2
		y: 3
		x: root.checked
				? root.width - width - 3
				: 3
		color: root.checked
				? Theme.onHighlight
				: Theme.text

		Behavior on x {
			NumberAnimation {
				duration: 120
				easing.type: Easing.OutCubic
			}
		}
	}
}
