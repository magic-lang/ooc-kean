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

SortedVectorTest: class extends Fixture {

	init: func() {
		super("SortedVectorList")
		this add("SortedVectorList cover create", func() {


			sortedVectorList := SortedVectorList<Int> new() as SortedVectorList<Int>
			sortedVectorList readCompareValuesFunctionPointer(compareValues)
			expect(sortedVectorList count, is equal to(0))
			sortedVectorList add(6)
			sortedVectorList add(9)
			sortedVectorList add(2)
			sortedVectorList add(5)
			sortedVectorList add(1)
			sortedVectorList add(3)
			sortedVectorList add(7)
			sortedVectorList add(8)
			sortedVectorList add(0)
			sortedVectorList add(4)
			expect(sortedVectorList count, is equal to(10))
			for (i in 0..sortedVectorList count)
				expect(sortedVectorList[i]  < i+1)

			sortedVectorList remove()
			sortedVectorList remove()
			sortedVectorList remove()
			sortedVectorList remove()
			expect(sortedVectorList count, is equal to(6))
			for (i in 0..sortedVectorList count)
				expect(sortedVectorList[i]  < i+1)


			sortedVectorList add(6)
			sortedVectorList add(8)
			sortedVectorList add(7)
			expect(sortedVectorList count, is equal to(9))
			for (i in 0..sortedVectorList count)
				expect(sortedVectorList[i]  < i+1)

			sortedVectorList remove(5)
			expect(sortedVectorList count, is equal to(8))
			for (i in 0..sortedVectorList count)
				expect(sortedVectorList[i]  < i+1)

			sortedVectorList insert(3, 6)
			expect(sortedVectorList count, is equal to(9))
			for (i in 0..sortedVectorList count)
				expect(sortedVectorList[i]  < i+1)
		})
	}

	compareValues := func (firstValue: Cell<Int>, secondValue: Cell<Int>) -> Bool {
		first := firstValue[Int]
		second := secondValue[Int]
		first > second
	}
}
SortedVectorTest new() run()
