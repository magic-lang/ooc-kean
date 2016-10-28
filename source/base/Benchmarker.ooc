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
	_instanceCounter := static 0
	_name: String
	_profilers := VectorList<Profiler> new(32, false)
	init: func (name: String) {
		this _instanceCounter += 1
		this _name = name + this _instanceCounter
	}
	registerProfiler: func (profiler: Profiler) {
		if (profiler != null)
			this _profilers add(profiler)
	}
	log: func {
		filePath := this _name + ".txt"
		version (android)
			filePath = "/data/media/0/DCIM/Camera/" + filePath
		writer := FileWriter new(filePath)
		for (i in 0 .. this _profilers count) {
			output := this _profilers[i] name + ">" + this _profilers[i] averageTime + "|\n"
			writer write(output)
		}
		writer free()
	}
	free: override func {
		this _instanceCounter -= 1
		this _profilers free()
		super()
	}
}