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

use collections
use base
import io/FileWriter

import Timer

Profiler: class {
	_name: String
	_timer := Timer new()
	init: func (=_name) { This _profilers add(this) }
	free: override func {
		for (i in 0 .. This _profilers count)
			if (this == This _profilers[i]) {
				This _profilers removeAt(i)
				break
			}
		this _timer free()
		super()
	}
	start: func {
		this _timer start()
	}
	stop: func {
		this _timer stop()
	}
	reset: func {
		this _timer reset()
	}
	_profilers := static VectorList<This> new(100)
	printResults: static func {
		This _logResults(func (s: String) { Debug print(s) })
	}
	logResults: static func (fileName := "profiling.txt") {
		fileWriter := FileWriter new(fileName)
		This _logResults(func (s: String) { fileWriter write(s) })
		fileWriter close()
		fileWriter free()
	}
	resetAll: static func { This _profilers apply(func (profiler: This) { profiler reset() }) }
	free: static func ~all {
		while (This _profilers count > 0)
			This _profilers remove() free()
		This _profilers free()
		This _profilers = null
	}
	_logResults: static func (logMethod: Func (String)) {
		for (i in 0 .. This _profilers count) {
			profiler := This _profilers[i]
			outputString := profiler _name + " Time: " & ("%.3f" formatFloat(profiler _timer _result / 1000.0f)) >> " Average: " & ("%.3f" formatFloat(profiler _timer _average / 1000.0f))
			logMethod(outputString)
			outputString free()
		}
		(logMethod as Closure) free()
	}
}
