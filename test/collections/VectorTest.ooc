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

VectorTest: class extends Fixture {
	init: func {
		super("Vector")
		this add("heap cover create", func {
			heapVector := HeapVector<Int> new(10) as Vector<Int>
			expect(heapVector capacity, is equal to(10))
			expect(heapVector[0], is equal to(0))

			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(0))
			for (i in 0 .. 10)
			// Insert 0 .. 10
				heapVector[i] = i
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(i))
			// Change all values to 10
			for (i in 0 .. 10)
				heapVector[i] = 10
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(10))

			// Increase array size to 20
			heapVector resize(20)
			expect(heapVector capacity, is equal to(20))
			for (i in 0 .. 20)
				heapVector[i] = i
			for (i in 0 .. 20)
				expect(heapVector[i], is equal to(i))
			for (i in 0 .. 20)
				heapVector[i] = 20

			for (i in 0 .. 20)
				expect(heapVector[i], is equal to(20))
			heapVector resize(15)
			expect(heapVector capacity, is equal to(15))

			for (i in 0 .. 15)
				expect(heapVector[i], is equal to(20))

			for (i in 0 .. 15)
				heapVector[i] = 15

			isNotTheValue := is not equal to(15)
			for (i in 16 .. 20)
				expect(heapVector[i], isNotTheValue)

			// Decrease array size below original size
			heapVector resize(5)
			expect(heapVector capacity, is equal to(5))
			for (i in 0 .. 5)
				heapVector[i] = 5
			for (i in 0 .. 5)
				expect(heapVector[i], is equal to(5))
			isNotTheValue = is not equal to(5)
			for (i in 6 .. 20)
				expect(heapVector[i], isNotTheValue)

			// Copy tests
			heapVector resize(3)
			for (i in 0 .. 3)
				heapVector[i] = i
			oldValue := heapVector[1]
			heapVector copy(1, 0)
			expect(heapVector[0], is equal to(oldValue))

			heapVector resize(10)
			for (i in 0 .. 10)
				heapVector[i] = i
			heapVector resize(20)
			for (i in 0 .. 10)
				heapVector copy(i, i + 1)
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(0))

			// Move tests
			heapVector resize(3)
			for (i in 0 .. 3)
				heapVector[i] = i
			oldValue = heapVector[1]
			heapVector move(1, 0)
			expect(heapVector[0], is equal to(oldValue))

			heapVector resize(10)
			for (i in 0 .. 10)
				heapVector[i] = i
			heapVector resize(20)
			for (i in 0 .. 10)
				heapVector move(i, i + 1)
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(0))

			heapVector free()

		})

		this add("Stack cover create", func {
			dataTMP: Int[30]
			data := dataTMP[0]&

			//stackVector := StackVector<Int> new(data[0]&, 10) as Vector<Int>
			stackVector := StackVector<Int> new(data, 30) as Vector<Int>

			expect(stackVector capacity, is equal to(30))
			for (i in 0 .. stackVector capacity)
				stackVector[i] = i
			// Test case for 0 .. 30
			for (i in 0 .. 30)
				expect(stackVector[i], is equal to(i))

			// Insert 30 in every element of array
			for (i in 0 .. 30)
				stackVector[i] = 30
			for (i in 0 .. 30)
				expect(stackVector[i], is equal to(30))

			// Decrease array size to 20
			stackVector resize(20)
			expect(stackVector capacity, is equal to(20))

			// Insert 0 .. 20
			for (i in 0 .. 20)
					stackVector[i] = i
			for (i in 0 .. 20)
				expect(stackVector[i], is equal to(i))
			// Change all values to 20
			for (i in 0 .. 20)
				stackVector[i] = 20
			for (i in 0 .. 20)
				expect(stackVector[i], is equal to(20))
			// Test if elements above size=20 also changed
			isNotTheValue := is not equal to(20)
			for (i in 21 .. 30)
				expect(stackVector[i], isNotTheValue)

			stackVector resize(40)

			expect(stackVector capacity, is equal to(20))
			stackVector resize(10)
			expect(stackVector capacity, is equal to(10))
			stackVector resize(14)
			expect(stackVector capacity, is equal to(10))
			for (i in 0 .. 10)
				stackVector[i] = 10
			for (i in 0 .. 10)
				expect(stackVector[i], is equal to(10))
			isNotTheValue = is not equal to(10)
			for (i in 11 .. 30)
				expect(stackVector[i], isNotTheValue)

			// Copy tests
			stackVector resize(3)
			for (i in 0 .. 3)
				stackVector[i] = i
			oldValue := stackVector[1]
			stackVector copy(1, 0)
			expect(stackVector[0], is equal to(oldValue))

			// Move tests
			stackVector resize(3)
			for (i in 0 .. 3)
				stackVector[i] = i
			oldValue = stackVector[1]
			stackVector move(1, 0)
			expect(stackVector[0], is equal to(oldValue))

			stackVector free()

		})

	}
}
VectorTest new() run()
