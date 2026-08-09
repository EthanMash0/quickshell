pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	//------------------------------
	// user values (from theme.json)
	//------------------------------
	// these are plain strings/numbers so the json file stays readable and
	// hand editable. the resolved colors below are what the shell binds to.
	property alias foreground: themeJson.foreground
	property alias background: themeJson.background
	property alias accent: themeJson.accent
	property alias barOpacity: themeJson.barOpacity
	property alias barHeight: themeJson.barHeight
	property alias cornerRadius: themeJson.cornerRadius
	property alias borderWidth: themeJson.borderWidth
	property alias fontFamily: themeJson.fontFamily
	property alias fontScale: themeJson.fontScale
	property alias launcherWidth: themeJson.launcherWidth
	property alias launcherHeight: themeJson.launcherHeight

	//-----------------
	// resolved colors
	//-----------------
	readonly property color text: root.foreground
	readonly property color surface: root.background
	readonly property color highlight: root.accent

	// dimmed text for subtitles, placeholders and secondary labels
	readonly property color textMuted: root.alpha(root.text, 0.53)
	readonly property color textFaint: root.alpha(root.text, 0.40)

	// hover and selection washes, derived so they follow the text color
	readonly property color hoverFaint: root.alpha(root.text, 0.07)
	readonly property color hover: root.alpha(root.text, 0.13)
	readonly property color hoverStrong: root.alpha(root.text, 0.20)

	// selection washes follow the accent instead
	readonly property color selection: root.alpha(root.highlight, 0.20)
	readonly property color selectionSoft: root.alpha(root.highlight, 0.13)

	readonly property color border: root.text
	readonly property color borderSoft: root.alpha(root.text, 0.40)

	// the bar is translucent over the wallpaper, popups and the launcher are not
	readonly property color barBackground: root.alpha(root.surface, root.barOpacity)
	readonly property color inputBackground: root.alpha(root.surface, 0.20)

	// text drawn on top of a filled accent block needs to invert
	readonly property color onHighlight: root.surface

	//---------
	// metrics
	//---------
	readonly property int radius: root.cornerRadius
	readonly property int radiusSmall: Math.max(2, Math.round(root.cornerRadius / 2))

	// label text follows the user font, icon glyphs deliberately do not so that
	// picking a font without nerd font glyphs cannot break the bar icons
	readonly property string labelFont: root.fontFamily.length > 0
			? root.fontFamily
			: Qt.application.font.family

	//---------
	// helpers
	//---------
	// builds a translucent variant of a base color so alpha shades stay in sync
	// with whatever the user picked
	function alpha(base, amount) {
		return Qt.rgba(base.r, base.g, base.b, amount)
	}

	// every pixelSize in the shell goes through here so one scale moves all of
	// them together. the floor keeps text legible even at the smallest scale,
	// which matters because the settings app scales too and is the only way back
	function fontSize(base) {
		return Math.max(8, Math.round(base * root.fontScale))
	}

	// true when the string is something QML can actually parse as a color,
	// used to reject half typed values from the settings app
	function isValidColor(value) {
		if (typeof value !== "string") return false

		return /^#([0-9a-fA-F]{6}|[0-9a-fA-F]{8})$/.test(value.trim())
	}

	function resetToDefaults() {
		root.foreground = "#ebdbb2"
		root.background = "#181818"
		root.accent = "#ebdbb2"
		root.barOpacity = 0.73
		root.barHeight = 40
		root.cornerRadius = 8
		root.borderWidth = 1
		root.fontFamily = ""
		root.fontScale = 1.0
		root.launcherWidth = 480
		root.launcherHeight = 560
	}

	//-------------------
	// theme persistence
	//-------------------
	FileView {
		id: themeFile
		path: `${Quickshell.configDir}/theme.json`
		watchChanges: true
		onFileChanged: reload()
		onAdapterUpdated: writeAdapter()
		onLoadFailed: error => {
			if (error === FileViewError.FileNotFound) {
				writeAdapter()
			}
		}

		JsonAdapter {
			id: themeJson

			property string foreground: "#ebdbb2"
			property string background: "#181818"
			property string accent: "#ebdbb2"
			property real barOpacity: 0.73
			property int barHeight: 40
			property int cornerRadius: 8
			// 0 removes the outline from popups, the launcher and cards
			property int borderWidth: 1
			// empty means "use the system default font"
			property string fontFamily: ""
			// multiplies every text size in the shell
			property real fontScale: 1.0
			property int launcherWidth: 480
			property int launcherHeight: 560
		}
	}
}
