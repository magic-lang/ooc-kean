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
		sizeXS := 3
		sizeS := 5
		sizeM := 10
		sizeL := 15
		sizeXL := 20
		vector2D := Vector2D<Int> new(sizeM, sizeM)
		super("Vector2D")
		this add("capacity", func {
			expect(vector2D rowCapacity, is equal to(sizeM))
			expect(vector2D columnCapacity, is equal to(sizeM))
		})
		this add("get/set operators", func {
			for (i in 0 .. sizeM)
				for (j in 0 .. sizeM)
					expect(vector2D[i, j], is equal to(0))
			for (i in 0 .. sizeM)
				for (j in 0 .. sizeM)
					vector2D[i, j] = i * j
			for (i in 0 .. sizeM)
				for (j in 0 .. sizeM)
					expect(vector2D[i, j], is equal to(i * j))
			// Change all values to 10
			for (i in 0 .. sizeM)
				for (j in 0 .. sizeM)
					vector2D[i, j] = sizeM
			for (i in 0 .. sizeM)
				for (j in 0 .. sizeM)
					expect(vector2D[i, j], is equal to(sizeM))
		})
		this add("resize increase", func {
			// Increase array size to 20x20
			vector2D resize(sizeXL, sizeXL)
			expect(vector2D rowCapacity, is equal to(sizeXL))
			expect(vector2D columnCapacity, is equal to(sizeXL))
			for (i in 0 .. sizeXL)
				for (j in 0 .. sizeXL)
					vector2D[i, j] = i * sizeXL + j
			for (i in 0 .. sizeXL)
				for (j in 0 .. sizeXL)
					expect(vector2D[i, j], is equal to(i * sizeXL + j))
			for (i in 0 .. sizeXL)
				for (j in 0 .. sizeXL)
					vector2D[i, j] = sizeXL

			for (i in 0 .. sizeXL)
				for (j in 0 .. sizeXL)
					expect(vector2D[i, j], is equal to(sizeXL))
		})
		this add("resize decrease", func {
			// Resize back to original size
			vector2D resize(sizeL, sizeL)
			expect(vector2D rowCapacity, is equal to(sizeL))
			expect(vector2D columnCapacity, is equal to(sizeL))

			for (i in 0 .. sizeL)
				for (j in 0 .. sizeL)
					expect(vector2D[i, j], is equal to(sizeXL))

			for (i in 0 .. sizeL)
				for (j in 0 .. sizeL)
					vector2D[i, j] = sizeL

			isNotTheValue := is not equal to(sizeL)
			for (i in 16 .. sizeXL)
				for (j in 16 .. sizeXL)
					expect(vector2D[i, j], isNotTheValue)
		})
		this add("resize decrease 2", func {
			// Decrease array size below original size
			vector2D resize(sizeS, sizeS)
			expect(vector2D rowCapacity, is equal to(sizeS))
			expect(vector2D columnCapacity, is equal to(sizeS))
			for (i in 0 .. sizeS)
				for (j in 0 .. sizeS)
					vector2D[i, j] = sizeS
			for (i in 0 .. sizeS)
				for (j in 0 .. sizeS)
					expect(vector2D[i, j], is equal to(sizeS))
		})
		this add("move", func {
			// Move tests
			vector2D resize(sizeXS, sizeXS)
			for (i in 0 .. sizeXS)
				for (j in 0 .. sizeXS)
					vector2D[i, j] = i * j
			oldValue := vector2D[1, 1]
			vector2D move(1, 1, 0, 0)
			expect(vector2D[0, 0], is equal to(oldValue))

			vector2D resize(sizeL, sizeL)
			for (i in 0 .. sizeL)
				for (j in 0 .. sizeL)
					vector2D[i, j] = i * j

			vector2D resize(sizeXL, sizeXL)
			for (i in 0 .. sizeL)
				for (j in 0 .. sizeL)
					vector2D move(i, i, i + 1, i + 1)
			for (i in 0 .. sizeL)
				for (j in 0 .. sizeL)
					expect(vector2D[i, j], is equal to(0))
		})
	}
}
Vector2DTest new() run()
