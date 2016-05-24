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
			heapVector := HeapVector<Int> new(10)
			expect(heapVector capacity, is equal to(10))
			expect(heapVector[0], is equal to(0))

			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(0))
			for (i in 0 .. 10)
				heapVector[i] = i
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(i))
			for (i in 0 .. 10)
				heapVector[i] = 10
			for (i in 0 .. 10)
				expect(heapVector[i], is equal to(10))

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

			heapVector resize(5)
			expect(heapVector capacity, is equal to(5))
			for (i in 0 .. 5)
				heapVector[i] = 5
			for (i in 0 .. 5)
				expect(heapVector[i], is equal to(5))

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
		this add("nested heap vector using cover", func {
			sizeX := 10
			sizeY := 10
			additionTable := HeapVector<Vector<MyCover>> new(sizeX, false)
			for (i in 0 .. sizeX) {
				additionTable[i] = HeapVector<MyCover> new(sizeY, false)
				for (j in 0 .. sizeY)
					additionTable[i][j] = MyCover new(i + j)
			}

			expect(additionTable[2][4] content, is equal to(6))
			additionTable[1][2] = MyCover new(12)
			expect(additionTable[1][2] content, is equal to(12))

			for (i in 0 .. sizeX)
				additionTable[i] free()
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

			expect(additionTable[2][4] content, is equal to(6))
			additionTable[1][2] content = 12
			expect(additionTable[1][2] content, is equal to(12))
			additionTable[1][2] increase()
			expect(additionTable[1][2] content, is equal to(13))

			for (i in 0 .. sizeX) {
				for (j in 0 .. sizeY)
					additionTable[i][j] free()
				additionTable[i] free()
			}
			additionTable free()
		})
	}
}

VectorTest new() run() . free()
