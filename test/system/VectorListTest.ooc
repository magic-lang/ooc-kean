/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use collections

_TestCover: cover {
	_value: Int
	value ::= this _value
	init: func@ (=_value)
}

VectorListTest: class extends Fixture {
	staticlist: static VectorList<Int>
	count: static Int = 0
	init: func {
		super("VectorList")
		tolerance := 0.00001f
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
			(firstList, secondList) free()
		})
		this add("VectorList getFirstElements", func {
			list := VectorList<Int> new()
			list add(0) . add(1) . add(2)

			firstResult := list getFirstElements(2)
			secondResult := firstResult getFirstElements(5)
			expect(secondResult count, is equal to(2))
			expect(secondResult[0], is equal to(0))
			expect(secondResult[1], is equal to(1))
			(list, firstResult, secondResult) free()
		})
		this add("VectorList getElements", func {
			list := VectorList<Int> new()
			list add(0) . add(1) . add(2) . add(3)

			indices := VectorList<Int> new()
			indices add(1)
			indices add(2)
			newList := list getElements(indices)
			expect(newList count, is equal to(2))
			expect(newList[0], is equal to(1))
			expect(newList[1], is equal to(2))
			(list, indices, newList) free()
		})
		this add("VectorList getSlice", func {
			list := VectorList<Float> new()
			list add(1.0f)
			list add(2.0f)
			list add(3.0f)
			list add(4.0f)
			slice := list getSlice(1, 2)
			expect(slice count, is equal to(2))
			expect(slice[0], is equal to(2.0f) within(tolerance))
			expect(slice[1], is equal to(3.0f) within(tolerance))
			sliceInto := VectorList<Float> new()
			list getSliceInto(Range new(1, 2), sliceInto)
			expect(sliceInto[0], is equal to(2.0f) within(tolerance))
			expect(sliceInto[1], is equal to(3.0f) within(tolerance))
			(list, slice, sliceInto) free()
		})
		this add("VectorList apply", func {
			This staticlist = VectorList<Int> new()
			This staticlist add(0) . add(1) . add(2)
			This staticlist apply(This _applyTester)
			This staticlist free()
		})
		this add("VectorList modify", func {
			list := VectorList<Int> new()
			list add(0) . add(1) . add(2)

			list modify(|value| value += 1)
			for (index in 0 .. list count)
				expect(list[index], is equal to(index + 1))
			list free()
		})
		this add("VectorList map", func {
			list := VectorList<Int> new()
			list add(0) . add(1) . add(2)

			newList := list map(|value| (value + 1) toString())
			expect(list count, is equal to(newList count))
			expect(newList[0], is equal to("1"))
			expect(newList[1], is equal to("2"))
			expect(newList[2], is equal to("3"))
			(list, newList) free()
		})
		this add("VectorList reverse", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(64) . add(128)

			reversed := list reverse()
			expect(reversed[0], is equal to(128))
			expect(reversed[1], is equal to(64))
			expect(reversed[2], is equal to(16))
			expect(reversed[3], is equal to(8))
			(list, reversed) free()
		})
		this add("VectorList removeAt", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(32) . add(64)

			expect(list empty, is false)
			while (!list empty)
				list removeAt(0)
			expect(list empty, is true)
			list free()
		})
		this add("VectorList removeAt~range", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(32) . add(64)
			list removeAt(0, 0)
			expect(list count, is equal to(4))
			expect(list empty, is false)
			list removeAt(1 .. 3)
			expect(list empty, is false)
			expect(list count, is equal to(2))
			expect(list[0], is equal to(8))
			expect(list[1], is equal to(64))
			list removeAt(0 .. 2)
			expect(list empty, is true)
			list free()
		})
		this add("VectorList direct vector access", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(32)

			point := list pointer as Int*
			expect(point[0], is equal to(list[0]))
			expect(point[1], is equal to(list[1]))
			expect(point[2], is equal to(list[2]))
			list free()
		})
		this add("VectorList sort", func {
			list := VectorList<Int> new()
			list add(32) . add(16) . add(8)

			sortedList := list copy()
			sortedList sort(|v1, v2| v1 < v2)
			count := list count
			iterator := sortedList iterator()
			for (value in iterator) {
				count -= 1
				expect(value, is equal to(list[count]))
			}
			(list, sortedList, iterator) free()
		})
		this add("VectorList fold", func {
			list := VectorList<Int> new()
			list add(1) . add(2) . add(3)
			sum := list fold(Int, |v1, v2| v1 + v2, 0)
			expect(sum, is equal to(6))
			list free()
		})
		this add("Iterator correct", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(32)

			iterator := list iterator()
			expect(iterator hasNext(), is true)
			for ((index, item) in iterator)
				expect(item, is equal to(list[index]))
			expect(iterator hasNext(), is false)
			secondIterator := list iterator()
			expect(secondIterator next(), is equal to(8))
			(secondIterator, iterator, list) free()

			// Note: This is convenient, but leaks the iterator instance.
			// for ((index, item) in list)
			// 	expect(item, is equal to(list[index]))
		})
		this add("VectorList search", This _testVectorListSearch)
		this add("VectorList bound search", This _testVectorListBoundSearch)
	}
	_testVectorListSearch: static func {
		list := VectorList<Int> new()
		expect(list search(|instance| 1 == instance), is equal to(-1))
		for (i in 0 .. 10)
			list add(i)
		expect(list search(|instance| 1 == instance), is equal to(1))
		expect(list search(|instance| 9 == instance), is equal to(9))
		expect(list search(|instance| 10 == instance), is equal to(-1))
		list free()
	}
	_testVectorListBoundSearch: static func {
		intList := VectorList<Int> new()
		intList add(10) . add(10) . add(10) . add(20) . add(20) . add(20) . add(30) . add(30)
		unorderedList := VectorList<Int> new()
		unorderedList add(2) . add(23) . add(-1)
		intComparator := func (first, second: Int*) -> Bool {
			first@ < second@
		}
		intToCompare := 20
		expect(intList isSorted(0, intList count, intComparator), is true)
		expect(unorderedList isSorted(0, unorderedList count, intComparator), is false)
		expect(intList lowerBound(0, intList count, 40, intComparator), is equal to(-1))
		expect(intList upperBound(0, intList count, 40, intComparator), is equal to(intList count))
		expect(intList lowerBound(0, intList count, intToCompare, intComparator), is equal to(3))
		expect(intList upperBound(0, intList count, intToCompare, intComparator), is equal to(6))
		(intList, unorderedList, intComparator as Closure) free()

		stringList := VectorList<String> new()
		stringList add("a") . add("a") . add("b") . add("ab") . add("ba") . add("bb") .add("ccc") . add("ddd")
		stringComparator := func (first, second: String*) -> Bool {
			first@ size < second@ size
		}
		stringToCompare := "aa"
		stringNotFound := "I'm too long"
		expect(stringList isSorted(0, stringList count, stringComparator), is true)
		expect(stringList lowerBound(0, stringList count, stringNotFound, stringComparator), is equal to(-1))
		expect(stringList upperBound(0, stringList count, stringNotFound, stringComparator), is equal to(stringList count))
		expect(stringList lowerBound(0, stringList count, stringToCompare, stringComparator), is equal to(3))
		expect(stringList upperBound(0, stringList count, stringToCompare, stringComparator), is equal to(6))
		(stringList, stringToCompare, stringNotFound, stringComparator as Closure) free()

		coverList := VectorList<_TestCover> new()
		coverList add(_TestCover new(1)) . add(_TestCover new(1)) . add(_TestCover new(1)) . add(_TestCover new(2))
		coverList add(_TestCover new(2)) . add(_TestCover new(2)) . add(_TestCover new(3)) . add(_TestCover new(3))
		coverComparator := func (first, second: _TestCover*) -> Bool {
			first@ value < second@ value
		}
		expect(coverList isSorted(0, coverList count, coverComparator), is true)
		coverToCompare := _TestCover new(2)
		coverNotFound := _TestCover new(10)
		expect(coverList lowerBound(0, coverList count, coverNotFound, coverComparator), is equal to(-1))
		expect(coverList upperBound(0, coverList count, coverNotFound, coverComparator), is equal to(coverList count))
		expect(coverList lowerBound(0, coverList count, coverToCompare, coverComparator), is equal to(3))
		expect(coverList upperBound(0, coverList count, coverToCompare, coverComparator), is equal to(6))
		(coverList, coverComparator as Closure) free()
	}
	_applyTester: static func (index: Int*) { expect(This staticlist[index@], is equal to(index@)) }
}

VectorListTest new() run() . free()
