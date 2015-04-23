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
import text/StringTokenizer
import FloatComplex
import FloatComplexList
import lang/IO

FloatComplexListTest: class extends Fixture {

	complexNumber0 := FloatComplex new (2,1)
	complexNumber1 := FloatComplex new (3,2)
	complexNumber2 := FloatComplex new (5,3)
	complexNumber3 := FloatComplex new (-2,-1)

	complexNumberArray := FloatComplexList new(4)
	complexNumberArray[0] = complexNumber0
	complexNumberArray[1] = complexNumber1
	complexNumberArray[2] = complexNumber2
	complexNumberArray[3] = complexNumber3

	tolerance := 0.00001

	init: func() {
		super("FloatComplexList")
		this add("discrete fourier transform", func() {
			result := FloatComplexList discreteFourierTransform(complexNumberArray)
			result = FloatComplexList inverseDiscreteFourierTransform(result)
			for (i in 0..(complexNumberArray count)) {
				expect((result[i] - complexNumberArray[i]) absoluteValue < tolerance, is true)
			}
		})
		this add("fast fourier transform", func() {
			result := FloatComplexList fastFourierTransform(complexNumberArray)
			result = FloatComplexList inverseFastFourierTransform(result)
			for (i in 0..(complexNumberArray count)) {
				expect((result[i] - complexNumberArray[i]) absoluteValue < tolerance, is true)
			}
		})
	}
}
FloatComplexListTest new() run()
