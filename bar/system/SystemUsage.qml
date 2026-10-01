pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

import "../../prefs"

Singleton {
	id: root

	//-------------------
	// public properties
	//-------------------
	property int ramPercent: 0
	property int cpuPercent: 0
	property int gpuPercent: 0
	property int vramPercent: 0

	// cards discovered from sysfs. each entry:
	// slot, type, driver, label, busyPath, vramUsedPath, vramTotalPath, driFilter
	property var gpus: []
	// the card the bar is actually reading, after applying the preference
	property string activePci: ""
	property string activeLabel: ""

	// true when prefs names a card that is plugged in right now
	readonly property bool usingSavedGpu: {
		const slot = Prefs.gpuPciSlot
		if (!slot.length) return false
		const list = root.gpus
		for (let i = 0; i < list.length; ++i) {
			if (list[i].slot === slot) return true
		}
		return false
	}

	//-----
	// RAM
	//-----
	FileView {
		id: meminfo
		path: "/proc/meminfo"
		onLoaded: {
			const t = text()
			const total = Number(t.match(/MemTotal:\s+(\d+)/)?.[1])
			const avail = Number(t.match(/MemAvailable:\s+(\d+)/)?.[1])
			if (total > 0) {
				root.ramPercent = Math.round((total - avail) / total * 100)
			}
		}
	}

	//-----
	// CPU
	//-----
	property real lastCpuTotal: 0
	property real lastCpuIdle: 0

	FileView {
		id: stat
		path: "/proc/stat"
		onLoaded: {
			const m = text().match(/^cpu\s+(.+)$/m)
			if (!m) return

			const parts = m[1].trim().split(/\s+/).map(n => Number(n))
			const idle = parts[3] + (parts[4] || 0)
			const total = parts.reduce((a,b) => a + b, 0)

			const totalDiff = total - root.lastCpuTotal
			const idleDiff = idle - root.lastCpuIdle

			if (root.lastCpuTotal > 0 && totalDiff > 0) {
				root.cpuPercent = Math.round((1 - idleDiff / totalDiff) * 100)
			}

			root.lastCpuTotal = total
			root.lastCpuIdle = idle
		}
	}

	//-----
	// GPU
	//-----
	// "amd" | "nvidia" | "intel" | "none"
	property string gpuType: "none"
	property string gpuBusyPath: ""
	property string vramUsedPath: ""
	property string vramTotalPath: ""
	property string intelFilter: ""
	property bool intelHold: false
	property real vramUsedBytes: 0
	property real vramTotalBytes: 0

	// amdgpu has both mem_info files. nvidia reports memory from nvidia-smi.
	// xe discrete exposes a size file; its used amount is summed from fdinfo.
	readonly property bool hasVram: {
		if (root.gpuType === "nvidia") return true
		if (root.gpuType === "intel") return root.vramTotalPath.length > 0
		return root.vramUsedPath.length > 0 && root.vramTotalPath.length > 0
	}

	// one line per card, tab separated. pci slot is stable across boots; cardN is not.
	// an empty saved slot prefers the first card that has dedicated memory.
	Process {
		id: gpuDetect
		command: [
			"sh",
			"-c",
			`
			for d in /sys/class/drm/card*
			do
				base=$(basename "$d")
				case "$base" in
					card[0-9]|card[0-9][0-9]) ;;
					*) continue ;;
				esac
				[ -f "$d/device/vendor" ] || continue
				slot=$(sed -n 's/^PCI_SLOT_NAME=//p' "$d/device/uevent")
				[ -n "$slot" ] || continue
				v=$(tr -d '[:space:]' < "$d/device/vendor")
				drv=$(basename "$(readlink -f "$d/device/driver" 2>/dev/null)")
				line=$(lspci -s "$slot" -mm 2>/dev/null | head -n 1)
				label=$(printf '%s\n' "$line" | awk -F'"' '{print $6}')
				[ -n "$label" ] || label="$drv"
				label=$(printf '%s' "$label" | tr -d '[:cntrl:]')
				type=
				busy=
				used=
				total=
				case "$v" in
					0x1002)
						type=amd
						[ -f "$d/device/gpu_busy_percent" ] && busy="$d/device/gpu_busy_percent"
						[ -f "$d/device/mem_info_vram_used" ] && used="$d/device/mem_info_vram_used"
						[ -f "$d/device/mem_info_vram_total" ] && total="$d/device/mem_info_vram_total"
						;;
					0x10de)
						type=nvidia
						;;
					0x8086)
						type=intel
						if [ -f "$d/gt_busy_percent" ]
						then
							busy="$d/gt_busy_percent"
						elif [ -f "$d/device/gt_busy_percent" ]
						then
							busy="$d/device/gt_busy_percent"
						fi
						for t in "$d"/device/tile[0-9]/memory/physical_vram_size_bytes
						do
							[ -f "$t" ] || continue
							total="$t"
							break
						done
						;;
					*)
						continue
						;;
				esac
				printf '%s\t%s\t%s\t%s\t%s\t%s\t%s\t%s\n' \
					"$slot" "$type" "$drv" "$label" "$busy" "$used" "$total" "drm:/dev/dri/$base"
			done
			`
		]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {
				const lines = text.trim().length ? text.trim().split("\n") : []
				const found = []
				for (let i = 0; i < lines.length; ++i) {
					const p = lines[i].split("\t")
					if (p.length < 8) continue
					found.push({
						slot: p[0],
						type: p[1],
						driver: p[2],
						label: p[3],
						busyPath: p[4],
						vramUsedPath: p[5],
						vramTotalPath: p[6],
						driFilter: p[7]
					})
				}
				root.gpus = found
				root.applySelection()
			}
		}
	}

	Connections {
		target: Prefs
		function onGpuPciSlotChanged() {
			root.applySelection()
		}
	}

	function dedicated(card) {
		return card.type === "nvidia" || card.vramTotalPath.length > 0
	}

	function applySelection() {
		const list = root.gpus
		const pref = Prefs.gpuPciSlot
		let chosen = null

		if (pref.length > 0) {
			for (let i = 0; i < list.length; ++i) {
				if (list[i].slot === pref) {
					chosen = list[i]
					break
				}
			}
		}
		if (!chosen) {
			for (let i = 0; i < list.length; ++i) {
				if (root.dedicated(list[i])) {
					chosen = list[i]
					break
				}
			}
		}
		if (!chosen && list.length > 0)
			chosen = list[0]

		if (!chosen) {
			root.gpuType = "none"
			root.gpuBusyPath = ""
			root.vramUsedPath = ""
			root.vramTotalPath = ""
			root.intelFilter = ""
			root.activePci = ""
			root.activeLabel = ""
			root.gpuPercent = 0
			root.vramPercent = 0
			return
		}

		const switched = root.activePci !== chosen.slot || root.gpuType !== chosen.type
		const prevFilter = root.intelFilter

		root.gpuType = chosen.type
		root.gpuBusyPath = chosen.busyPath
		root.vramUsedPath = chosen.vramUsedPath
		root.vramTotalPath = chosen.vramTotalPath
		root.intelFilter = chosen.type === "intel" ? chosen.driFilter : ""
		root.activePci = chosen.slot
		root.activeLabel = chosen.label

		if (switched) {
			root.gpuPercent = 0
			root.vramPercent = 0
			root.vramUsedBytes = 0
			root.vramTotalBytes = 0
		}

		if (chosen.type === "intel" && prevFilter !== root.intelFilter)
			root.kickIntel()
		else if (chosen.type === "nvidia")
			nvidiaQuery.running = true

		Qt.callLater(root.reloadGpu)
	}

	function kickIntel() {
		if (root.gpuType !== "intel") return
		root.intelHold = true
		intelKick.restart()
	}

	function publishVram() {
		if (root.vramTotalBytes <= 0) return
		root.vramPercent = Math.min(100, Math.max(0, Math.round(root.vramUsedBytes / root.vramTotalBytes * 100)))
	}

	function reloadGpu() {
		if (root.gpuType === "amd" && root.gpuBusyPath.length)
			gpuBusy.reload()
		if (root.vramUsedPath.length)
			vramUsed.reload()
		if (root.vramTotalPath.length)
			vramTotal.reload()
	}

	// AMD utilization. intel_gpu_top and nvidia-smi cover the other two.
	FileView {
		id: gpuBusy
		path: root.gpuBusyPath
		onLoaded: {
			if (root.gpuType !== "amd" || !root.gpuBusyPath.length) return
			const n = Number(text().trim())
			if (!Number.isNaN(n))
				root.gpuPercent = Math.min(100, Math.max(0, Math.round(n)))
		}
	}

	// Nvidia. -i keeps this on the selected pci slot when more than one card is present.
	Process {
		id: nvidiaQuery
		command: [
			"nvidia-smi",
			"-i",
			root.activePci,
			"--query-gpu=utilization.gpu,memory.used,memory.total",
			"--format=csv,noheader,nounits"
		]
		stdout: StdioCollector {
			onStreamFinished: {
				if (root.gpuType !== "nvidia") return
				const line = (text.trim().split("\n")[0] || "")
				const parts = line.split(",")
				const util = Number((parts[0] || "").trim())
				const used = Number((parts[1] || "").trim())
				const total = Number((parts[2] || "").trim())
				if (!Number.isNaN(util))
					root.gpuPercent = Math.min(100, Math.max(0, Math.round(util)))
				if (total > 0 && !Number.isNaN(used))
					root.vramPercent = Math.min(100, Math.max(0, Math.round(used / total * 100)))
			}
		}
	}

	/*
	 * Intel utilization.
	 * requires intel-gpu-tools, and for the engine counters:
	 *
	 * 	sudo setcap cap_perfmon=+ep "$(command -v intel_gpu_top)"
	 *
	 * -d follows the card selected above, so an awake iGPU is not assumed.
	 */
	Process {
		id: intelQuery
		running: root.gpuType === "intel" && root.intelFilter.length > 0 && !root.intelHold
		command: [
			"intel_gpu_top",
			"-J",
			"-s",
			"1000",
			"-d",
			root.intelFilter,
			"-o",
			"-"
		]
		stdout: SplitParser {
			splitMarker: "\n},"
			onRead: chunk => {
				if (root.gpuType !== "intel") return
				let t = chunk.trim()
				if (t.startsWith("["))
					t = t.slice(1).trim()
				if (t.startsWith(","))
					t = t.slice(1).trim()
				if (!t.startsWith("{"))
					t = "{" + t
				t = t + "}"

				try {
					const sample = JSON.parse(t)
					const engines = sample.engines || {}
					let busy = engines["Render/3D"]?.busy
					if (busy == null) {
						busy = 0
						for (const k in engines)
							busy = Math.max(busy, Number(engines[k]?.busy) || 0)
					}
					root.gpuPercent = Math.min(100, Math.max(0, Math.round(busy)))
				} catch (e) {
					// incomplete chunk, ignore and leave previous value
				}
			}
		}
	}

	Timer {
		id: intelKick
		interval: 100
		onTriggered: root.intelHold = false
	}

	//------
	// VRAM
	//------
	FileView {
		id: vramUsed
		path: root.vramUsedPath
		onLoaded: {
			if (!root.vramUsedPath.length) return
			const n = Number(text().trim())
			if (Number.isNaN(n)) return
			root.vramUsedBytes = n
			root.publishVram()
		}
	}

	FileView {
		id: vramTotal
		path: root.vramTotalPath
		onLoaded: {
			if (!root.vramTotalPath.length) return
			const n = Number(text().trim())
			if (Number.isNaN(n)) return
			root.vramTotalBytes = n
			root.publishVram()
		}
	}

	// xe/i915 dedicated cards have no single "used" file. resident bytes live in
	// each client's fdinfo (vram0 on xe, local0 on i915) and are in KiB.
	Process {
		id: intelVram
		command: [
			"sh",
			"-c",
			`
			find /proc -regextype posix-extended -regex '/proc/[0-9]+/fdinfo/[0-9]+' -readable -exec awk -v slot="$1" '
				FNR == 1 { hit = 0 }
				$1 == "drm-pdev:" { hit = ($2 == slot) }
				hit && $1 ~ /^drm-resident-(vram|local)[0-9]+:$/ { sum += $2 * 1024 }
				END { printf "%d\\n", sum + 0 }
			' {} + 2>/dev/null
			`,
			"intel-vram",
			root.activePci
		]
		stdout: StdioCollector {
			onStreamFinished: {
				if (root.gpuType !== "intel" || !root.vramTotalPath.length) return
				const lines = text.trim().length ? text.trim().split("\n") : []
				let sum = 0
				for (let i = 0; i < lines.length; ++i) {
					const n = Number(lines[i])
					if (!Number.isNaN(n)) sum += n
				}
				root.vramUsedBytes = sum
				root.publishVram()
			}
		}
	}

	//-----------------
	// singleton timer
	//-----------------
	Timer {
		interval: 1000
		running: true
		repeat: true
		triggeredOnStart: true
		onTriggered: {
			meminfo.reload()
			stat.reload()
			root.reloadGpu()

			if (root.gpuType === "nvidia")
				nvidiaQuery.running = true
			else if (root.gpuType === "intel" && root.vramTotalPath.length)
				intelVram.running = true
		}
	}
}
