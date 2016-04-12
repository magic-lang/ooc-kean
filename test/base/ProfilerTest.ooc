/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit
import io/File

ProfilerTest: class extends Fixture {
	init: func {
		super("Profiler")
		this add("log", func {
			this _createOutputDirectory()
			outputFile := "test/base/output/profilerTest.log"
			profiler := Profiler new("test")
			profiler start()
			for (i in 0 .. 10_000_000) { }
			profiler stop()
			Profiler logResults(outputFile)
			file := File new(outputFile)
			expect(file exists())
			content := file read()
			expect(content empty(), is equal to(false))
			(profiler, content, file) free()
		})
		this add("cleanup", func {
			profiler := Profiler new("for cleanup")
			profiler start() . stop()
			profilerToFree := Profiler new("to free")
			profilerToFree free()
		})
	}
	_createOutputDirectory: func {
		file := File new("test/base/output")
		file mkdir()
		file free()
	}
}

ProfilerTest new() run() . free()
