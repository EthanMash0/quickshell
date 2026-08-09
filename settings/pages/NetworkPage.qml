import QtQuick
import QtQuick.Layouts
import Quickshell.Networking

import "../../theme"
import "../components"

SettingsPage {
	id: root

	title: "Network"
	description: "Wi-Fi and wired connections, managed through NetworkManager."

	//-----------
	// device data
	//-----------
	readonly property var devices: Networking.devices.values

	readonly property var wifiDevices: root.devices.filter(d => d.type === DeviceType.Wifi)
	readonly property var wiredDevices: root.devices.filter(d => d.type === DeviceType.Wired)

	//----------------
	// page local state
	//----------------
	// the network currently showing a password prompt, if any
	property var pendingNetwork: null
	property string errorText: ""

	//------------------------
	// visible network list
	//------------------------
	readonly property var networks: {
		const seen = ({})
		const result = []

		for (let i = 0; i < root.wifiDevices.length; i++) {
			const found = root.wifiDevices[i].networks.values

			for (let j = 0; j < found.length; j++) {
				const network = found[j]
				const name = network.name || ""
				if (!name.length) continue

				// several access points can share an ssid, keep the strongest
				const existing = seen[name]
				if (existing) {
					if (network.signalStrength > existing.signalStrength) {
						result[result.indexOf(existing)] = network
						seen[name] = network
					}
					continue
				}

				seen[name] = network
				result.push(network)
			}
		}

		// connected first, then saved networks, then by signal
		return result.sort((a, b) => {
			if (a.connected !== b.connected) return a.connected ? -1 : 1
			if (a.known !== b.known) return a.known ? -1 : 1
			return b.signalStrength - a.signalStrength
		})
	}

	//----------
	// scanning
	//----------
	// the window unloads this page when it closes, so the scan only runs while
	// the user is actually looking at the list
	function setScanning(on) {
		for (let i = 0; i < root.wifiDevices.length; i++) {
			root.wifiDevices[i].scannerEnabled = on
		}
	}

	Component.onCompleted: root.setScanning(true)
	Component.onDestruction: root.setScanning(false)

	// adapters can appear after the page has loaded
	onWifiDevicesChanged: root.setScanning(true)

	//---------
	// helpers
	//---------
	function signalGlyph(strength) {
		if (strength < 0.25) return "󰤟"
		if (strength < 0.50) return "󰤢"
		if (strength < 0.75) return "󰤥"
		return "󰤨"
	}

	function securityLabel(security) {
		switch (security) {
			case WifiSecurityType.Open: return "Open"
			case WifiSecurityType.Owe: return "Open, encrypted"
			case WifiSecurityType.StaticWep:
			case WifiSecurityType.DynamicWep: return "WEP"
			case WifiSecurityType.WpaPsk: return "WPA"
			case WifiSecurityType.Wpa2Psk: return "WPA2"
			case WifiSecurityType.Sae: return "WPA3"
			case WifiSecurityType.WpaEap:
			case WifiSecurityType.Wpa2Eap:
			case WifiSecurityType.Wpa3SuiteB192: return "Enterprise"
		}
		return "Secured"
	}

	function isOpen(security) {
		return security === WifiSecurityType.Open
				|| security === WifiSecurityType.Owe
	}

	// only pre-shared key networks can be joined from here, there is no api for
	// the identity and certificate fields enterprise networks ask for
	function isEnterprise(security) {
		return security === WifiSecurityType.WpaEap
				|| security === WifiSecurityType.Wpa2Eap
				|| security === WifiSecurityType.Wpa3SuiteB192
	}

	function networkSubtitle(network) {
		const parts = []

		switch (network.state) {
			case ConnectionState.Connected: parts.push("Connected"); break
			case ConnectionState.Connecting: parts.push("Connecting"); break
			case ConnectionState.Disconnecting: parts.push("Disconnecting"); break
			default: if (network.known) parts.push("Saved")
		}

		parts.push(root.securityLabel(network.security))
		parts.push(`${Math.round(network.signalStrength * 100)}%`)

		return parts.join("   ·   ")
	}

	function wiredSubtitle(device) {
		const parts = []

		if (device.connected) {
			parts.push("Connected")
		} else {
			parts.push(device.hasLink ? "Cable plugged in" : "No cable")
		}

		if (device.address) parts.push(device.address)
		if (device.linkSpeed > 0) parts.push(`${device.linkSpeed} Mb/s`)

		return parts.join("   ·   ")
	}

	function failureText(network, reason) {
		switch (reason) {
			case ConnectionFailReason.NoSecrets:
				return `${network.name} did not accept that password.`
			case ConnectionFailReason.WifiAuthTimeout:
				return `${network.name} timed out while authenticating.`
			case ConnectionFailReason.WifiNetworkLost:
				return `${network.name} went out of range.`
			case ConnectionFailReason.WifiClientDisconnected:
				return `${network.name} disconnected.`
		}
		return `Could not connect to ${network.name}.`
	}

	//----------
	// actions
	//----------
	function joinNetwork(network) {
		root.errorText = ""

		if (root.isEnterprise(network.security)) {
			root.errorText = `${network.name} is an enterprise network. Set it up once with nmcli and it will appear here as saved.`
			return
		}

		// saved networks already have their secret stored and open ones need none
		if (network.known || root.isOpen(network.security)) {
			network.connect()
			return
		}

		root.pendingNetwork = network
	}

	function submitPassword(network, password) {
		if (!password.length) return

		root.errorText = ""
		root.pendingNetwork = null
		network.connectWithPsk(password)
	}

	//-----------
	// wifi card
	//-----------
	Card {
		title: "WI-FI"

		trailing: Toggle {
			checked: Networking.wifiEnabled
			enabled: Networking.wifiHardwareEnabled
			onToggled: value => Networking.wifiEnabled = value
		}

		InfoText {
			visible: root.wifiDevices.length === 0
			text: "No Wi-Fi adapter found."
		}

		InfoText {
			visible: !Networking.wifiHardwareEnabled
			text: "Wi-Fi is blocked by a hardware switch."
		}

		SettingRow {
			visible: Networking.wifiEnabled && root.wifiDevices.length > 0
			label: "Available networks"
			description: root.networks.length > 0
					? `${root.networks.length} in range`
					: "Scanning…"

			ActionButton {
				label: "Rescan"
				onClicked: {
					// toggling the scanner asks networkmanager for a fresh sweep
					root.setScanning(false)
					root.setScanning(true)
				}
			}
		}

		InfoText {
			visible: root.errorText.length > 0
			text: root.errorText
			color: Theme.text
		}

		Repeater {
			model: Networking.wifiEnabled
					? root.networks
					: []

			ColumnLayout {
				required property var modelData

				Layout.fillWidth: true
				spacing: 6

				ListRow {
					glyph: root.signalGlyph(modelData.signalStrength)
					title: modelData.name
					subtitle: root.networkSubtitle(modelData)
					highlighted: modelData.connected

					onClicked: {
						if (!modelData.connected) {
							root.joinNetwork(modelData)
						}
					}

					ActionButton {
						visible: !modelData.connected
						primary: true
						label: "Connect"
						enabled: !modelData.stateChanging
						onClicked: root.joinNetwork(modelData)
					}

					ActionButton {
						visible: modelData.connected
						label: "Disconnect"
						onClicked: modelData.disconnect()
					}

					ActionButton {
						visible: modelData.known
						label: "Forget"
						destructive: true
						onClicked: modelData.forget()
					}
				}

				//-----------------
				// password prompt
				//-----------------
				RowLayout {
					Layout.fillWidth: true
					Layout.leftMargin: 40
					Layout.bottomMargin: 4
					spacing: 6
					visible: root.pendingNetwork === modelData

					onVisibleChanged: if (visible) passwordField.forceActiveFocus()

					InputField {
						id: passwordField
						Layout.fillWidth: true
						echoMode: TextInput.Password
						placeholderText: `Password for ${modelData.name}`
						onAccepted: root.submitPassword(modelData, text)
					}

					ActionButton {
						primary: true
						label: "Join"
						onClicked: root.submitPassword(modelData, passwordField.text)
					}

					ActionButton {
						label: "Cancel"
						onClicked: root.pendingNetwork = null
					}
				}

				// surfaces the reason a connection attempt was rejected
				Connections {
					target: modelData
					function onConnectionFailed(reason) {
						root.errorText = root.failureText(modelData, reason)
					}
				}
			}
		}
	}

	//------------
	// wired card
	//------------
	Card {
		visible: root.wiredDevices.length > 0
		title: "WIRED"

		Repeater {
			model: root.wiredDevices

			ListRow {
				required property var modelData

				glyph: "󰌗"
				title: modelData.name
				subtitle: root.wiredSubtitle(modelData)
				highlighted: modelData.connected
				interactive: false

				ActionButton {
					visible: !modelData.connected && !!modelData.network
					primary: true
					label: "Connect"
					onClicked: modelData.network.connect()
				}

				ActionButton {
					visible: modelData.connected
					label: "Disconnect"
					onClicked: modelData.disconnect()
				}
			}
		}

		SettingRow {
			visible: root.wiredDevices.length === 1
			label: "Connect automatically"
			description: "Bring this interface up on its own when a cable is plugged in."

			Toggle {
				checked: root.wiredDevices.length === 1 && root.wiredDevices[0].autoconnect
				onToggled: value => root.wiredDevices[0].autoconnect = value
			}
		}
	}
}
