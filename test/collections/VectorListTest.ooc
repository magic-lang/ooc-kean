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

VectorListTest: class extends Fixture {
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
		this add("VectorList getSlice", func {
			list := VectorList<Float> new()
			list add(1.0f)
			list add(2.0f)
			list add(3.0f)
			list add(4.0f)
			slice := list getSlice(1, 2)
			expect(slice count == 2)
			expect(slice[0] == 2.0f)
			expect(slice[1] == 3.0f)
			sliceInto := VectorList<Float> new()
			list getSliceInto(Range new(1, 2), sliceInto)
			expect(sliceInto[0] == 2.0f)
			expect(sliceInto[1] == 3.0f)
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
			list free(); newList free()
		})
		this add("VectorList reverse", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(64)
			list add(128)
			reversed := list reverse()
			expect(reversed[0] == 128)
			expect(reversed[1] == 64)
			expect(reversed[2] == 16)
			expect(reversed[3] == 8)
			list free()
			reversed free()
		})
		this add("VectorList remove", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(32)
			list add(64)
			expect(list empty, is equal to(false))
			while (!list empty) {
				list removeAt(0)
			}
			expect(list empty, is equal to(true))
			list free()
		})
		this add("VectorList direct vector access", func {
			list := VectorList<Int> new()
			list add(8)
			list add(16)
			list add(32)
			point := list pointer as Int*
			expect(point[0] == list[0])
			expect(point[1] == list[1])
			expect(point[2] == list[2])
		})
		this add("VectorList sort", func {
			//TODO Current way of sorting not supported by Rock
		})
		this add("VectorList fold", func {
			//TODO Current way of folding not supported by Rock
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
			expect(iterator hasNext?(), is equal to(true))
			for ((index, item) in iterator)
				expect(item, is equal to(list[index]))
			expect(iterator hasNext?(), is equal to(false))			
			secondIterator := list iterator()
			expect(secondIterator next(), is equal to(8))			
			iterator free()
			list free()
		})
	}
}
VectorListTest new() run()
