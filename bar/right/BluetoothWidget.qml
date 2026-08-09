import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import "../../theme"

RowLayout {
	readonly property var adapter: Bluetooth.defaultAdapter

	Text {
		color: Theme.text
		font.pixelSize: Theme.fontSize(16)
		text: {
			const a = adapter
			if (!a) return "󰂲"

			if (a.state !== BluetoothAdapterState.Enabled) {
				return "󰂲"
			}

			for (let i = 0; i < a.devices.values.length; i++) {
				if (a.devices.values[i].connected) {
					return "󰂱"
				}
			}
			return "󰂯"
		}
	}
}
