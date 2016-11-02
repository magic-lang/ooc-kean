/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

import Profiler
import io/FileWriter

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
			filePath = "/data/media/0/DCIM/Camera/" & this _name & ".log"
		writer := FileWriter new(filePath)
		for (i in 0 .. this _profilers count) {
			output := this _profilers[i] name & ">" & this _profilers[i] averageTime & "|\n"
			writer write(output)
		}
		writer free()
	}
	free: override func {
		this _profilers free()
		this _name free()
		super()
	}
}
