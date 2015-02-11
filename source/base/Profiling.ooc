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
		result := 0.0f
		result = this _timer stop()
		result
	}
	timeStr : static String = " Time: "
	average : static String = " Average: "
	min : static String = " Min: "
	max : static String = " Max: "
	newLine : static String = "\n"
	createOutputString: static func (debugLevel: Int) -> String {
		output := ""
		outputTmp := ""
		for (i in 0..This _logList count) {
			if ((This _logList[i] _debugLevel == debugLevel) || (debugLevel == 1) ) {
				log := This _logList[i]
				//output = output + log _message + " Time: " + log _timer _result toString() + " Average: " + log _timer _average toString() + " Min: " + log _timer _min toString() + " Max: " + log _timer _max toString() + "\n"
				outputTmp = output + log _message
				if (i > 0)
					output free()
				logStr := log _timer _result toString()
				tmp := outputTmp + timeStr
				output = tmp + logStr
				tmp free()

				outputTmp free()
				outputTmp = output + average
				output free()
				logStr free()
				logStr = log _timer _average toString()
				output = outputTmp + logStr

				outputTmp free()
				outputTmp = output + min
				output free()
				logStr free()
				logStr = log _timer _min toString()
				output = outputTmp + logStr

				outputTmp free()
				outputTmp = output + max
				output free()
				logStr free()
				logStr = log _timer _max toString()
				output = outputTmp + logStr

				outputTmp free()
				logStr free()
				outputTmp = output + newLine

				output free()
				output = outputTmp
			}
		}
		output
	}
	reset: static func {
		This _logList clear()
	}
	dispose: static func {
		This _logList free()
	}
}
