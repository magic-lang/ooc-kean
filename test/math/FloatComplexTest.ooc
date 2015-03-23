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
import math
import FloatComplex

FloatComplexTest: class extends Fixture {

	complexNumber0 := FloatComplex new (2,1)
	complexNumber1 := FloatComplex new (3,2)
	complexNumber2 := FloatComplex new (5,3)

	init: func() {
		super("FloatComplex")
		this add("equality", func() {
			expect(this complexNumber0 real == 2, is true)
			expect(this complexNumber0 imaginary == 1, is true)
		})
		this add("addition", func() {
			expect((this complexNumber0 + this complexNumber1) real, is equal to(this complexNumber2 real))
			expect((this complexNumber0 + this complexNumber1) imaginary, is equal to(this complexNumber2 imaginary))
		})
		this add("subtraction", func() {
			expect((this complexNumber2 - this complexNumber1) real, is equal to(this complexNumber0 real))
			expect((this complexNumber2 - this complexNumber1) imaginary, is equal to(this complexNumber0 imaginary))
		})
		this add("negative", func() {
			expect(-this complexNumber0 real == -2, is true)
			expect(-this complexNumber0 imaginary == -1, is true)
		})
		this add("mulitplication", func() {
			expect((this complexNumber0 * this complexNumber1) real == 4, is true)
			expect((this complexNumber0 * this complexNumber1) imaginary == 7, is true)
		})
		this add("scalar multiplication", func() {
			expect((this complexNumber0 * (-1.0f)) real, is equal to((-complexNumber0) real))
			expect((this complexNumber0 * (-1.0f)) imaginary, is equal to((-complexNumber0) imaginary))
		})
	}
}
FloatComplexTest new() run()


/*
expect(this complexNumber0 == this complexNumber0, is true)
expect(this complexNumber0 != this complexNumber1, is true)
expect(this complexNumber1 == this complexNumber2, is true)
*/
