import QtQuick
import QtQuick.Layouts

import "../../theme"

// labelled colour entry with a live swatch
RowLayout {
	id: root

	property string label: ""
	property string value: "#000000"

	// only fires for values that parse as a colour, so half typed input is ignored
	signal edited(string value)

	Layout.fillWidth: true
	spacing: 10

	Text {
		Layout.preferredWidth: 120
		text: root.label
		color: Theme.text
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(13)
	}

	Rectangle {
		implicitWidth: 22
		implicitHeight: 22
		radius: Theme.radiusSmall
		color: root.value
		border.width: 1
		border.color: Theme.borderSoft
	}

	InputField {
		id: field

		Layout.preferredWidth: 130
		text: root.value

		onTextEdited: {
			if (Theme.isValidColor(text)) {
				root.edited(text.trim())
			}
		}

		// typing breaks the binding above, so re-sync when the value changes
		// from elsewhere such as the reset button
		Connections {
			target: root
			function onValueChanged() {
				if (field.text !== root.value) {
					field.text = root.value
				}
			}
		}
	}

	Text {
		Layout.fillWidth: true
		visible: !Theme.isValidColor(field.text)
		text: "expects #rrggbb or #aarrggbb"
		color: Theme.textFaint
		font.family: Theme.labelFont
		font.pixelSize: Theme.fontSize(11)
	}
}
