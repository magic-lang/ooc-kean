/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

 use base

clock: extern func -> LLong
CLOCKS_PER_SEC: extern const LLong

Timer: abstract class {
	_startTime: Double
	_endTime: Double
	_result: Double
	_total: Double
	_count: Int
	_min: Double
	_max: Double
	_average: Double

	init: func { this reset() }
	start: abstract func
	stop: abstract func -> TimeSpan
	isRunning: virtual func -> Bool { !this _startTime equals(0.0) || !this _endTime equals(0.0) }
	measure: func (action: Func) -> TimeSpan {
		this start()
		action()
		this stop()
	}
	_update: virtual func {
		if (this _result < this _min)
			this _min = this _result
		if (this _result > this _max)
			this _max = this _result
		this _total += this _result
		this _count += 1
		this _average = this _total / this _count
	}
	reset: virtual func {
		this _min = Double positiveInfinity
		(this _max, this _startTime, this _endTime, this _result, this _total, this _count, this _average) = (0, 0, 0, 0, 0, 0, 0)
	}
}

WallTimer: class extends Timer {
	init: func { super() }
	start: override func { this _startTime = (Time runTimeMicro() as Double) } // Note: Only millisecond precision on Win32
	stop: override func -> TimeSpan {
		this _endTime = (Time runTimeMicro() as Double)
		this _result = this _endTime - this _startTime
		this _update()
		TimeSpan microseconds(this _result)
	}
}

CpuTimer: class extends Timer {
	init: func { super() }
	start: override func { this _startTime = (clock() as Double) }
	stop: override func -> TimeSpan {
		this _endTime = (clock() as Double)
		this _result = 1000.0 * (this _endTime - this _startTime) / CLOCKS_PER_SEC
		this _update()
		TimeSpan milliseconds(this _result)
	}
}
