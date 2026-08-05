import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Shapes.DesignHelpers
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Hyprland
import Quickshell.Io

PanelWindow {
	id: root

	color: "transparent"
	visible: false

	exclusionMode: ExclusionMode.Ignore
	WlrLayershell.layer: WlrLayer.Overlay

	onWidthChanged: if (visible) root.reposition()
	onHeightChanged: if (visible) root.reposition()

	//-------------------
	// public properties
	//-------------------
	property var anchorItem: null
	property alias isHovered: previewHoverHandler.hovered
	property var windows: []

	//----------------------------
	// private / local properties
	//----------------------------
	property real borderAngleDegrees: 0 // for setting gradient background
	property real borderAngleRadians: root.borderAngleDegrees * Math.PI / 180
	property real borderRatioX: Math.cos(root.borderAngleRadians)
	property real borderRatioY: Math.sin(root.borderAngleRadians)
	property var border: [
		[ 0.0, "Transparent" ]
	]

	//-------------
	// show / hide
	//-------------
	function show(anchorItem, windows) {
		root.anchorItem = anchorItem
		root.windows = windows

		const screen = anchorItem.Window?.window?.screen
		if (screen) {
			root.screen = screen
		}

		cancelHide()
		root.visible = true
		Qt.callLater(root.reposition)
	}

	function hide() {
		root.visible = false
		root.windows = []
		root.anchorItem = null
	}

	function scheduleHide() {
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop()
	}

	// accounts for selecting a different app icon
	function reposition() {
		if (!root.anchorItem || !root.visible) {
			return
		}

		const item = root.anchorItem
		// below the icon, horizontally centered on it
		const g = item.mapToGlobal(0, item.height)
		const local = root.contentItem.mapFromGlobal(g.x, g.y) 

		menu.x = local.x + (item.width - menu.width) / 2
		menu.y = local.y + 8
	}

	anchors {
		top: true
		bottom: true
		left: true
		right: true
	}

	Timer {
		id: hideTimer
		interval: 400
		onTriggered: root.hide()
	}

	Process {
		command: [
			"hyprctl", 
			"getoption", 
			"general:col.active_border"
		]
		running: true

		stdout: StdioCollector {
			onStreamFinished: {
				let line = text.match(/^[^\n]*/m)
				let items = line[0].split(' ')
				items.splice(0, 2)
				let angle = items.pop()
				root.borderAngleDegrees = angle.match(/\d*/)

				root.border.length = items.length
				root.border[0][1] = "#" + items[0]
				let increment = 1 / (items.length - 1)
				for (let i = 1; i < items.length; i++) {
					root.border[i] = [
						root.border[i - 1][0] + increment,
						"#" + items[i]
					]
				}
			} 
		}
	}

	WrapperRectangle {
		id: menu
		margin: 8
		radius: 8
		color: "#181818"

		HoverHandler {
			id: previewHoverHandler
			onHoveredChanged: {
				if (!hovered) {
					root.scheduleHide()
				}
			}
		}

		Row {
			id: previews
			spacing: 10

			Repeater {
				model: windows

				RectangleShape {
					required property var modelData // passed from repeater to child
					id: border

					width: preview.implicitWidth + 4
					height: preview.implicitHeight + 4
					antialiasing: true
					radius: 5
					fillColor: "transparent"
					property ShapeGradient gradientVal: null
					fillGradient: {
						root.visible
						preview.visible 
							? border.gradientVal 
							: null
					}

					function makeGradient() {
						let qml = ``
						qml += `import QtQuick\n`
						qml += `import QtQuick.Shapes\n`
						qml += `LinearGradient {\n`
						qml += `\tproperty real centerX: border.implicitWidth / 2\n`
						qml += `\tproperty real centerY: border.implicitHeight / 2\n`
						qml += `\tproperty real radius: Math.max(border.implicitWidth, border.implicitHeight)\n`
						qml += `\t\n`
						qml += `\tproperty real offsetX: radius * root.borderRatioX\n`
						qml += `\tproperty real offsetY: radius * root.borderRatioY\n`
						qml += `\t\n`
						qml += `\tx1: centerX - offsetX\n`
						qml += `\ty1: centerY - offsetY\n`
						qml += `\t\n`
						qml += `\tx2: centerX + offsetX\n`
						qml += `\ty2: centerY + offsetY\n`
						qml += `\t\n`
						for (let i = 0; i < root.border.length; i++) {
							let stop = root.border[i]
							qml += `\tGradientStop { position: ${stop[0]}; color: "${stop[1]}" }\n`
						}
						qml += `}`

						border.gradientVal = Qt.createQmlObject(qml, border, "gradient")
					}
					Component.onCompleted: makeGradient()

					// adds radius to child
					ClippingWrapperRectangle {
						anchors.centerIn: parent
						antialiasing: true
						radius: 4
						color: "transparent"

						ScreencopyView {
							id: preview
							anchors.centerIn: parent
							captureSource: modelData
							live: true
							constraintSize: Qt.size(500, 300)

							MouseArea {
								cursorShape: Qt.PointingHandCursor
								anchors.fill: parent
								onClicked: modelData.activate()
							}
						}
					}
				}
			}
		}
	}
}
