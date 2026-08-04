import Quickshell
import Quickshell.Io

Scope {
	//---------------
	// IPC (Hyprland)
	//---------------
	// qs ipc call launcher toggle|show|hide
	IpcHandler {
		target: "launcher"

		function toggle(): void {
			LauncherState.toggle()
		}

		function show(): void {
			LauncherState.show()
		}

		function hide(): void {
			LauncherState.hide()
		}
	}

	// one window per screen
	Variants {
		model: Quickshell.screens

		LauncherWindow {}
	}
}
