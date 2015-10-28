use ooc-unit
use ooc-math
import math

IntRandomGeneratorTest: class extends Fixture {
	init: func {
		super("IntRandomGenerator")
		this add("seeds", func {
			valuesCount := 1_000_000
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
					++countEqual
				expect(x == y)
			}
			expect(countEqual < valuesCount)
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
			expect(Int absolute(mean - expectedMean) < tolerance)
		})
		this add("gaussian distribution", func {
			expectedMean := 2
			expectedDeviation := 12
			generator := IntGaussianRandomGenerator new(expectedMean, expectedDeviation)
			values := generator next(1_000_000)
			mean := 0
			for (i in 0 .. values length)
				mean += values[i]
			mean /= values length
			deviation := 0
			for (i in 0 .. values length)
				deviation += (values[i] - mean) * (values[i] - mean)
			deviation = sqrt(deviation / values length)
			expect(Int absolute(mean - expectedMean) < 2)
			expect(Int absolute(deviation - expectedDeviation) < 2)
		})
		this add("set seed", func {
			generator1 := IntUniformRandomGenerator new(0, 100)
			generator1 setSeed(123456)
			expect(generator1 next(), is equal to(79))
			expect(generator1 next(), is equal to(93))
			expect(generator1 next(), is equal to(50))
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
		})
	}
}

IntRandomGeneratorTest new() run()
