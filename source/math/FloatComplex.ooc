//
// Copyright (c) 2011-2012 Anders Frisk
// Copyright (c) 2012-2015 Simon Mika <simon@mika.se>
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

use ooc-collections
import math
import text/StringTokenizer
import structs/ArrayList
import structs/FreeArrayList

FloatComplex: cover {
	real, imaginary: Float
	init: func@ (=real, =imaginary)
	conjugate ::= FloatComplex new(this real, - this imaginary)
	absoluteValue ::= (this real pow(2) + this imaginary pow(2)) sqrt()
	operator + (other: This) -> This { This new(this real + other real, this imaginary + other imaginary) }
	operator - (other: This) -> This { This new(this real - other real, this imaginary - other imaginary) }
	operator - -> This { This new(-this real, -this imaginary) }
	operator * (other: Float) -> This { This new(other * this real, other * this imaginary) }
	operator * (other: This) -> This {
		This new(
			this real * other real - this imaginary * other imaginary,
			this real * other imaginary + this imaginary * other real
		)
	}
	operator / (other: Float) -> This { This new(this real / other, this imaginary / other) }
	operator / (other: This) -> This { (this * other conjugate) / (other absoluteValue pow(2)) }
	operator == (other: This) -> Bool { this real == other real && this imaginary == other imaginary }
	operator != (other: This) -> Bool { !(this == other) }
	toString: func -> String {
		this real toString() >> (this imaginary > 0 ? " +" : " ") & this imaginary toString() >> "i"
	}
	parse: static func (input: String) -> This {
		realResult, imaginaryResult: Float
		parts: FreeArrayList<String> = input split(' ') as FreeArrayList
		realResult = parts[0] toFloat()
		imaginaryResult = parts[1] toFloat()
		parts free()
		This new (realResult, imaginaryResult)
	}
	exponential: func -> This {
		(this real) exp() * This new((this imaginary) cos(), (this imaginary) sin())
	}
	logarithm: func -> This {
		This new(this absoluteValue log(), atan2(this imaginary, this real))
	}
	rootOfUnity: static func (n: Int, k:= 1) -> This {
		This new(0, 2 * k * PI / n) exponential()
	}
	discreteFourierTransform: static func (input: HeapVector<This>) -> HeapVector<This> {
		result := HeapVector<This> new(input capacity)
		for (i in 0..(input capacity)) {
			for (j in 0..(input capacity))
				result[i] = result[i] + input[j] * FloatComplex rootOfUnity(input capacity, -i * j)
		}
		result
	}
	inverseDiscreteFourierTransform: static func (input: HeapVector<This>) -> HeapVector<This> {
		result := HeapVector<This> new(input capacity)
		for (i in 0..(input capacity)) {
			result[i] = input[i] conjugate
		}
		result = FloatComplex discreteFourierTransform(result)
		for (i in 0..(result capacity)) {
			result[i] = (result[i] conjugate) / (input capacity)
		}
		result
	}
	fastFourierTransform: static func (input: HeapVector<This>) -> HeapVector<This> {
		result := HeapVector<This> new(input capacity)
		if (input capacity == 1)
			result = input
		else {
			halfLength: Int = input capacity / 2
			evenInput := HeapVector<This> new(halfLength)
			oddInput := HeapVector<This> new(halfLength)
			for (i in 0..halfLength) {
				evenInput[i] = input[2 * i]
				oddInput[i] = input[2 * i + 1]
			}
			evenOutput := FloatComplex fastFourierTransform(evenInput)
			oddOutput := FloatComplex fastFourierTransform(oddInput)
			root: This
			for (i in 0..halfLength) {
				root = FloatComplex rootOfUnity(input capacity, -i)
				result[i] = evenOutput[i] + root * oddOutput[i]
				result[halfLength + i] = evenOutput[i] - root * oddOutput[i]
			}
		}
		result
	}
	inverseFastFourierTransform: static func (input: HeapVector<This>) -> HeapVector<This> {
		result := HeapVector<This> new(input capacity)
		for (i in 0..(input capacity)) {
			result[i] = input[i] conjugate
		}
		result = FloatComplex fastFourierTransform(result)
		for (i in 0..(result capacity)) {
			result[i] = (result[i] conjugate) / (input capacity)
		}
		result
	}
}
operator * (left: Float, right: FloatComplex) -> FloatComplex { FloatComplex new(left * right real, left * right imaginary) }
operator / (left: Float, right: FloatComplex) -> FloatComplex { (left * right conjugate) / (right absoluteValue pow(2)) }
