/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit

MyCover: cover {
	content: Int
	init: func@ (=content)
	init: func@ ~default { this init(0) }
	increase: func { this content += 1 }
}
MyClass: class {
	content: Int
	init: func (=content)
	init: func ~default { this init(0) }
	increase: func { this content += 1 }
}

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

			// Decrease array size below original size
			heapVector resize(5)
			expect(heapVector capacity, is equal to(5))
			for (i in 0 .. 5)
				heapVector[i] = 5
			for (i in 0 .. 5)
				expect(heapVector[i], is equal to(5))

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

		/* Activate test when [] supports references.
		this add("cover by reference in heap vector", func {
			heapVector := HeapVector<MyCover> new(3) as Vector<MyCover>
			// Test default value
			expect(heapVector capacity, is equal to(3))
			expect(heapVector[0] content, is equal to(0))
			// Test assignment by value
			heapVector[2] = MyCover new(3)
			expect(heapVector[2] content, is equal to(3))
			// Test side effects by reference
			// This test requires the [] operands to pass pointers instead of values.
			// It is dangerous to reallocate a collection while pointers are referring
			// directly to the allocation since resizing will free the memory.
			// If you need a persistent pointer to cover element or a flat subset of the
			// element within the same allocation, you must put each cover in a cell.
			heapVector[2] increase()
			expect(heapVector[2] content, is equal to(4))
			heapVector free()
		})
		*/

		this add("nested heap vector using cover", func {
			sizeX := 10
			sizeY := 10
			additionTable := HeapVector<Vector<MyCover>> new(sizeX, false)
			for (i in 0 .. sizeX) {
				additionTable[i] = HeapVector<MyCover> new(sizeY, false)
				for (j in 0 .. sizeY)
					additionTable[i][j] = MyCover new(i + j)
			}
			// Array access requires casting to the correct type when a collection holds a generic collection
			// 2 + 4 = 6
			expect((additionTable[2] as Vector<MyCover>)[4] content, is equal to(6))
			// Write that 1 + 2 = 12 just to confuse
			// Since the [] operator can't give a reference to the content attribute, the whole cover must be replaced.
			(additionTable[1] as Vector<MyCover>)[2] = MyCover new(12)
			// Confirm that 1 + 2 = 12 according to the new logic
			expect((additionTable[1] as Vector<MyCover>)[2] content, is equal to(12))
			additionTable free()
		})

		this add("nested heap vector using class", func {
			sizeX := 10
			sizeY := 10
			additionTable := HeapVector<Vector<MyClass>> new(sizeX)
			for (i in 0 .. sizeX) {
				additionTable[i] = HeapVector<MyClass> new(sizeY)
				for (j in 0 .. sizeY)
					additionTable[i][j] = MyClass new(i + j)
			}
			// Array access requires casting to the correct type when a collection holds a generic collection
			// 2 + 4 = 6
			expect((additionTable[2] as Vector<MyClass>)[4] content, is equal to(6))
			// Write that 1 + 2 = 12 just to confuse
			(additionTable[1] as Vector<MyClass>)[2] content = 12
			// Confirm that 1 + 2 = 12 according to the new logic
			expect((additionTable[1] as Vector<MyClass>)[2] content, is equal to(12))
			// Increase the value of 1 + 2 to 13
			(additionTable[1] as Vector<MyClass>)[2] increase()
			// Confirm that 1 + 2 = 13 according to the new logic
			expect((additionTable[1] as Vector<MyClass>)[2] content, is equal to(13))
			additionTable free()
		})
	}
}

VectorTest new() run() . free()
