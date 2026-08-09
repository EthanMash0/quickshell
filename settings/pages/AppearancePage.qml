import QtQuick
import QtQuick.Layouts

import "../../theme"
import "../components"

SettingsPage {
	id: root

	title: "Appearance"
	description: "Colours and metrics for the bar, the launcher and this window. Changes apply straight away and are saved to theme.json."

	// qt silently substitutes a missing family, so warn instead of failing
	readonly property bool fontInstalled: Theme.fontFamily.length === 0
			|| Qt.fontFamilies().indexOf(Theme.fontFamily) !== -1

	//--------------
	// colour card
	//--------------
	Card {
		title: "COLOURS"

		HexField {
			label: "Text"
			value: Theme.foreground
			onEdited: value => Theme.foreground = value
		}

		HexField {
			label: "Background"
			value: Theme.background
			onEdited: value => Theme.background = value
		}

		HexField {
			label: "Accent"
			value: Theme.accent
			onEdited: value => Theme.accent = value
		}

		InfoText {
			text: "Hover and selection shades are derived from these, so they stay in step automatically."
		}
	}

	//--------------
	// preview card
	//--------------
	Card {
		title: "PREVIEW"

		// a miniature of the bar sitting above a launcher row
		Rectangle {
			Layout.fillWidth: true
			implicitHeight: 112
			radius: Theme.radius
			color: Theme.alpha(Theme.text, 0.06)
			clip: true

			ColumnLayout {
				anchors.fill: parent
				anchors.margins: 10
				spacing: 10

				// bar strip
				Rectangle {
					Layout.fillWidth: true
					implicitHeight: Math.max(24, Theme.barHeight * 0.6)
					radius: Theme.radiusSmall
					color: Theme.barBackground

					RowLayout {
						anchors.fill: parent
						anchors.leftMargin: 8
						anchors.rightMargin: 8
						spacing: 8

						Rectangle {
							implicitWidth: 18
							implicitHeight: 18
							radius: Theme.radiusSmall
							color: Theme.highlight

							Text {
								anchors.centerIn: parent
								text: "1"
								color: Theme.onHighlight
								font.family: Theme.labelFont
								font.pixelSize: Theme.fontSize(12)
							}
						}

						Item {
							Layout.fillWidth: true
						}

						Text {
							text: "12:34"
							color: Theme.text
							font.family: Theme.labelFont
							font.pixelSize: Theme.fontSize(13)
						}
					}
				}

				// launcher rows, the second one selected
				Rectangle {
					Layout.fillWidth: true
					Layout.fillHeight: true
					radius: Theme.radiusSmall
					color: Theme.surface
					border.width: Theme.borderWidth
					border.color: Theme.border

					ColumnLayout {
						anchors.fill: parent
						anchors.margins: 6
						spacing: 2

						Text {
							Layout.fillWidth: true
							leftPadding: 6
							text: "Files"
							color: Theme.text
							font.family: Theme.labelFont
							font.pixelSize: Theme.fontSize(12)
						}

						Rectangle {
							Layout.fillWidth: true
							implicitHeight: 22
							radius: Theme.radiusSmall
							color: Theme.selection

							Text {
								anchors.verticalCenter: parent.verticalCenter
								leftPadding: 6
								text: "Terminal"
								color: Theme.text
								font.family: Theme.labelFont
								font.pixelSize: Theme.fontSize(12)
							}
						}
					}
				}
			}
		}
	}

	//-----------
	// bar card
	//-----------
	Card {
		title: "BAR"

		SliderRow {
			label: "Background opacity"
			description: `${Math.round(Theme.barOpacity * 100)}% over the wallpaper`
			from: 0
			to: 1
			value: Theme.barOpacity
			onMoved: value => Theme.barOpacity = value
		}

		SliderRow {
			label: "Height"
			description: `${Theme.barHeight} px`
			from: 24
			to: 64
			stepSize: 1
			value: Theme.barHeight
			onMoved: value => Theme.barHeight = Math.round(value)
		}
	}

	//------------
	// shape card
	//------------
	Card {
		title: "SHAPE"

		SliderRow {
			label: "Corner radius"
			description: `${Theme.cornerRadius} px on popups, cards and the launcher`
			from: 0
			to: 20
			stepSize: 1
			value: Theme.cornerRadius
			onMoved: value => Theme.cornerRadius = Math.round(value)
		}

		SliderRow {
			label: "Border width"
			description: Theme.borderWidth === 0
					? "Borderless"
					: `${Theme.borderWidth} px outline on popups, cards and the launcher`
			from: 0
			to: 4
			stepSize: 1
			value: Theme.borderWidth
			onMoved: value => Theme.borderWidth = Math.round(value)
		}

		InfoText {
			text: "Buttons, toggles and text fields keep their outlines regardless, so they stay visible at zero."
		}
	}

	//---------------
	// launcher card
	//---------------
	Card {
		title: "LAUNCHER"

		SliderRow {
			label: "Width"
			description: `${Theme.launcherWidth} px`
			from: 320
			to: 900
			stepSize: 1
			value: Theme.launcherWidth
			onMoved: value => Theme.launcherWidth = Math.round(value)
		}

		SliderRow {
			label: "Height"
			description: `${Theme.launcherHeight} px`
			from: 320
			to: 1000
			stepSize: 1
			value: Theme.launcherHeight
			onMoved: value => Theme.launcherHeight = Math.round(value)
		}
	}

	//-----------
	// font card
	//-----------
	Card {
		title: "FONT"

		SettingRow {
			label: "Label font"
			description: "Used for text labels. Icon glyphs stay on the default font so a font without nerd font coverage cannot break the bar."

			InputField {
				id: fontField

				Layout.preferredWidth: 200
				text: Theme.fontFamily
				placeholderText: "System default"

				onTextEdited: Theme.fontFamily = text.trim()

				// typing breaks the binding above, so re-sync after a reset
				Connections {
					target: Theme
					function onFontFamilyChanged() {
						if (fontField.text !== Theme.fontFamily) {
							fontField.text = Theme.fontFamily
						}
					}
				}
			}
		}

		InfoText {
			visible: !root.fontInstalled
			text: `"${Theme.fontFamily}" is not installed, so Qt will substitute something close to it.`
		}

		SliderRow {
			label: "Text size"
			description: `${Math.round(Theme.fontScale * 100)}% of the default size`
			from: 0.8
			to: 1.5
			stepSize: 0.05
			value: Theme.fontScale
			onMoved: value => Theme.fontScale = Math.round(value * 20) / 20
		}

		InfoText {
			text: "Scales every label in the bar, the launcher and this window. The range is capped so this window stays readable enough to change back."
		}
	}

	//------------
	// reset card
	//------------
	Card {
		title: "THEME FILE"

		SettingRow {
			label: "Reset to defaults"
			description: "Puts the original gruvbox colours and metrics back."

			ActionButton {
				label: "Reset"
				onClicked: Theme.resetToDefaults()
			}
		}

		InfoText {
			text: "Everything here is stored in ~/.config/quickshell/theme.json, which you can also edit by hand."
		}
	}
}
