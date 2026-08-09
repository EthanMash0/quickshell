import QtQuick

import "../../theme"

// small labeled button. primary fills with the accent, otherwise it is outlined
Rectangle {
	id: root

	property string label: ""
	property bool primary: false
	property bool destructive: false

	signal clicked()

	implicitWidth: labelText.implicitWidth + 22
	implicitHeight: 28
	radius: Theme.radiusSmall

	opacity: root.enabled
			? 1
			: 0.35

	color: {
		if (root.primary) {
			return buttonHover.hovered
					? Theme.highlight
					: Theme.alpha(Theme.highlight, 0.8)
		}
		return buttonHover.hovered
				? Theme.hover
				: "transparent"
	}

	border.width: root.primary
			? 0
			: 1
	border.color: Theme.borderSoft

	HoverHandler {
		id: buttonHover
		enabled: root.enabled
		cursorShape: Qt.PointingHandCursor
	}

	TapHandler {
		enabled: root.enabled
		onTapped: root.clicked()
	}

	Text {
		id: labelText
		anchors.centerIn: parent
		text: root.label
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(12)
		color: {
			if (root.primary) return Theme.onHighlight
			return root.destructive
					? Theme.textMuted
					: Theme.text
		}
	}
}
