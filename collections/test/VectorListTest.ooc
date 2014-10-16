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
	init: func() {
		super("VectorList")
		this add("VectorList cover create", func() {

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

			for (i in 0..vectorList count)
				vectorList remove()
			expect(vectorList count, is equal to(0))

			for (i in 0..10)
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

		})
	}
}
VectorTest new() run()
