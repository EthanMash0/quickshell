import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

RowLayout {
	readonly property var adapter: Bluetooth.defaultAdapter

	Text {
		color: "#ebdbb2"
		font.pixelSize: 16
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
