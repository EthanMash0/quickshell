import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

RowLayout {
	id: root

	readonly property var devices: Networking.devices.values

	readonly property var wiredDevice: {
		const ds = root.devices
		for (let i = 0; i < ds.length; i++) {
			if (ds[i].type === DeviceType.Wired && ds[i].connected) {
				return ds[i]
			}
		}
		return null
	}
	readonly property var wifiNetwork: {
		const ds = root.devices
		for (let i = 0; i < ds.length; i++) {
			const d = ds[i]
			if (d.type !== DeviceType.Wifi) {
				continue
			}
			const nets = d.networks.values
			for (let j = 0; j < nets.length; j++) {
				if (nets[j].connected) {
					return nets[j]
				}
			}
		}
		return null
	}

	readonly property real signal: wifiNetwork
																? wifiNetwork.signalStrength
																: 0

	Text {
		color: "#ebdbb2"
		font.pixelSize: 16
		anchors.centerIn: parent
		text: {
			// prefer ethernet when it is in use
			if (root.wiredDevice) {
				return "󰌗"
			}
			if (!Networking.wifiEnabled || !Networking.wifiHardwareEnabled) {
				return "󰤮"
			}
			if (!root.wifiNetwork) {
				return "󰤯"
			}

			const s = root.signal
			if (s < 0.25) {
				return "󰤟"
			}
			if (s < 0.50) {
				return "󰤢"
			}
			if (s < 0.75) {
				return "󰤥"
			}
			return "󰤨"
		}
	}
}
