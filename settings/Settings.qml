import Quickshell
import Quickshell.Io

Scope {
	//---------------
	// IPC (Hyprland)
	//---------------
	// qs ipc call settings toggle|show|hide
	// qs ipc call settings open network|bluetooth|audio|appearance
	IpcHandler {
		target: "settings"

		function toggle(): void {
			SettingsState.toggle()
		}

		function show(): void {
			SettingsState.show()
		}

		function hide(): void {
			SettingsState.hide()
		}

		function open(page: string): void {
			SettingsState.showPage(page)
		}
	}

	// a normal toplevel window, so it is only ever created once rather than
	// once per screen like the bar and launcher
	SettingsWindow {}
}
