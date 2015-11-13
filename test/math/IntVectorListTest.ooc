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
import lang/IO

IntVectorListTest: class extends Fixture {
	init: func {
		super("IntVectorList")
		this add("sort", func {
			list := IntVectorList new()
			list add(-1)
			list add(2)
			list add(-3)
			list add(4)
			sorted := list sort()
			expect(sorted[0], is equal to(-3))
			expect(sorted[1], is equal to(-1))
			expect(sorted[2], is equal to(2))
			expect(sorted[3], is equal to(4))
			list free()
			sorted free()
		})
		this add("copy", func {
			list := IntVectorList new()
			list add(-1)
			list add(2)
			list add(-3)
			list add(4)
			copy := list copy()
			expect(list count == copy count)
			for (i in 0 .. list count)
				expect(copy[i], is equal to(list[i]))
			list free()
			copy free()
		})
		this add("compress", func {
			list := IntVectorList new()
			list add(1)
			list add(2)
			list add(1)
			list add(5)
			list add(2)
			list add(7)
			list add(6)
			list add(7)
			list add(7)
			compressed := list compress()
			expect(compressed[0], is equal to(1))
			expect(compressed[1], is equal to(2))
			expect(compressed[2], is equal to(5))
			expect(compressed[3], is equal to(6))
			expect(compressed[4], is equal to(7))
			list free()
			compressed free()
		})
	}
}
IntVectorListTest new() run()
