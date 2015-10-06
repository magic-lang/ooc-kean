use ooc-unit
use ooc-math
use ooc-base
import math/Random
import math

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
					++countEqual
				expect(last >= 0.0f && last <= 1.0f)
				last = current
				current = generator next()
			}
			expect(countEqual < valuesCount)
			numbers := generator next(valuesCount)
			expect(numbers length == valuesCount)
			countEqual = 0
			for (i in 1 .. valuesCount)
				if (numbers[i] == numbers[i - 1])
					++countEqual
			expect(countEqual < valuesCount)
			generator = FloatUniformRandomGenerator new(15.0f, 20.0f)
			for (i in 0 .. valuesCount) {
				result := generator next()
				expect(result >= 15.0f && result <= 20.0f)
			}
		})
		this add("gaussian", func {
			valuesCount := 100
			countEqual := 0
			generator := FloatGaussianRandomGenerator new()
			last := generator next()
			current := generator next()
			for (i in 0 .. valuesCount) {
				if (last == current)
					++countEqual
				last = current
				current = generator next()
			}
			expect(countEqual < valuesCount)
			countEqual = 0
			numbers := generator next(valuesCount)
			expect(numbers length == valuesCount)
			for (i in 1 .. valuesCount)
				if (numbers[i] == numbers[i - 1])
					++countEqual
			expect(countEqual < valuesCount)
		})
		this add("seeds", func {
			valuesCount := 1_000_000
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
					++countEqual
				expect(x == y)
			}
			expect(countEqual < valuesCount)
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
			expect(Float absolute(mean - expectedMean) < tolerance)
		})
		this add("gaussian distribution", func {
			expectedMean := -3.0f
			expectedDeviation := 12.0f
			tolerance := 0.9f
			generator := FloatGaussianRandomGenerator new(expectedMean, expectedDeviation)
			values := generator next(1_000_000)
			mean := 0.0f
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			deviation := 0.0f
			for (i in 0 .. values length)
				deviation += (values[i] - mean) * (values[i] - mean)
			deviation = sqrt(deviation / values length)
			expect(Float absolute(mean - expectedMean) < tolerance)
			expect(Float absolute(deviation - expectedDeviation) < tolerance)
		})
		/*this add("measurement", func {
			timer := ClockTimer new()
			timer start()
			uniform := FloatUniformRandomGenerator new(-250.0f, 750.0f)
			sum := 0.0f
			for (i in 0 .. 1000) {
				sum += uniform next()
			}
			println(timer stop() toString())
			uniform free()
			timer start()
			sum2 := 0.0f
			for (j in 0 .. 1000) {
				sum += Random randFloat() * 1000.0f - 250.0f
			}
			println(timer stop() toString())
		})*/
	}
}
FloatRandomGeneratorTest new() run()
