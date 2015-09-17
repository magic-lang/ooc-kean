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

Vector2DTest: class extends Fixture {
	init: func {
		super("Vector2D")
		this add("vector2d list cover create", func {
			vector2D := Vector2D<Int> new(10, 10)
			expect(vector2D rowCapacity, is equal to(10))
			expect(vector2D columnCapacity, is equal to(10))

			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2D[i, j], is equal to(0))
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					vector2D[i, j] = i * j
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2D[i, j], is equal to(i * j))
			// Change all values to 10
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					vector2D[i, j] = 10
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2D[i, j], is equal to(10))

			// Increase array size to 20x20
			vector2D resize(20, 20)
			expect(vector2D rowCapacity, is equal to(20))
			expect(vector2D columnCapacity, is equal to(20))
			for (i in 0 .. 20)
				for (j in 0 .. 20)
					vector2D[i, j] = i * 20 + j
			for (i in 0 .. 20)
				for (j in 0 .. 20)
					expect(vector2D[i, j], is equal to(i * 20 + j))
			for (i in 0 .. 20)
				for (j in 0 .. 20)
					vector2D[i, j] = 20

			for (i in 0 .. 20)
				for (j in 0 .. 20)
					expect(vector2D[i, j], is equal to(20))
			vector2D resize(15, 15)
			expect(vector2D rowCapacity, is equal to(15))
			expect(vector2D columnCapacity, is equal to(15))

			for (i in 0 .. 15)
				for (j in 0 .. 15)
					expect(vector2D[i, j], is equal to(20))

			for (i in 0 .. 15)
				for (j in 0 .. 15)
					vector2D[i, j] = 15

			isNotTheValue := is not equal to(15)
			for (i in 16 .. 20)
				for (j in 16 .. 20)
					expect(vector2D[i, j], isNotTheValue)

			// Decrease array size below original size
			vector2D resize(5, 5)
			expect(vector2D rowCapacity, is equal to(5))
			expect(vector2D columnCapacity, is equal to(5))
			for (i in 0 .. 5)
				for (j in 0 .. 5)
					vector2D[i, j] = 5
			for (i in 0 .. 5)
				for (j in 0 .. 5)
					expect(vector2D[i, j], is equal to(5))

			// Copy tests
			vector2D resize(3, 3)
			for (i in 0 .. 3)
				for (j in 0 .. 3)
					vector2D[i, j] = i
			oldValue := vector2D[1, 1]
			vector2D move(1, 1, 0, 0)
			expect(vector2D[0, 0], is equal to(oldValue))

			vector2D resize(10, 10)
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					vector2D[i, j] = i * j

			vector2D resize(20, 20)
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					vector2D move(i, i, i + 1, i + 1)
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2D[i, j], is equal to(0))

			vector2D free()
		})
	}
}
Vector2DTest new() run()
