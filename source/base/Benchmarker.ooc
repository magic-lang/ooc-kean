/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
import Profiler
import io/[FileWriter, FileReader]

Benchmarker: class {
	_name: String
	_profilers := VectorList<Profiler> new(32, false)
	init: func (=_name)
	registerProfiler: func (profiler: Profiler) {
		if (profiler != null)
			this _profilers add(profiler)
	}
	log: func (filePath := "benchmarker.log") {
		version (android)
			filePath = "/data/media/0/DCIM/Camera/#{this _name}.log"
		writer := FileWriter new(filePath)
		for (i in 0 .. this _profilers count) {
			output := "#{this _profilers[i] name}>#{this _profilers[i] averageTime}|\n"
			writer write(output)
		}
		writer free()
	}
	benchmark: func (filePath := "benchmarker.log") {
		input := this _readFile(filePath)
		inputRows := input split("|")
		for (i in 0 .. this _profilers count) {
			profiler := this _profilers[i]
			index := inputRows search(|row| profiler name == row trim() split(">")[0])
			if (index > -1) {
				thresholdMilliseconds := inputRows[index] trim() split(">")[1] toDouble()
				if (profiler timer _average > thresholdMilliseconds * 1000.0f)
					Debug error("Profiler(#{profiler _name}) timed out. Time: #{profiler _timer _average / 1000.0f}ms, Deadline: #{thresholdMilliseconds}ms")
				inputRows remove(index)
			}
		}
		input free()
		inputRows free()
	}
	_readFile: func (filePath: String) -> String {
		reader := FileReader new(filePath)
		result := CharBuffer new()
		reader read(result)
		reader free()
		String new(result)
	}
	free: override func {
		this _profilers free()
		this _name free()
		super()
	}
}
