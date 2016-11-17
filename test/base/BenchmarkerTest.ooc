/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use unit
import io/[File, FileWriter]

BenchmarkerTest: class extends Fixture {
	outputDir := "test/base/output"
	outputFile := "test/base/output/benchmarker.txt"
	init: func {
		super("Benchmarker")
		File createDirectories(this outputDir)
		this add("log - w/o profiler", func {
			benchmarker := Benchmarker new("benchmarker") . log(this outputFile)
			this _validateFile(true)
			benchmarker free()
		})
		this add("log - w/ profiler", func {
			profiler := Profiler new("profiler")
			benchmarker := Benchmarker new("benchmarker") . registerProfiler(profiler)
			profiler start()
			for (i in 0 .. 10_000_000) { }
			profiler stop()
			benchmarker log(this outputFile)
			this _validateFile(false)
			(benchmarker, profiler) free()
		})
		this add("benchmark", func {
			quick := 0.00
			slow := 200.0
			exceptionCount := 0
			benchmarker := Benchmarker new("benchmarker")
			writer := FileWriter new(outputFile)
			profiler := Profiler new("profiler") . start()
			benchmarker registerProfiler(profiler)
			writer write("#{profiler name}>#{slow}|\n")
			profiler stop()
			writer free()
			try {
				benchmarker benchmark(this outputFile)
			} catch (exception: Exception) {
				exceptionCount += 1
				exception free()
			}
			expect(exceptionCount, is equal to(0))

			writer = FileWriter new(outputFile)
			writer write("#{profiler name}>#{quick}|\n")
			writer free()
			try {
				benchmarker benchmark(this outputFile)
			} catch (exception: Exception) {
				exceptionCount += 1
				exception free()
			}
			expect(exceptionCount, is equal to(1))
			(benchmarker, profiler) free()
		})
	}
	_validateFile: func (isEmpty: Bool) {
		file := File new(this outputFile)
		expect(file exists())
		content := file read()
		expect(content empty(), is equal to(isEmpty))
		file remove()
		(file, content) free()
	}
	free: override func {
		this outputDir free()
		this outputFile free()
		super()
	}
}

BenchmarkerTest new() run() . free()
