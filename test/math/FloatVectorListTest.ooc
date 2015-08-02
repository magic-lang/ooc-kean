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
import lang/IO

FloatVectorListTest: class extends Fixture {
//	TODO: Implement the remaining tests
	tolerance := 0.000001f

	init: func {
		super("FloatVectorList")
		this add("sum", func {

		})
		this add("maxValue", func {

		})
		this add("mean", func {

		})
		this add("variance", func {

		})
		this add("standard deviation", func {

		})
		this add("sort", func {

		})
		this add("accumulate", func {

		})
		this add("copy", func {

		})
		this add("getSlice", func {
			list := FloatVectorList new()
			list add(1.0f)
			list add(2.0f)
			list add(3.0f)
			list add(4.0f)
			slice := list getSlice(1 .. 2)
			expect(slice[0] == 2.0f)
			expect(slice[1] == 3.0f)
		})
		this add("operator + (This)", func {

		})
		this add("add into", func {

		})
		this add("operator - (This)", func {

		})
		this add("operator * (Float)", func {

		})
		this add("operator / (Float)", func {

		})
		this add("operator + (Float)", func {

		})
		this add("operator - (Float)", func {

		})
		this add("array index", func {

		})
		this add("to string", func {

		})
		this add("median", func {
			list := FloatVectorList new()
			list add(2.0f)
			expect(list median(), is equal to(2.0f) within(tolerance))
			list add(1.0f)
			expect(list median(), is equal to(1.5f) within(tolerance))
			list add(6.0f)
			expect(list median(), is equal to(2.0f) within(tolerance))
			list add(4.0f)
			expect(list median(), is equal to(3.0f) within(tolerance))
			list add(7.0f)
			expect(list median(), is equal to(4.0f) within(tolerance))
		})
		this add("moving median filter", func {
			list := FloatVectorList new()
			list add(2.0f)
			list add(1.0f)
			list add(6.0f)
			list add(4.0f)
			list add(7.0f)
			filtered := list movingMedianFilter(3)
			expect(filtered[0], is equal to(1.5f) within(tolerance))
			expect(filtered[1], is equal to(2.0f) within(tolerance))
			expect(filtered[2], is equal to(4.0f) within(tolerance))
			expect(filtered[3], is equal to(6.0f) within(tolerance))
			expect(filtered[4], is equal to(5.5f) within(tolerance))
		})
	}
}
FloatVectorListTest new() run()
