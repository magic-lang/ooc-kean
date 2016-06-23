/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use collections
use unit

SortedVectorListClassTester: class {
	_value: Float
	value ::= this _value
	init: func (=_value)
}

sortedVectorListIntComparator := func (a, b: Int*) -> Bool { a@ < b@ }
sortedVectorListClassComparator := func (a, b: SortedVectorListClassTester*) -> Bool { a@ value < b@ value }

SortedVectorListTest: class extends Fixture {
	init: func {
		super("SortedVectorList")
		this add("Add (int)", func {
			list := SortedVectorList<Int> new(sortedVectorListIntComparator)
			value := 1
			for (i in 0 .. 100) {
				value = ((value + i) * 3) modulo(101)
				list add(value)
			}

			expect(list count, is equal to(100))
			for (i in 0 .. list count - 1)
				expect(list[i], is lessOrEqual than(list[i + 1]))
			list free()
		})
		this add("Add (class)", func {
			list := SortedVectorList<SortedVectorListClassTester> new(sortedVectorListClassComparator)
			value := 1.f
			for (i in 0 .. 100) {
				value = (((value + i) * 3) modulo(101)) as Float + 0.5f
				list add(SortedVectorListClassTester new(value))
			}

			expect(list count, is equal to(100))
			for (i in 0 .. list count - 1) {
				(first, second) := (list[i], list[i + 1])
				expect(list[i] value, is lessOrEqual than(list[i + 1] value))
			}
			list free()
		})
		this add("Append (int)", func {
			list := SortedVectorList<Int> new(sortedVectorListIntComparator)
			other := VectorList<Int> new()
			value := 1
			for (i in 0 .. 100) {
				value = ((value + i) * 3) modulo(101)
				list add(value)
				other add(value + 1)
			}
			expect(list count, is equal to(100))
			expect(other count, is equal to(100))

			list append(other)
			expect(list count, is equal to(200))
			for (i in 0 .. list count - 1)
				expect(list[i], is lessOrEqual than(list[i + 1]))
			(list, other) free()
		})
	}
}

SortedVectorListTest new() run() . free()
