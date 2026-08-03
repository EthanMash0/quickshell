import QtQuick
import QtQuick.Layouts
import QtQuick.Shapes
import QtQuick.Shapes.DesignHelpers
import Quickshell
import Quickshell.Wayland
import Quickshell.Widgets
import Quickshell.Io

PopupWindow {
	id: root
	color: "transparent"
	implicitWidth: previews.implicitWidth + 16
	implicitHeight: previews.implicitHeight + 16

	property var windows: []

	visible: true

	property bool isOpen: true

	function show(wins, anchorItem) {
		root.windows = wins
		anchor.item = anchorItem
		anchor.updateAnchor()
		cancelHide()
		// visible = true
		root.isOpen = true
	}

	function hide() {
		hideTimer.stop()
		// visible = false
		windows = []
	}

	function scheduleHide() {
		root.isOpen = false
		hideTimer.restart()
	}

	function cancelHide() {
		hideTimer.stop()
	}

	property real borderAngleDegrees: 0
	property var border: [
		[ 0.0, "Transparent" ]
	]

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

	property real borderAngleRadians: root.borderAngleDegrees * Math.PI / 180
	property real borderRatioX: Math.cos(root.borderAngleRadians)
	property real borderRatioY: Math.sin(root.borderAngleRadians)

	anchor {
		edges: Edges.Bottom
		gravity: Edges.Bottom

		margins.top: 40
	}

	Timer {
		id: hideTimer
		interval: 200
		onTriggered: root.hide()
	}

	property alias isHovered: previewHoverHandler.hovered

	HoverHandler {
		id: previewHoverHandler
		onHoveredChanged: {
			if (hovered) {
				root.cancelHide()
			} else {
				root.scheduleHide()
			}
		}
	}

	WrapperRectangle {
		margin: 8
		radius: 8
		color: "#bb181818"

		opacity: root.isOpen ? 1.0 : 0.0
		scale: root.isOpen ? 1.0 : 0.8

		Behavior on opacity {
			NumberAnimation { duration: 150; easing.type: Easing.OutCubic }
		}
		Behavior on scale {
			NumberAnimation { duration: 150; easing.type: Easing.OutBack }
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
					fillGradient: root.isOpen && preview.isOpen ? border.gradientVal : null

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

							property bool isOpen: false

							Component.onCompleted: {
								preview.isOpen = true
							// 	border.fillGradient = root.isOpen ? border.gradientVal : null
							}

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
