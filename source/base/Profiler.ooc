/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use base
import io/FileWriter

import Timer

Profiler: class {
	_name: String
	_timer := WallTimer new()
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
		fileWriter free()
	}
	resetAll: static func { This _profilers apply(func (profiler: This) { profiler reset() }) }
	free: static func ~all {
		while (This _profilers count > 0)
			This _profilers remove() free()
		This _profilers free()
		This _profilers = null
	}
	benchmark: static func (task: Func, timeout := TimeSpan milliseconds(1000.0)) -> Double {
		numberOfIterations := 0
		timer := WallTimer new()
		totalTime := TimeSpan new(0)
		while (totalTime < timeout) {
			numberOfIterations += 1
			timer start()
			task()
			totalTime += timer stop()
		}
		timer free()
		(task as Closure) free(Owner Receiver)
		totalTime toMilliseconds() / (numberOfIterations * 1000.0)
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

GlobalCleanup register(|| Profiler free~all())
