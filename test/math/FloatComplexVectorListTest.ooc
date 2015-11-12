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
	}
}
FloatComplexVectorListTest new() run()
