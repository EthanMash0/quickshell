import QtQuick
import QtQuick.Layouts

import "../../theme"

// labelled slider that pulls its value back in when something else changes it,
// for example the reset button on the appearance page
SettingRow {
	id: root

	property real value: 0
	property real from: 0
	property real to: 1
	property real stepSize: 0

	signal moved(real value)

	LevelSlider {
		id: slider

		Layout.preferredWidth: 220
		from: root.from
		to: root.to
		stepSize: root.stepSize
		value: root.value

		onMoved: root.moved(value)

		Connections {
			target: root
			function onValueChanged() {
				if (!slider.pressed && Math.abs(slider.value - root.value) > 0.0001) {
					slider.value = root.value
				}
			}
		}
	}
}
