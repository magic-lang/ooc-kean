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
			expect(vector2D rowCount, is equal to(sizeM))
			expect(vector2D columnCount, is equal to(sizeM))
		})
		this add("get/set operators", func {
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(0))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * column
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(row * column))
			// Change all values to 10
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeM
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeM))
		})
		this add("resize increase", func {
			// Increase array size to 20x20
			vector2D resize(sizeXL, sizeXL)
			expect(vector2D rowCount, is equal to(sizeXL))
			expect(vector2D columnCount, is equal to(sizeXL))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * sizeXL + column
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(row * sizeXL + column))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeXL

			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeXL))
		})
		this add("resize decrease", func {
			// Resize back to original size
			vector2D resize(sizeL, sizeL)
			expect(vector2D rowCount, is equal to(sizeL))
			expect(vector2D columnCount, is equal to(sizeL))

			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeXL))

			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeL

			isNotTheValue := is not equal to(sizeL)
			for (row in 16 .. vector2D rowCount)
				for (column in 16 .. vector2D columnCount)
					expect(vector2D[row, column], isNotTheValue)
		})
		this add("resize decrease 2", func {
			// Decrease array size below original size
			vector2D resize(sizeS, sizeS)
			expect(vector2D rowCount, is equal to(sizeS))
			expect(vector2D columnCount, is equal to(sizeS))
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = sizeS
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(sizeS))
		})
		this add("move", func {
			// Move tests
			vector2D resize(sizeXS, sizeXS)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * column
			oldValue := vector2D[1, 1]
			vector2D move(1, 1, 0, 0)
			expect(vector2D[0, 0], is equal to(oldValue))

			vector2D resize(sizeL, sizeL)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D[row, column] = row * column

			vector2D resize(sizeXL, sizeXL)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					vector2D move(row, row, row + 1, row + 1)
			for (row in 0 .. vector2D rowCount)
				for (column in 0 .. vector2D columnCount)
					expect(vector2D[row, column], is equal to(0))
		})
	}
}
Vector2DTest new() run()
