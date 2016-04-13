/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use math

IntRandomGeneratorTest: class extends Fixture {
	init: func {
		super("IntRandomGenerator")
		this add("seeds", func {
			valuesCount := 100_000
			countEqual := 0
			seed := 26234
			generator1 := IntUniformRandomGenerator new(seed)
			generator2 := IntUniformRandomGenerator new(seed)
			generator3 := IntUniformRandomGenerator new(seed + 1)
			for (i in 0 .. valuesCount) {
				x := generator1 next()
				y := generator2 next()
				z := generator3 next()
				if (x == z)
					countEqual += 1
				expect(x, is equal to(y))
			}
			expect(countEqual, is less than(valuesCount))
			(generator1, generator2, generator3) free()
		})
		this add("uniform distribution", func {
			a := -167
			b := 934
			expectedMean := (b + a) / 2
			tolerance := expectedMean / 10
			intGenerator := IntUniformRandomGenerator new(a, b)
			values := intGenerator next(1_000_000)
			mean := 0
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			expect((mean - expectedMean) absolute < tolerance)
			(values, intGenerator) free()
		})
		this add("gaussian distribution", func {
			expectedMean := 2
			expectedDeviation := 12
			generator := IntGaussianRandomGenerator new(expectedMean - 1, expectedDeviation - 1)
			generator setRange(expectedMean, expectedDeviation)
			values := generator next(1_000_000)
			mean := 0
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			deviation := 0
			for (i in 0 .. values length)
				deviation += (values[i] - mean) * (values[i] - mean)
			deviation = sqrt(deviation / values length)
			expect((mean - expectedMean) absolute < 2)
			expect((deviation - expectedDeviation) absolute < 2)
			(values, generator) free()
		})
		this add("uniform range", func {
			uniformGenerator := IntUniformRandomGenerator new()
			uniformGenerator setRange(-250_000, 250_000)
			uniformLowest := 250_000
			uniformHighest := -250_000
			for (i in 0 .. 100_000) {
				value := uniformGenerator next()
				if (value > uniformHighest)
					uniformHighest = value
				else if (value < uniformLowest)
					uniformLowest = value
			}
			expect(uniformLowest, is greaterOrEqual than(uniformGenerator minimum))
			expect(uniformHighest, is lessOrEqual than(uniformGenerator maximum))
			expect(uniformLowest, is greaterOrEqual than(-250_000))
			expect(uniformHighest, is lessOrEqual than(250_000))
			uniformGenerator free()
		})
		this add("set seed", func {
			generatorUniform := IntUniformRandomGenerator new(0, 100)
			generatorGaussian := IntGaussianRandomGenerator new(0, 10)
			generatorUniform setSeed(123456)
			generatorGaussian setSeed(789012)
			expect(generatorUniform next(), is equal to(79))
			expect(generatorUniform next(), is equal to(93))
			expect(generatorUniform next(), is equal to(50))
			expect(generatorGaussian next(), is equal to(-12))
			expect(generatorGaussian next(), is equal to(5))
			expect(generatorGaussian next(), is equal to(1))
			(generatorUniform, generatorGaussian) free()
		})
		this add("global seed", func {
			IntRandomGenerator permanentSeed = 123455
			generator1 := IntUniformRandomGenerator new(0, 100)
			expect(generator1 next(), is equal to(76))
			expect(generator1 next(), is equal to(51))
			expect(generator1 next(), is equal to(6))
			generator2 := IntUniformRandomGenerator new(0, 100)
			expect(generator2 next(), is equal to(76))
			expect(generator2 next(), is equal to(51))
			expect(generator2 next(), is equal to(6))
			(generator1, generator2) free()
		})
	}
}

IntRandomGeneratorTest new() run() . free()
