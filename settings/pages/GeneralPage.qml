import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../../prefs"
import "../components"

SettingsPage {
	id: root

	title: "General"
	description: "Clock formatting and the applications the bar opens. Saved to prefs.json."

	// a live sample so the format is judged by its result rather than its tokens
	readonly property string clockPreview: Qt.formatDateTime(new Date(), Prefs.clockFormat)

	readonly property bool customFormat: Prefs.clockCustomFormat.trim().length > 0

	//------------
	// clock card
	//------------
	Card {
		title: "CLOCK"

		SettingRow {
			label: "Preview"
			description: "How the bar clock reads right now."

			Text {
				text: root.clockPreview
				color: Theme.highlight
				font.family: Theme.labelFont
				font.pixelSize: Theme.fontSize(14)
				font.bold: true
			}
		}

		SettingRow {
			label: "24 hour time"
			// the toggles below do nothing while a custom format is set, so say so
			// rather than letting them look broken
			description: root.customFormat
					? "Overridden by the custom format below."
					: "Show 17:30 instead of 05:30 PM."

			Toggle {
				checked: Prefs.clockUse24Hour
				enabled: !root.customFormat
				onToggled: value => Prefs.clockUse24Hour = value
			}
		}

		SettingRow {
			label: "Show date"
			description: root.customFormat
					? "Overridden by the custom format below."
					: "Prefix the time with the weekday and date."

			Toggle {
				checked: Prefs.clockShowDate
				enabled: !root.customFormat
				onToggled: value => Prefs.clockShowDate = value
			}
		}

		SettingRow {
			label: "Show seconds"
			description: root.customFormat
					? "Overridden by the custom format below."
					: "Ticks every second instead of every minute."

			Toggle {
				checked: Prefs.clockShowSeconds
				enabled: !root.customFormat
				onToggled: value => Prefs.clockShowSeconds = value
			}
		}

		SettingRow {
			label: "Custom format"
			description: "Qt date tokens, for example \"ddd d MMM  HH:mm\". Leave empty to use the toggles above."

			InputField {
				id: formatField

				Layout.preferredWidth: 200
				text: Prefs.clockCustomFormat
				placeholderText: "Automatic"

				onTextEdited: Prefs.clockCustomFormat = text

				// typing breaks the binding above, so re-sync after a reset
				Connections {
					target: Prefs
					function onClockCustomFormatChanged() {
						if (formatField.text !== Prefs.clockCustomFormat) {
							formatField.text = Prefs.clockCustomFormat
						}
					}
				}
			}
		}
	}

	//-------------------
	// default apps card
	//-------------------
	Card {
		title: "DEFAULT APPS"

		SettingRow {
			label: "Calendar"
			description: "Opened when the clock is clicked."

			InputField {
				id: calendarField

				Layout.preferredWidth: 220
				text: Prefs.calendarCommand
				placeholderText: "gnome-calendar"

				onTextEdited: Prefs.calendarCommand = text

				Connections {
					target: Prefs
					function onCalendarCommandChanged() {
						if (calendarField.text !== Prefs.calendarCommand) {
							calendarField.text = Prefs.calendarCommand
						}
					}
				}
			}

			ActionButton {
				label: "Test"
				enabled: Prefs.calendarCommand.trim().length > 0
				onClicked: Prefs.run(Prefs.calendarCommand)
			}
		}

		SettingRow {
			label: "System monitor"
			description: "Opened when the CPU, GPU and RAM readout is clicked."

			InputField {
				id: monitorField

				Layout.preferredWidth: 220
				text: Prefs.systemMonitorCommand
				placeholderText: "alacritty -e btop"

				onTextEdited: Prefs.systemMonitorCommand = text

				Connections {
					target: Prefs
					function onSystemMonitorCommandChanged() {
						if (monitorField.text !== Prefs.systemMonitorCommand) {
							monitorField.text = Prefs.systemMonitorCommand
						}
					}
				}
			}

			ActionButton {
				label: "Test"
				enabled: Prefs.systemMonitorCommand.trim().length > 0
				onClicked: Prefs.run(Prefs.systemMonitorCommand)
			}
		}

		InfoText {
			text: "Commands run through a shell, so flags, pipes and quoting all work."
		}
	}

	//------------
	// reset card
	//------------
	Card {
		title: "PREFERENCES FILE"

		SettingRow {
			label: "Reset to defaults"
			description: "Restores the clock, default apps and media preferences. Appearance is reset separately."

			ActionButton {
				label: "Reset"
				onClicked: Prefs.resetToDefaults()
			}
		}

		InfoText {
			text: "Stored in ~/.config/quickshell/prefs.json, which you can also edit by hand."
		}
	}
}
