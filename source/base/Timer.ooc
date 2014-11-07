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
import io/FileWriter, DebugPrinting

clock: extern func () -> LLong
CLOCKS_PER_SEC: extern const LLong

Timer: class {
	_startTime: Double
	_endTime: Double
	_result: Double
	_total: Double
	_count: Int
	_min: Double
	_max: Double
	_timeList := static VectorList<Timer> new(100)
	_message: String
	_average: Double
	init: func (=_message) {
		this _min = INFINITY
		this _max = 0.0
	}
	start: func {
		this _startTime = (clock() as Double)
	}
	stop: func -> Double {
		this _endTime = (clock() as Double)
		this _result = (this _endTime - this _startTime) / CLOCKS_PER_SEC
		if (this _result < this _min)
			this _min = this _result
		if (this _result > this _max)
			this _max = this _result
		this _total = this _total + this _result
		this _count = this _count + 1
		this _average = this _total / this _count
		This _timeList add(this)
		this _result
	}
	printTimeList: static func {
		timeStr := ""
		for (i in 0..This _timeList count) {
			dataStr := This _timeList[i] _message  + ": Time = " + (This _timeList[i] _result toString() + ", Total = " + This _timeList[i] _total toString() + ", Count = " + This _timeList[i] _count toString() + ", Average = " + This _timeList[i] _average toString() + ", Min = " + This _timeList[i] _min toString() + ", Max = " + This _timeList[i] _max toString()  )
			timeStr = timeStr + dataStr  + "\n"
		}
		DebugPrinting printDebug(timeStr)
	}
	saveLog: static func {
		timeStr := ""
		for (i in 0..This _timeList count) {
			dataStr := This _timeList[i] _message  + ": Time = " + (This _timeList[i] _result toString() + ", Total = " + This _timeList[i] _total toString() + ", Count = " + This _timeList[i] _count toString() + ", Average = " + This _timeList[i] _average toString() + ", Min = " + This _timeList[i] _min toString() + ", Max = " + This _timeList[i] _max toString()  )
			timeStr = timeStr + dataStr  + "\n"
		}
		fw := FileWriter new("profiling.txt")
		fw write(timeStr)
		fw close()
	}
}
