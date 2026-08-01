pragma Singleton

import QtQuick
import Quickshell
import Quickshell.Io

Singleton {
	id: root

	//-------------------
	// public properties
	//-------------------
	property int ramPercent: 0
	property int cpuPercent: 0
	property int gpuPercent: 0

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
	property string gpuType: "none" // "amd" | "nvidia" | "intel" | "none"
	property string gpuBusyPath: ""

	// to detect gpu vendor
	Process {
		id: gpuDetect
		command: [
			"sh",
			"-c",
			`
			for d in /sys/class/drm/card[0-9]*
			do
				[ -f "$d/device/vendor" ] || continue
				v=$(cat "$d/device/vendor")
				case "$v" in
				0x1002)
					if [ -f "$d/device/gpu_busy_percent" ]
					then
						echo "amd $d/device/gpu_busy_percent"
					else
						echo "amd"
					fi
					exit 0
					;;
				0x10de) 
					echo "nvidia"
					exit 0 
					;;
				0x8086)
					if [ -f "$d/gt_busy_percent" ]
					then
						echo "intel $d/gt_busy_percent"
					elif [ -f "$d/device/gt_busy_percent" ]
					then
						echo "intel $d/device/gt_busy_percent"
					else
						echo "intel"
					fi
					exit 0
					;;
				esac
			done
			echo "none"
			`
		]
		running: true
		stdout: StdioCollector {
			onStreamFinished: {
				const parts = text.trim().split(/\s+/)
				root.gpuType = parts[0] || "none"
				root.gpuBusyPath = parts[1] || ""
			}
		}
	}

	// AMD mainly
	FileView {
		id: gpuBusy
		path: root.gpuBusyPath
		onLoaded: {
			if (!root.gpuBusyPath.length) return
			const n = Number(text().trim())
			if (!Number.isNaN(n)) {
				root.gpuPercent = Math.min(100, Math.max(0, Math.round(n)))
			}
		}
	}

	// Nvidia
	Process {
		id: nvidiaQuery
		command: [
			"nvidia-smi",
			"--query-gpu=utilization.gpu",
			"--format=csv,noheader,nounits"
		]
		stdout: StdioCollector {
			onStreamFinished: {
				const n = Number(text.trim())
				if (!Number.isNaN(n)) {
					root.gpuPercent = Math.round(n)
				}
			}
		}
	}

	/* 
	 * Intel 
	 * - requires intel-gpu-tools install and the following command:
	 *
	 * 	sudo setcap cap_perfmon=+ep "$(command -v intel_gpu_top)"
	 */
	Process {
		id: intelQuery
		running: root.gpuType === "intel"
		command: [
			"intel_gpu_top",
			"-J",
			"-s",
			"1000",
			"-o",
			"-"
		]
		stdout: SplitParser {
			onRead: chunk => {
				let t = chunk.trim()
				if (t.startsWith("[")) {
					t = t.slice(1).trim()
				}
				if (t.startsWith(",")) {
					t = t.slice(1).trim()
				}
				if (!t.startsWith("{")) {
					t = "{" + t
				}
				if (!t.endsWith("}")) {
					t = t + "}"
				}
				try {
					const sample = JSON.parse(t)
					const engines = sample.engines || {}
					let busy = engines["Render/3D/0"]?.busy
					if (busy == null) {
						busy = 0
						for (const k in engines) {
							busy = Math.max(busy, Number(engines[k]?.busy) || 0)
						}
					}
					root.gpuPercent = Math.min(100, Math.max(0, Math.round(busy)))
				} catch (e) {
					// incomplete chunk, ignore and leave previous value
				}
			}
		}
		stdout: StdioCollector {
			onStreamFinished: {
				let t = text.trim()
				if (!t) return
				if (!t.startsWith("[")) {
					t = "[" + t.replace(/}\s*{/g, "},{") + "]"
				}
				try {
					const samples = JSON.parse(t)
					const sample = samples[samples.length - 1]
					const engines = sample?.engines || {}
					const render = engines["Render/3D/0"]?.busy
					let busy = render
					if (busy == null) {
						busy = 0
						for (const k in engines) {
							busy = Math.max(busy, Number(engines[k]?.busy) || 0)
						}
					}
					root.gpuPercent = Math.min(100, Math.max(0, Math.round(busy)))
				} catch (e) {
					// leave previous value
				}
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

			if (root.gpuBusyPath) {
				gpuBusy.reload()
			} else if (root.gpuType === "nvidia") {
				nvidiaQuery.running = true
			}
		}
	}
}
