/*
* Copyright (C) 2014 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

use ooc-unit
use ooc-collections

TestClass: class {
	_value := 0
	value ::= _value
	init: func(=_value)
}

VectorTest: class extends Fixture {

	sortFunc: static func (a,b: Int) -> Bool {
		result := a > b
		"arguments to sortFunc %i, %i : %i" format(a,b,result) println()
		result
	}
	sortFuncClass: static func (a,b: TestClass) -> Bool {
		a value > b value
	}
	passByRef: static func (vec: VectorList<Int>@) -> Int {
		vec[0]
	}
	init: func {
		super("VectorList")
		this add("VectorList cover create", func {

			vectorList := VectorList<Int> new() as VectorList<Int>

			expect(vectorList count, is equal to(0))
			vectorList add(0)
			vectorList add(1)
			vectorList add(2)

			expect(vectorList count, is equal to(3))
			removedInt := vectorList remove()
			expect(vectorList count, is equal to(2))
			expect(removedInt, is equal to(2))
			removedInt = vectorList remove()
			expect(vectorList count, is equal to(1))
			expect(removedInt, is equal to(1))
			removedInt = vectorList remove()
			expect(vectorList count, is equal to(0))
			expect(removedInt, is equal to(0))

			expect(vectorList count, is equal to(0))
			vectorList add(3)
			vectorList add(4)
			vectorList add(5)
			expect(vectorList count, is equal to(3))
			removedInt = vectorList remove()
			expect(vectorList count, is equal to(2))
			expect(removedInt, is equal to(5))
			removedInt = vectorList remove()
			expect(vectorList count, is equal to(1))
			expect(removedInt, is equal to(4))
			removedInt = vectorList remove()
			expect(vectorList count, is equal to(0))
			expect(removedInt, is equal to(3))

			for (i in 0 .. vectorList count)
				vectorList remove()
			expect(vectorList count, is equal to(0))

			for (i in 0 .. 10)
				vectorList add(i)
			expect(vectorList count, is equal to(10))

			compareInt := vectorList[3]
			removedInt = vectorList remove(3)
			expect(removedInt , is equal to(compareInt))

			compareInt = vectorList[5]
			removedInt = vectorList remove(5)
			expect(removedInt, is equal to(compareInt))

			vectorList insert(5, 4)
			expect(vectorList[5], is equal to(4))

			vectorList clear()
			for (i in 0 .. vectorList count)
				expect(vectorList[i], is equal to(null))
			for (i in 0 .. 10)
				vectorList add(i)
			expect(vectorList count, is equal to(10))
			vectorList free()
		})
		this add("VectorList append", func {
			firstList := VectorList<Int> new()
			firstList add(0)
			firstList add(1)
			firstList add(2)
			secondList := VectorList<Int> new()
			secondList add(3)
			secondList add(4)
			secondList add(5)
			firstList append(secondList)
			expect(firstList[0], is equal to(0))
			expect(firstList[1], is equal to(1))
			expect(firstList[2], is equal to(2))
			expect(firstList[3], is equal to(3))
			expect(firstList[4], is equal to(4))
			expect(firstList[5], is equal to(5))
			expect(firstList count, is equal to(6))
			firstList free()
			secondList free()
		})
		this add("VectorList getFirstElements", func {
			list := VectorList<Int> new()
			list add(0)
			list add(1)
			list add(2)
			firstResult := list getFirstElements(2)
			secondResult := firstResult getFirstElements(5)
			expect(secondResult count, is equal to(2))
			expect(secondResult[0], is equal to(0))
			expect(secondResult[1], is equal to(1))
			list free()
			firstResult free()
			secondResult free()
		})
		this add("VectorList getElements", func {
			list := VectorList<Int> new()
			list add(0)
			list add(1)
			list add(2)
			list add(3)
			indices := VectorList<Int> new()
			indices add(1)
			indices add(2)
			newList := list getElements(indices)
			expect(newList count, is equal to(2))
			expect(newList[0], is equal to(1))
			expect(newList[1], is equal to(2))
			list free()
			indices free()
		})
		this add("VectorList apply and sort", func {
			list := VectorList<TestClass> new()
			list add(TestClass new(1))
			list add(TestClass new(3))
			list add(TestClass new(2))
			list sort(sortFuncClass)
			list free()
		})
		this add("VectorList pass by reference", func {
			list := VectorList<Int> new()
			list add(1)
			expect(passByRef(list&) == 1)
			list free()
		})
	}
}
VectorTest new() run()
