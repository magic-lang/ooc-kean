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

Dictionary: class {
	_dictionaryList: Object*
	_capacity: Int

	init: func {
		init(10)
	}
	init: func ~withCapacity (=_capacity) {
		this _dictionaryList = gc_malloc((this _capacity as SizeT)*(Object size))
	}

	_insert: func (item: Object, index: Int) {
		if (item != null) {
			this _dictionaryList[index] = item
		}
	}

	add: func (key: Int, value: Object) -> This {
		copy := this clone()
		copy _insert(value, key)
		return copy
	}

	put: func (key: Int, value: Object) -> This {
		add(key, value)
	}

	remove: func (key: Int) -> Object {
		returnValue := get(key)
		this _dictionaryList[key] = null
		return returnValue
	}

	clone: func -> This {
		result := This new()
		memcpy(result _dictionaryList,this _dictionaryList,(this _capacity as SizeT)*(Object size))
		return result
	}

	merge: func (other: This) -> This {
		copy := this clone()
		for (i in 0..this _capacity) {
			copy _insert(other _dictionaryList[i], i)
		}
		return copy
	}

	get: func (key: Int) -> Object {
		return this _dictionaryList[key]
	}
	set: func (key: Int, value: Object) {
		this add(key, value)
	}

	__destroy__: func {
		gc_free(this _dictionaryList)
	}
}
