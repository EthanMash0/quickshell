pragma Singleton

import Quickshell
import QtQuick

import "../../prefs"

Singleton {
	id: root
	readonly property string time: {
		Qt.formatDateTime(clock.date, Prefs.clockFormat)
	}

	SystemClock {
		id: clock
		// ticking every second all day is wasteful, so only do it when the
		// format actually shows seconds
		precision: Prefs.clockNeedsSeconds
				? SystemClock.Seconds
				: SystemClock.Minutes
	}
}
