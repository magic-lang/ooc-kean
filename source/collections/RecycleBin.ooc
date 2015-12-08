/*
* Copyright (C) 2015 - Simon Mika <simon@mika.se>
*
* This sofware is free software; you can redistribute it and/or
* modify it under the terms of the GNU Lesser General Public
* License as published by the Free Software Foundation; either
* version 2.1 of the License, or (at your option) any later version.
*
* This software is distributed in the hope that it will be useful,
* but WITHOUT ANY WARRANTY; without even the implied warranty of
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with This software. If not, see <http://www.gnu.org/licenses/>.
*/
import threading/Mutex

RecycleBin: class <T> {
	_mutex := Mutex new()
	_free: Func (T)
	//TODO: Replace with SynchronizedVectorList
	_list: VectorList<T>
	_size: Int
	init: func (=_size, =_free) { this _list = VectorList<T> new(_size) }
	free: override func {
		this clear()
		this _list free()
		this _mutex free()
		super()
	}
	add: func (object: T) {
		this _mutex lock()
		if (this _list count == this _size)
			this _free(this _list remove(0))
		this _list add(object)
		this _mutex unlock()
	}
	search: func (matches: Func (T) -> Bool) -> T {
		result: T = null
		this _mutex lock()
		for (i in 0 .. this _list count) {
			if (matches(this _list[i])) {
				result = this _list remove(i)
				break
			}
		}
		this _mutex unlock()
		(matches as Closure) free()
		result
	}
	clear: func {
		this _mutex lock()
		for (i in 0 .. this _list count)
			this _free(this _list remove())
		this _mutex unlock()
	}
}
