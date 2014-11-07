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
import io/FileWriter

clock: extern func () -> LLong
CLOCKS_PER_SEC: extern const LLong

Timer: class {
	_startTime: Double
	_endTime: Double
	_total: Double
	_count: Int
	_min: Double
	_max: Double
	_timeList := static VectorList<String> new(100)
	init: func {
		this _min = INFINITY
		this _max = 0.0
	}
	startTimer: func {
		this _startTime = (clock() as Double)
	}
	stopTimer: func (message: String)  -> Double {
		this _endTime = (clock() as Double)
		result := (this _endTime - this _startTime) / CLOCKS_PER_SEC
		if (result < this _min)
			this _min = result
		if (result > this _max)
			this _max = result
		this _total = this _total + result
		this _count = this _count + 1
		average := this _total / this _count
		dataStr := message + ": Time = " + (result toString() + ", Total = " + this _total toString() + ", Count = " + this _count toString() + ", Average = " + average toString() + ", Min = " + this _min toString() + ", Max = " + this _max toString()  )
		This _timeList add(dataStr)
		result
	}
	printTimeList: static func {
		timeStr := ""
		for (i in 0..This _timeList count) {
			timeStr = timeStr + This _timeList[i]  + "\n"
		}
		(timeStr) println()
		fw := FileWriter new("profiling.txt")
		fw write(timeStr)
		fw close()
	}
}
