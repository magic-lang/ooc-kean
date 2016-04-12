/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use collections

VectorListTest: class extends Fixture {
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
			list add(0)
			list add(1)
			list add(2)
			firstResult := list getFirstElements(2)
			secondResult := firstResult getFirstElements(5)
			expect(secondResult count, is equal to(2))
			expect(secondResult[0], is equal to(0))
			expect(secondResult[1], is equal to(1))
			(list, firstResult, secondResult) free()
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
			list free()
			slice free()
			sliceInto free()
		})
		this add("VectorList apply", func {
			list := VectorList<Int> new()
			list add(0)
			list add(1)
			list add(2)
			c := 0
			list apply(|value|
				expect(value, is equal to(c))
				c += 1)
			list free()
		})
		this add("VectorList modify", func {
			list := VectorList<Int> new()
			list add(0)
			list add(1)
			list add(2)

			list modify(|value| value += 1)
			c := 1
			list apply(|value|
				expect(value, is equal to(c))
				c += 1)
			list free()
		})
		this add("VectorList map", func {
			list := VectorList<Int> new()
			list add(0)
			list add(1)
			list add(2)
			newList := list map(|value| (value + 1) toString())
			expect(list count, is equal to(newList count))
			expect(newList[0], is equal to("1"))
			expect(newList[1], is equal to("2"))
			expect(newList[2], is equal to("3"))
			(list, newList) free()
		})
		this add("VectorList reverse", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(64)
			list add(128)
			reversed := list reverse()
			expect(reversed[0], is equal to(128))
			expect(reversed[1], is equal to(64))
			expect(reversed[2], is equal to(16))
			expect(reversed[3], is equal to(8))
			list free()
			reversed free()
		})
		this add("VectorList remove", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(32)
			list add(64)
			expect(list empty, is false)
			while (!list empty)
				list removeAt(0)
			expect(list empty, is true)
			list free()
		})
		this add("VectorList direct vector access", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(32)
			point := list pointer as Int*
			expect(point[0], is equal to(list[0]))
			expect(point[1], is equal to(list[1]))
			expect(point[2], is equal to(list[2]))
			list free()
		})
		this add("VectorList sort", func {
			list := VectorList<Int> new()
			list add(8) . add(16) . add(32)
			sortedList := list copy()
			sortedList sort(|v1, v2| v1 < v2)
			count := list count
			for (value in sortedList) {
				count -= 1
				expect(value, is equal to(list[count]))
			}
		})
		this add("VectorList fold", func {
			list := VectorList<Int> new()
			list add(1) . add(2) . add(3)
			sum := list fold(Int, |v1, v2| v1 + v2, 0)
			expect(sum, is equal to(6))
		})
		this add("Iterator leak", func {
			list := VectorList<Int> new()
			list add(1)
			list add(2)
			list add(4)
			// Convenient, but leaks the iterator instance.
			for ((index, item) in list)
				expect(item, is equal to(list[index]))
			list free()
		})
		this add("Iterator correct", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(32)
			iterator := list iterator()
			expect(iterator hasNext(), is true)
			for ((index, item) in iterator)
				expect(item, is equal to(list[index]))
			expect(iterator hasNext(), is false)
			secondIterator := list iterator()
			expect(secondIterator next(), is equal to(8))
			secondIterator free()
			iterator free()
			list free()
		})
		this add("VectorList search", This _testVectorListSearch)
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
}

VectorListTest new() run() . free()
