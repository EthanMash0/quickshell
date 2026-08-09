import QtQuick
import QtQuick.Layouts
import Quickshell.Bluetooth

import "../../theme"
import "../../bluetooth"
import "../components"

SettingsPage {
	id: root

	title: "Bluetooth"
	description: "Pair and connect devices on the default adapter."

	//---------------
	// pairing agent
	//---------------
	// the agent only needs to exist while someone might pair something, so it
	// follows the page rather than running for the whole session
	Component.onCompleted: BluetoothAgent.enabled = true
	Component.onDestruction: BluetoothAgent.enabled = false

	// bluez asks the agent, not us, so the device has to be remembered here for
	// the prompt to be able to name it
	property var pairingDevice: null

	function beginPair(device) {
		root.pairingDevice = device
		BluetoothAgent.pairingWith = root.nameOf(device)
		BluetoothAgent.statusText = ""
		device.pair()
	}

	Connections {
		target: root.pairingDevice

		function onPairedChanged() {
			const device = root.pairingDevice
			if (!device || !device.paired) return

			// bluez will not reconnect a device on its own unless it is trusted,
			// which is the step people usually miss when pairing by hand
			device.trusted = true
			device.connect()

			root.pairingDevice = null
		}
	}

	//-------------
	// adapter data
	//-------------
	readonly property var adapter: Bluetooth.defaultAdapter
	readonly property bool powered: !!root.adapter && root.adapter.state === BluetoothAdapterState.Enabled

	readonly property var devices: root.adapter
			? root.adapter.devices.values
			: []

	// bluez keeps remembering devices after they disconnect, so split the list
	// into ones we already know and ones the scan just turned up
	readonly property var knownDevices: root.sortDevices(root.devices.filter(d => d.paired || d.bonded))
	readonly property var nearbyDevices: root.sortDevices(root.devices.filter(d => !d.paired && !d.bonded))

	//---------
	// helpers
	//---------
	// connected devices float to the top, everything else sorts by name
	function sortDevices(list) {
		return list.slice().sort((a, b) => {
			if (a.connected !== b.connected) {
				return a.connected ? -1 : 1
			}
			return root.nameOf(a).toLowerCase().localeCompare(root.nameOf(b).toLowerCase())
		})
	}

	function nameOf(device) {
		return device.name || device.deviceName || device.address
	}

	// bluez reports a freedesktop icon name, map the common ones to a glyph
	function glyphOf(device) {
		const icon = (device.icon || "").toLowerCase()

		if (icon.includes("headset") || icon.includes("headphone")) return "󰋋"
		if (icon.includes("speaker") || icon.includes("audio")) return "󰓃"
		if (icon.includes("phone")) return "󰄞"
		if (icon.includes("mouse")) return "󰦋"
		if (icon.includes("keyboard")) return "󰌌"
		if (icon.includes("watch")) return "󰖉"
		if (icon.includes("computer")) return "󰟀"
		if (icon.includes("gaming") || icon.includes("joypad")) return "󰊴"
		if (icon.includes("printer")) return "󰐪"
		if (icon.includes("camera")) return "󰄀"

		return "󰂯"
	}

	function statusOf(device) {
		if (device.pairing) return "Pairing"

		switch (device.state) {
			case BluetoothDeviceState.Connected: return "Connected"
			case BluetoothDeviceState.Connecting: return "Connecting"
			case BluetoothDeviceState.Disconnecting: return "Disconnecting"
		}

		return device.paired || device.bonded
				? "Paired"
				: "Not paired"
	}

	function subtitleOf(device) {
		const parts = [root.statusOf(device)]

		if (device.batteryAvailable) {
			parts.push(`${Math.round(device.battery * 100)}% battery`)
		}
		parts.push(device.address)

		return parts.join("   ·   ")
	}

	//----------------------
	// pairing request card
	//----------------------
	Card {
		visible: BluetoothAgent.hasRequest
		title: "PAIRING REQUEST"

		SettingRow {
			label: BluetoothAgent.pairingWith.length > 0
					? BluetoothAgent.pairingWith
					: "A device wants to pair"
			description: {
				switch (BluetoothAgent.requestKind) {
					case "confirm":
						return BluetoothAgent.requestPasskey.length > 0
								? `Check that the device shows ${BluetoothAgent.requestPasskey}, then confirm.`
								: "Confirm that you want to pair with this device."
					case "authorize":
						return "The device is asking to use a service."
					case "pin":
						return "Enter the PIN shown on the device. Older devices often use 0000."
					case "passkey":
						return "Enter the passkey shown on the device."
					case "display":
						return `Type ${BluetoothAgent.requestPasskey} on the device, then press enter there.`
				}
				return ""
			}
		}

		// typed responses: a pin or a passkey the device is showing
		RowLayout {
			Layout.fillWidth: true
			visible: BluetoothAgent.needsInput
			spacing: 8

			InputField {
				id: secretField

				Layout.preferredWidth: 160
				placeholderText: BluetoothAgent.requestKind === "pin"
						? "PIN"
						: "Passkey"
				onAccepted: {
					BluetoothAgent.submit(text)
					text = ""
				}
			}

			ActionButton {
				label: "Send"
				primary: true
				enabled: secretField.text.length > 0
				onClicked: {
					BluetoothAgent.submit(secretField.text)
					secretField.text = ""
				}
			}
		}

		// yes/no responses
		RowLayout {
			Layout.fillWidth: true
			visible: BluetoothAgent.requestKind === "confirm"
					|| BluetoothAgent.requestKind === "authorize"
			spacing: 8

			ActionButton {
				label: "Confirm"
				primary: true
				onClicked: BluetoothAgent.accept()
			}

			ActionButton {
				label: "Reject"
				destructive: true
				onClicked: BluetoothAgent.deny()
			}
		}

		// nothing to answer, the device is waiting on the user instead
		ActionButton {
			visible: BluetoothAgent.requestKind === "display"
			label: "Dismiss"
			onClicked: BluetoothAgent.dismiss()
		}
	}

	//--------------
	// adapter card
	//--------------
	Card {
		title: "ADAPTER"

		trailing: Toggle {
			checked: root.powered
			enabled: !!root.adapter
			onToggled: value => root.adapter.enabled = value
		}

		InfoText {
			visible: !root.adapter
			text: "No bluetooth adapter found."
		}

		SettingRow {
			visible: !!root.adapter
			label: root.adapter
					? (root.adapter.name || root.adapter.adapterId)
					: ""
			description: root.powered
					? "Powered on"
					: "Powered off"
		}

		SettingRow {
			visible: root.powered
			label: "Scan for devices"
			description: "Keeps looking for nearby devices while enabled."

			Toggle {
				checked: !!root.adapter && root.adapter.discovering
				onToggled: value => root.adapter.discovering = value
			}
		}

		SettingRow {
			visible: root.powered
			label: "Discoverable"
			description: "Lets other devices find this machine."

			Toggle {
				checked: !!root.adapter && root.adapter.discoverable
				onToggled: value => root.adapter.discoverable = value
			}
		}
	}

	//------------------
	// known devices
	//------------------
	Card {
		visible: root.powered
		title: "MY DEVICES"

		InfoText {
			visible: root.knownDevices.length === 0
			text: "No paired devices yet."
		}

		Repeater {
			model: root.knownDevices

			ListRow {
				required property var modelData

				glyph: root.glyphOf(modelData)
				title: root.nameOf(modelData)
				subtitle: root.subtitleOf(modelData)
				highlighted: modelData.connected

				// the whole row toggles the connection, the buttons are shortcuts
				onClicked: {
					if (modelData.connected) {
						modelData.disconnect()
					} else {
						modelData.connect()
					}
				}

				ActionButton {
					primary: !modelData.connected
					label: modelData.connected
							? "Disconnect"
							: "Connect"
					enabled: modelData.state !== BluetoothDeviceState.Connecting
							&& modelData.state !== BluetoothDeviceState.Disconnecting
					onClicked: {
						if (modelData.connected) {
							modelData.disconnect()
						} else {
							modelData.connect()
						}
					}
				}

				ActionButton {
					label: "Forget"
					destructive: true
					onClicked: modelData.forget()
				}
			}
		}
	}

	//----------------
	// nearby devices
	//----------------
	Card {
		visible: root.powered
		title: "NEARBY"

		InfoText {
			visible: root.nearbyDevices.length === 0
			text: root.adapter && root.adapter.discovering
					? "Scanning…"
					: "Turn on \"Scan for devices\" to look for something new."
		}

		Repeater {
			model: root.nearbyDevices

			ListRow {
				required property var modelData

				glyph: root.glyphOf(modelData)
				title: root.nameOf(modelData)
				subtitle: root.subtitleOf(modelData)

				onClicked: if (!modelData.pairing) root.beginPair(modelData)

				ActionButton {
					primary: !modelData.pairing
					label: modelData.pairing
							? "Cancel"
							: "Pair"
					onClicked: {
						if (modelData.pairing) {
							modelData.cancelPair()
						} else {
							root.beginPair(modelData)
						}
					}
				}
			}
		}

		InfoText {
			visible: BluetoothAgent.statusText.length > 0
			text: BluetoothAgent.statusText
		}

		InfoText {
			visible: root.nearbyDevices.length > 0 && !BluetoothAgent.running
			text: "The pairing agent is not running, so devices that ask for a PIN or a passkey will fail. Check that `bluetoothctl` is installed."
		}
	}
}
