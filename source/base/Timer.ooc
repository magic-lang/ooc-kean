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
	_average: Double
	init: func () {
		this _min = INFINITY
		this _max = 0.0
	}
	start: func {
		this _startTime = (clock() as Double)
	}
	stop: func -> Double {
		this _endTime = (clock() as Double)
		this _result = 1000.0 * (this _endTime - this _startTime) / CLOCKS_PER_SEC
		if (this _result < this _min)
			this _min = this _result
		if (this _result > this _max)
			this _max = this _result
		this _total += this _result
		this _count += 1
		this _average = this _total / this _count
		this _result
	}
	reset: func {
		this _startTime = 0
		this _endTime = 0
		this _result = 0
		this _total = 0
		this _count = 0
		this _min = 0
		this _average = 0
	}
}
