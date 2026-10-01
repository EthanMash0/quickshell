import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../prefs"
import "../../bar/system"
import "../components"

SettingsPage {
	id: root

	title: "Bar"
	description: "Which sides and widgets are shown. The header switch hides a whole side; the rows choose what returns with it."

	//------
	// left
	//------
	Card {
		title: "LEFT"

		trailing: Toggle {
			checked: Prefs.barShowLeft
			onToggled: value => Prefs.barShowLeft = value
		}

		SettingRow {
			label: "Power"
			description: "Sleep, lock and shut down."

			Toggle {
				checked: Prefs.barShowPower
				onToggled: value => Prefs.barShowPower = value
			}
		}

		SettingRow {
			label: "Workspaces"
			description: "Switch between workspaces."

			Toggle {
				checked: Prefs.barShowWorkspaces
				onToggled: value => Prefs.barShowWorkspaces = value
			}
		}
	}

	//--------
	// center
	//--------
	Card {
		title: "CENTER"

		trailing: Toggle {
			checked: Prefs.barShowCenter
			onToggled: value => Prefs.barShowCenter = value
		}

		SettingRow {
			label: "Apps"
			description: "Pinned and running applications."

			Toggle {
				checked: Prefs.barShowApps
				onToggled: value => Prefs.barShowApps = value
			}
		}
	}

	//-------
	// right
	//-------
	Card {
		title: "RIGHT"

		trailing: Toggle {
			checked: Prefs.barShowRight
			onToggled: value => Prefs.barShowRight = value
		}

		SettingRow {
			label: "System usage"
			description: "GPU, VRAM, CPU and RAM."

			Toggle {
				checked: Prefs.barShowUsage
				onToggled: value => Prefs.barShowUsage = value
			}
		}

		SettingRow {
			label: "System tray"
			description: "Status icons from running apps."

			Toggle {
				checked: Prefs.barShowTray
				onToggled: value => Prefs.barShowTray = value
			}
		}

		SettingRow {
			label: "Control center"
			description: "Audio, Bluetooth and network."

			Toggle {
				checked: Prefs.barShowControlCenter
				onToggled: value => Prefs.barShowControlCenter = value
			}
		}

		SettingRow {
			label: "Clock"
			description: "Time and date. Click opens the calendar."

			Toggle {
				checked: Prefs.barShowClock
				onToggled: value => Prefs.barShowClock = value
			}
		}
	}

	//-----
	// gpu
	//-----
	Card {
		visible: SystemUsage.gpus.length > 1
		title: "GPU"

		SettingRow {
			label: SystemUsage.activeLabel.length > 0
					? SystemUsage.activeLabel
					: "No GPU found"
			description: SystemUsage.usingSavedGpu
					? `Selected · ${SystemUsage.activePci}`
					: "Automatic · prefers a dedicated GPU"
		}

		ListRow {
			glyph: SystemUsage.usingSavedGpu ? "" : "󰄬"
			title: "Automatic"
			subtitle: "Prefer a dedicated GPU when one is present."
			highlighted: !SystemUsage.usingSavedGpu
			onClicked: Prefs.gpuPciSlot = ""
		}

		Repeater {
			model: SystemUsage.gpus

			ListRow {
				required property var modelData

				readonly property bool selected: SystemUsage.usingSavedGpu
						&& modelData.slot === Prefs.gpuPciSlot

				glyph: selected ? "󰄬" : ""
				title: modelData.label
				subtitle: (modelData.type === "nvidia" || modelData.vramTotalPath.length > 0)
						? `${modelData.driver} · ${modelData.slot} · dedicated`
						: `${modelData.driver} · ${modelData.slot}`
				highlighted: selected
				onClicked: Prefs.gpuPciSlot = modelData.slot
			}
		}

		InfoText {
			text: "Used by the system usage widget. VRAM stays hidden when the chosen device has no dedicated memory."
		}
	}
}
