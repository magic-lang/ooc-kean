//
// Copyright (c) 2011-2015 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-unit
use ooc-math
use ooc-collections
import math
import FloatComplex
import FloatComplexVectorList
import lang/IO

FloatComplexVectorListTest: class extends Fixture {
	complexNumber0 := FloatComplex new (2, 1)
	complexNumber1 := FloatComplex new (3, 2)
	complexNumber2 := FloatComplex new (5, 3)
	complexNumber3 := FloatComplex new (-2, -1)

	complexNumberArray := FloatComplexVectorList new(4)
	complexNumberArray add(complexNumber0)
	complexNumberArray add(complexNumber1)
	complexNumberArray add(complexNumber2)
	complexNumberArray add(complexNumber3)

	tolerance := 0.00001

	init: func {
		super("FloatComplexVectorList")
		this add("discrete fourier transform", func {
			result := FloatComplexVectorList discreteFourierTransform(complexNumberArray)
			result = FloatComplexVectorList inverseDiscreteFourierTransform(result)
			for (i in 0 .. (complexNumberArray count))
				expect((result[i] - complexNumberArray[i]) absoluteValue < tolerance, is true)
		})
		this add("fast fourier transform", func {
			result := FloatComplexVectorList fastFourierTransform(complexNumberArray)
			resultInPlace := complexNumberArray copy()
			FloatComplexVectorList fastFourierTransformInPlace(resultInPlace)
			expect((result[0] - FloatComplex new(8, 5)) absoluteValue < tolerance, is true)
			expect((result[1] - FloatComplex new(0, -7)) absoluteValue < tolerance, is true)
			expect((result[2] - FloatComplex new(6, 3)) absoluteValue < tolerance, is true)
			expect((result[3] - FloatComplex new(-6, 3)) absoluteValue < tolerance, is true)
			for (i in 0 .. result count)
				expect((result[i] - resultInPlace[i]) absoluteValue < tolerance, is true)
			result = FloatComplexVectorList inverseFastFourierTransform(result)
			for (i in 0 .. (complexNumberArray count))
				expect((result[i] - complexNumberArray[i]) absoluteValue < tolerance, is true)
			fftBuffer := FloatComplexVectorList createFFTBuffer(complexNumberArray count)
			result = FloatComplexVectorList fastFourierTransform(complexNumberArray, fftBuffer)
			for (i in 0 .. (complexNumberArray count))
				expect((result[i] - resultInPlace[i]) absoluteValue < tolerance, is true)
		})
		this add("sum and mean", func {
			list := FloatComplexVectorList new()
			list add(FloatComplex new(1, 1))
			list add(FloatComplex new(2, -3))
			list add(FloatComplex new(4, -2))
			list add(FloatComplex new(-1, 8))
			sum := list sum
			mean := list mean
			expect(sum real == 6.0f)
			expect(sum imaginary == 4.0f)
			expect(mean real == 1.5f)
			expect(mean imaginary == 1.0f) //FIXME getting errors using "is equal to" here because... ooc (expected 1.00000000 got 1.00000000)
		})
		this add("real, imaginary lists", func {
			list := FloatComplexVectorList new()
			list add(FloatComplex new(1, 1))
			list add(FloatComplex new(2, -3))
			list add(FloatComplex new(4, -2))
			reals := list real
			imaginaries := list imaginary
			expect(reals sum, is equal to(7.0f) within(tolerance))
			expect(imaginaries sum == -4.0f) //FIXME getting errors using "is equal to" here because... ooc 
		})
		this add("createDefault", func {
			list := FloatComplexVectorList new(3, FloatComplex new(1, 2))
			expect(list real sum, is equal to(3.0f) within(tolerance))
			expect(list imaginary sum, is equal to(6.0f) within(tolerance))
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
		})
	}
}
FloatComplexVectorListTest new() run()
