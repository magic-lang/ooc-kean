/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use math

FloatRandomGeneratorTest: class extends Fixture {
	init: func {
		super("FloatRandomGenerator")
		this add("uniform", func {
			valuesCount := 200
			countEqual := 0
			generator := FloatUniformRandomGenerator new()
			last := generator next()
			current := generator next()
			for (i in 0 .. valuesCount) {
				if (last == current)
					countEqual += 1
				expect(last, is within(0.f, 1.f))
				last = current
				current = generator next()
			}
			expect(countEqual, is less than(valuesCount))
			numbers := generator next(valuesCount)
			expect(numbers length == valuesCount)
			countEqual = 0
			for (i in 1 .. valuesCount)
				if (numbers[i] == numbers[i - 1])
					countEqual += 1
			expect(countEqual, is less than(valuesCount))
			generator = FloatUniformRandomGenerator new(15.0f, 20.0f)
			for (i in 0 .. valuesCount) {
				result := generator next()
				expect(result, is within(15.0f, 20.0f))
			}
			(numbers, generator) free()
		})
		this add("gaussian", func {
			valuesCount := 100
			countEqual := 0
			generator := FloatGaussianRandomGenerator new()
			last := generator next()
			current := generator next()
			for (i in 0 .. valuesCount) {
				if (last == current)
					countEqual += 1
				last = current
				current = generator next()
			}
			expect(countEqual, is less than(valuesCount))
			countEqual = 0
			numbers := generator next(valuesCount)
			expect(numbers length == valuesCount)
			for (i in 1 .. valuesCount)
				if (numbers[i] == numbers[i - 1])
					countEqual += 1
			expect(countEqual, is less than(valuesCount))
			(numbers, generator) free()
		})
		this add("seeds", func {
			valuesCount := 100_000
			countEqual := 0
			seed := 26234
			generator1 := FloatUniformRandomGenerator new(seed)
			generator2 := FloatUniformRandomGenerator new(seed)
			generator3 := FloatUniformRandomGenerator new(seed + 1)
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
			a := 2.41f
			b := 10.44f
			expectedMean := (b + a) / 2
			tolerance := expectedMean / 10
			floatGenerator := FloatUniformRandomGenerator new(a, b)
			values := floatGenerator next(1_000_000)
			mean := 0.0f
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			expect((mean - expectedMean) absolute < tolerance)
			(values, floatGenerator) free()
		})
		this add("gaussian distribution", func {
			expectedMean := -3.0f
			expectedDeviation := 12.0f
			tolerance := 0.9f
			generator := FloatGaussianRandomGenerator new(expectedMean - 1.0f, expectedDeviation - 1.0f)
			generator setRange(expectedMean, expectedDeviation)
			values := generator next(1_000_000)
			mean := 0.0f
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			deviation := 0.0f
			for (i in 0 .. values length)
				deviation += (values[i] - mean) * (values[i] - mean)
			deviation = sqrt(deviation / values length)
			expect((mean - expectedMean) absolute < tolerance)
			expect((deviation - expectedDeviation) absolute < tolerance)
			(values, generator) free()
		})
		this add("uniform range", func {
			uniformGenerator := FloatUniformRandomGenerator new()
			uniformGenerator setRange(-25_000.0f, 25_000.0f)
			uniformLowest := 25_000.0f
			uniformHighest := -25_000.0f
			for (i in 0 .. 100_000) {
				value := uniformGenerator next()
				if (value > uniformHighest)
					uniformHighest = value
				else if (value < uniformLowest)
					uniformLowest = value
			}
			expect(uniformLowest, is greaterOrEqual than(uniformGenerator minimum))
			expect(uniformHighest, is lessOrEqual than(uniformGenerator maximum))
			expect(uniformLowest, is greaterOrEqual than(-25_000.0f))
			expect(uniformHighest, is lessOrEqual than(25_000.0f))
			uniformGenerator free()
		})
		this add("set seed", func {
			generator1 := FloatUniformRandomGenerator new(0, 100)
			generator1 setSeed(123456)
			expect(generator1 next(), is equal to(5.99f) within(0.01f))
			expect(generator1 next(), is equal to(54.54f) within(0.01f))
			expect(generator1 next(), is equal to(20.76f) within(0.01f))
			generator1 free()
		})
		this add("global seed", func {
			FloatRandomGenerator permanentSeed = 123455
			generator1 := FloatUniformRandomGenerator new(0, 100)
			expect(generator1 next(), is equal to(5.98f) within(0.01f))
			expect(generator1 next(), is equal to(57.96f) within(0.01f))
			expect(generator1 next(), is equal to(8.52f) within(0.01f))
			generator2 := FloatUniformRandomGenerator new(0, 100)
			expect(generator2 next(), is equal to(5.98f) within(0.01f))
			expect(generator2 next(), is equal to(57.96f) within(0.01f))
			expect(generator2 next(), is equal to(8.52f) within(0.01f))
			(generator1, generator2) free()
		})
	}
}

FloatRandomGeneratorTest new() run() . free()
