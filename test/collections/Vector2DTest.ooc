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
		this add("vecor2d list cover create", func {
			vector2d := Vector2D<Int> new(10, 10)
			expect(vector2d capacityRows, is equal to(10))
			expect(vector2d capacityColumns, is equal to(10))

			/*s: String
			println()
			for (i in 0..10) {
				s = ""
				for (j in 0..10) {
					s = s + vector2d[i, j] toString() + ", "
				}
				s println()
			}*/

			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2d[i, j], is equal to(0))
			for (i in 0 .. 10)
			  for (j in 0 .. 10)
				vector2d[i, j] = i*j
			for (i in 0 .. 10)
				for (j in 0 .. 10)
				expect(vector2d[i, j], is equal to(i*j))
			// Change all values to 10
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					vector2d[i, j] = 10
			for (i in 0 .. 10)
				for (j in 0 .. 10)
					expect(vector2d[i, j], is equal to(10))

			vector2d free()
		})
	}
}
Vector2DTest new() run()
