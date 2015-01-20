//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.
use ooc-math
GraphicBuffer: class {
	_allocate: static Func (Int, Int, Bool, Bool, Pointer*, Pointer*, Int*)
	_free: static Func (Pointer)
	_lock: static Func (Pointer, Bool, Pointer*)
	_unlock: static Func (Pointer)

	_size: IntSize2D
	size ::= this _size
	_stride: Int
	stride ::= this _stride
	_backend: Pointer = null
	_nativeBuffer: Pointer = null
	nativeBuffer ::= this _nativeBuffer
	init: func (=_size, read: Bool, write: Bool) {
		This _allocate(_size width, _size height, read, write, this _backend&, this _nativeBuffer&, this _stride&)
	}
	free: func { This _free(this _backend) }
	lock: func (write: Bool) -> Pointer {
		result: Pointer = null
		This _lock(this _backend, write, result&)
		result
	}
	unlock: func {
		This _unlock(this _backend)
	}
	initialize: static func (allocate: Func (Int, Int, Bool, Bool, Pointer*, Pointer*, Int*), free: Func (Pointer),
	lock: Func (Pointer, Bool, Pointer*), unlock: Func (Pointer)) {
		This _allocate = allocate
		This _free = free
		This _lock = lock
		This _unlock = unlock
	}
}
