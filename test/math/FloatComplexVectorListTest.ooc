/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use math
use collections
import FloatComplex
import FloatComplexVectorList

FloatComplexVectorListTest: class extends Fixture {
	complexNumber0 := FloatComplex new (2, 1)
	complexNumber1 := FloatComplex new (3, 2)
	complexNumber2 := FloatComplex new (5, 3)
	complexNumber3 := FloatComplex new (-2, -1)

	complexNumberArray := FloatComplexVectorList new(4)
	this complexNumberArray add(this complexNumber0)
	this complexNumberArray add(this complexNumber1)
	this complexNumberArray add(this complexNumber2)
	this complexNumberArray add(this complexNumber3)

	init: func {
		tolerance := 0.00001f
		super("FloatComplexVectorList")
		this add("discrete fourier transform", func {
			result := FloatComplexVectorList discreteFourierTransform(this complexNumberArray)
			result = FloatComplexVectorList inverseDiscreteFourierTransform(result)
			for (i in 0 .. (this complexNumberArray count))
				expect((result[i] - this complexNumberArray[i]) absoluteValue < tolerance, is true)
			result free()
		})
		this add("fast fourier transform", func {
			result := FloatComplexVectorList fastFourierTransform(this complexNumberArray)
			resultInPlace := this complexNumberArray copy()
			FloatComplexVectorList fastFourierTransformInPlace(resultInPlace)
			expect((result[0] - FloatComplex new(8, 5)) absoluteValue < tolerance, is true)
			expect((result[1] - FloatComplex new(0, -7)) absoluteValue < tolerance, is true)
			expect((result[2] - FloatComplex new(6, 3)) absoluteValue < tolerance, is true)
			expect((result[3] - FloatComplex new(-6, 3)) absoluteValue < tolerance, is true)
			for (i in 0 .. result count)
				expect((result[i] - resultInPlace[i]) absoluteValue < tolerance, is true)
			result = FloatComplexVectorList inverseFastFourierTransform(result)
			for (i in 0 .. (this complexNumberArray count))
				expect((result[i] - this complexNumberArray[i]) absoluteValue < tolerance, is true)
			fftBuffer := FloatComplexVectorList createFFTBuffer(this complexNumberArray count)
			result = FloatComplexVectorList fastFourierTransform(this complexNumberArray, fftBuffer)
			for (i in 0 .. (this complexNumberArray count))
				expect((result[i] - resultInPlace[i]) absoluteValue < tolerance, is true)
			result free()
		})
		this add("sum and mean", func {
			list := FloatComplexVectorList new()
			list add(FloatComplex new(1, 1))
			list add(FloatComplex new(2, -3))
			list add(FloatComplex new(4, -2))
			list add(FloatComplex new(-1, 8))
			sum := list sum
			mean := list mean
			expect(sum real, is equal to(6.0f) within(tolerance))
			expect(sum imaginary, is equal to(4.0f) within(tolerance))
			expect(mean real, is equal to(1.5f) within(tolerance))
			expect(mean imaginary, is equal to(1.0f) within(tolerance))
			list free()
		})
		this add("real, imaginary lists", func {
			list := FloatComplexVectorList new()
			list add(FloatComplex new(1, 1))
			list add(FloatComplex new(2, -3))
			list add(FloatComplex new(4, -2))
			reals := list real
			imaginaries := list imaginary
			expect(reals sum, is equal to(7.0f) within(tolerance))
			expect(imaginaries sum, is equal to(-4.0f) within(tolerance))
			list free()
		})
		this add("createDefault", func {
			list := FloatComplexVectorList new(3, FloatComplex new(1, 2))
			(reals, imaginaries) := (list real, list imaginary)
			expect(reals sum, is equal to(3.0f) within(tolerance))
			expect(imaginaries sum, is equal to(6.0f) within(tolerance))
			(reals, imaginaries, list) free()
		})
		this add("addInto and operators", func {
			list := FloatComplexVectorList new(3, FloatComplex new(1, 2))
			originalSum := list sum
			other := FloatComplexVectorList new(2, FloatComplex new(2, 3))
			single := FloatComplex new(1, 1)

			list addInto(other)
			expect(list sum == originalSum + other sum)

			added := list + single
			subtracted := list - single
			expect(added sum real, is equal to(10.0f) within(tolerance))
			expect(added sum imaginary, is equal to(15.0f) within(tolerance))
			expect(subtracted sum real, is equal to(4.0f) within(tolerance))
			expect(subtracted sum imaginary, is equal to(9.0f) within(tolerance))

			(added, subtracted, list, other) free()
		})
		this add("toText", func {
			list := FloatComplexVectorList new()
			list add(FloatComplex new(-1, 2))
			list add(FloatComplex new(3, -4))
			list add(FloatComplex new(-5, 6))
			text := list toText() take()
			expect(text, is equal to(t"-1.00 +2.00i\n3.00 -4.00i\n-5.00 +6.00i"))
			(text, list) free()
		})
		this add("getZeros", func {
			zeros := FloatComplexVectorList getZeros(7)
			sum := zeros sum
			expect(sum real, is equal to(0.f) within(tolerance))
			expect(sum imaginary, is equal to(0.f) within(tolerance))
			zeros free()
		})
	}

	free: override func {
		this complexNumberArray free()
		super()
	}
}

FloatComplexVectorListTest new() run() . free()
