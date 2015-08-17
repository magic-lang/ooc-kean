/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-collections
use ooc-base
import io/FileWriter

import Timer

Profiler: class {
	_debugLevel: Int
	_profilers := static VectorList<This> new(100)
	_name: String
	_timer := Timer new()
	_clockTimer := ClockTimer new()
	init: func (=_name, debugLevel := 0) { This _profilers add(this) }
	start: func {
		this _timer start()
		this _clockTimer start()
	}
	stop: func {
		this _timer stop()
		this _clockTimer stop()
	}
	printResults: static func {
		This _profilers apply(func (profiler: This) {
			outputString := profiler _name + " Time: " & ("%.3f" formatFloat(profiler _timer _result / 1000.0f)) >> " Average: " & ("%.3f" formatFloat(profiler _timer _average / 1000.0f))
			Debug print(outputString)
			outputString free()
		})
	}
	free: override func {
		this _timer free()
		this _timer = null
		this _clockTimer free()
		this _clockTimer = null
		super()
	}
	logResults: static func (fileName := "profiling.txt") {
		fw := FileWriter new(fileName)
		This _profilers apply(func (profiler: This) {
			outputString := profiler _name + " Time: " & ("%.3f" formatFloat(profiler _timer _result / 1000.0f)) >> " Average: " & ("%.3f" formatFloat(profiler _timer _average / 1000.0f))
			fw write(outputString)
			outputString free()
		})
		fw close()
	}
	reset: func {
		this _timer reset()
		this _clockTimer reset()
	}
	resetAll: static func { This _profilers apply(func (profiler: This) { profiler reset() }) }
	dispose: static func {
		This _profilers free()
		This _profilers = null
	}
}
