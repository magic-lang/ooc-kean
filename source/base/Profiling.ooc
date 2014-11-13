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

import Timer

Profiling: class {
	_debugLevel: Int
	_logList := static VectorList<Profiling> new(100)
	_message: String
	_timer: Timer
	init: func (=_message, =_debugLevel) {
		this _timer = Timer new()
		This _logList add(this)
	}
	start: func {
		this _timer start()
	}
	stop: func -> Double {
		this _timer stop()
	}
	createOutput: static func (debugLevel: Int) -> String {
		output := ""
		for (i in 0..This _logList count) {
			if ((This _logList[i] _debugLevel == debugLevel) || (debugLevel == 0) ) {
				log := This _logList[i]
				output = output + log _message + " Time: " + log _timer _result toString() + " Average: " + log _timer _average toString() + " Min: " + log _timer _min toString() + " Max: " + log _timer _max toString() + "\n"
			}
		}
		output
	}
}
