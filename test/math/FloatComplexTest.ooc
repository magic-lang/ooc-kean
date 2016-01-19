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
use base
use math
use collections
import FloatComplex
import structs/Vector

FloatComplexTest: class extends Fixture {
	complexNumber0 := FloatComplex new (2, 1)
	complexNumber1 := FloatComplex new (3, 2)
	complexNumber2 := FloatComplex new (5, 3)
	complexNumber3 := FloatComplex new (-2, -1)

	complexNumberArray := HeapVector<FloatComplex> new(4)
	complexNumberArray[0] = complexNumber0
	complexNumberArray[1] = complexNumber1
	complexNumberArray[2] = complexNumber2
	complexNumberArray[3] = complexNumber3

	tolerance := 1.0e-5f

	init: func {
		super("FloatComplex")
		this add("addition", func {
			expect((this complexNumber0 + this complexNumber1) real, is equal to(this complexNumber2 real))
			expect((this complexNumber0 + this complexNumber1) imaginary, is equal to(this complexNumber2 imaginary))
		})
		this add("subtraction", func {
			expect((this complexNumber2 - this complexNumber1) real, is equal to(this complexNumber0 real))
			expect((this complexNumber2 - this complexNumber1) imaginary, is equal to(this complexNumber0 imaginary))
		})
		this add("negative", func {
			expect((-this complexNumber0) real, is equal to(-2.0f) within(tolerance))
			expect((-this complexNumber0) imaginary, is equal to(-1.0f) within(tolerance))
		})
		this add("mulitplication", func {
			expect((this complexNumber0 * this complexNumber1) real, is equal to(4.0f) within(tolerance))
			expect((this complexNumber0 * this complexNumber1) imaginary, is equal to(7.0f) within(tolerance))
		})
		this add("scalar multiplication", func {
			expect(((-1.0f) * this complexNumber0) real, is equal to((-complexNumber0) real))
			expect(((-1.0f) * this complexNumber0) imaginary, is equal to((-complexNumber0) imaginary))
		})
		this add("division", func {
			expect((complexNumber2 / complexNumber0) real, is equal to(2.6f) within(tolerance))
			expect((complexNumber2 / complexNumber0) imaginary, is equal to(0.2f) within(tolerance))
		})
		this add("equality", func {
			expect(this complexNumber0 real, is equal to(2.0f) within(tolerance))
			expect(this complexNumber0 imaginary, is equal to(1.0f) within(tolerance))
			expect(this complexNumber0 == this complexNumber0, is true)
			expect(this complexNumber0 != this complexNumber1, is true)
			expect(this complexNumber1 == this complexNumber2, is false)
		})
		this add("toString and parse", func {
			expect(this complexNumber0 toString(), is equal to("2.00 +1.00i"))
			expect((FloatComplex parse(t"2.00 +1.00i")) == this complexNumber0, is true)
			expect(this complexNumber3 toString(), is equal to("-2.00 -1.00i"))
			expect((FloatComplex parse(t"-2.00 -1.00i")) == this complexNumber3, is true)
			expect(FloatComplex new (2, -1) toString(), is equal to("2.00 -1.00i"))
			expect((FloatComplex parse(t"2.00 -1.00i")) == FloatComplex new (2, -1), is true)
			expect(FloatComplex new (-2, 1) toString(), is equal to("-2.00 +1.00i"))
			expect((FloatComplex parse(t"-2.00 +1.00i")) == FloatComplex new (-2, 1), is true)
		})
		this add("exponential", func {
			expect(this complexNumber0 exponential() real, is equal to(this complexNumber0 real exp() * this complexNumber0 imaginary cos()) within(tolerance))
			expect(this complexNumber0 exponential() imaginary, is equal to(this complexNumber0 real exp() * this complexNumber0 imaginary sin()) within(tolerance))
			expect(this complexNumber2 exponential() logarithm() real, is equal to(this complexNumber2 real) within(tolerance))
			expect(this complexNumber2 exponential() logarithm() imaginary, is equal to(this complexNumber2 imaginary) within(tolerance))
		})
		this add("conjugate", func {
			expect(this complexNumber0 conjugate real, is equal to(this complexNumber0 real))
			expect(this complexNumber0 conjugate imaginary, is equal to(-this complexNumber0 imaginary))
			conjugateProduct := this complexNumber1 * this complexNumber1 conjugate
			expect(conjugateProduct real, is equal to (this complexNumber1 absoluteValue * this complexNumber1 absoluteValue) within(tolerance))
		})
		this add("roots of unity", func {
			expect(FloatComplex rootOfUnity(5, 0) real, is equal to(1.0f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 0) imaginary, is equal to(0.0f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 1) real, is equal to(0.309f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 1) imaginary, is equal to(0.951f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 2) real, is equal to(-0.809f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 2) imaginary, is equal to(0.588f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 3) real, is equal to(-0.809f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 3) imaginary, is equal to(-0.588f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 4) real, is equal to(0.309f) within(0.01f))
			expect(FloatComplex rootOfUnity(5, 4) imaginary, is equal to(-0.951f) within(0.01f))
		})
		this add("toText", func {
			complex := FloatComplex new(10, 5)
			text := complex toText() take()
			expect(text, is equal to(t"10.00 +5.00i"))
			text free()
		})
	}
}

FloatComplexTest new() run() . free()
