pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

// quickshell's bluetooth binding exposes pair()/cancelPair() but no bluez
// pairing agent, so any device that wants a passkey or a PIN just fails.
// this drives `bluetoothctl`, which registers an agent of its own on startup,
// and turns its prompts into something the settings page can render.
Singleton {
	id: root

	//-------------------
	// public properties
	//-------------------
	// the page turns this on while it is visible, so we are not holding a
	// bluetoothctl process open for the whole session
	property bool enabled: false

	// set by the page before it calls pair(), purely so the prompt can name the
	// device. bluetoothctl labels its prompts "[agent]" rather than by device
	property string pairingWith: ""

	// "" | "confirm" | "authorize" | "pin" | "passkey" | "display"
	property string requestKind: ""
	property string requestPasskey: ""
	property string statusText: ""

	readonly property bool running: agentProc.running

	// a prompt needing a button press or a typed value
	readonly property bool hasRequest: root.requestKind.length > 0

	// "display" is informational: the passkey has to be typed on the device
	readonly property bool needsInput: root.requestKind === "pin"
			|| root.requestKind === "passkey"

	//----------
	// controls
	//----------
	function accept() {
		root.send("yes")
	}

	function deny() {
		root.send("no")
	}

	function submit(value) {
		root.send(value)
	}

	function dismiss() {
		root.clearRequest()
	}

	function send(value) {
		if (agentProc.running) {
			agentProc.write(`${value}\n`)
		}
		root.clearRequest()
	}

	function clearRequest() {
		root.requestKind = ""
		root.requestPasskey = ""
	}

	//---------
	// parsing
	//---------
	// the last prompt we reacted to, so a redrawn prompt is not treated as new
	property string lastPrompt: ""

	// bluetoothctl writes colour codes and redraws its prompt with carriage
	// returns, none of which survives a naive line split
	function clean(raw) {
		return raw
				.replace(/\x1B\[[0-9;?]*[A-Za-z]/g, "")
				.replace(/\r/g, "\n")
	}

	function parse(raw) {
		// the buffer only grows, and only the newest prompt matters
		const text = root.clean(raw).slice(-4000)

		if (/Pairing successful/.test(text)) {
			root.statusText = "Pairing successful."
			root.clearRequest()
		} else if (/Failed to pair|AuthenticationFailed|AuthenticationCanceled/.test(text)) {
			root.statusText = "Pairing failed."
			root.clearRequest()
		}

		// walk every prompt in the tail and keep the last, since several can
		// land in a single chunk
		const patterns = [
			{ kind: "confirm", re: /Confirm passkey (\d+)/g },
			{ kind: "confirm", re: /(Confirm pairing)/g },
			{ kind: "authorize", re: /(Authorize service)/g },
			{ kind: "pin", re: /(Enter PIN code)/g },
			{ kind: "passkey", re: /(Enter passkey)/g },
			{ kind: "display", re: /Passkey: (\d+)/g }
		]

		let best = null

		for (let i = 0; i < patterns.length; i++) {
			const p = patterns[i]
			let m

			while ((m = p.re.exec(text)) !== null) {
				if (!best || m.index > best.index) {
					best = { kind: p.kind, index: m.index, whole: m[0], value: m[1] }
				}
			}
		}

		if (!best) return
		if (best.whole === root.lastPrompt) return

		root.lastPrompt = best.whole
		root.requestKind = best.kind
		root.requestPasskey = /^\d+$/.test(best.value || "")
				? best.value
				: ""
	}

	//---------------
	// agent process
	//---------------
	onEnabledChanged: {
		if (!root.enabled) {
			root.clearRequest()
			root.statusText = ""
			root.lastPrompt = ""
		}
	}

	Process {
		id: agentProc

		command: ["bluetoothctl"]
		running: root.enabled
		stdinEnabled: true

		// bluetoothctl registers an agent by itself on startup, this only makes
		// sure it is the one bluez actually calls
		onStarted: agentProc.write("default-agent\n")

		stdout: StdioCollector {
			// stream as it arrives, otherwise nothing surfaces until the process
			// exits and the prompts are useless
			waitForEnd: false
			onTextChanged: root.parse(text)
		}

		stderr: StdioCollector {
			waitForEnd: false
		}
	}
}
