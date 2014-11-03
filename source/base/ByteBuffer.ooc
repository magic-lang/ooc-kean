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
* MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
* Lesser General Public License for more details.
*
* You should have received a copy of the GNU Lesser General Public License
* along with this software. If not, see <http://www.gnu.org/licenses/>.
*/

import lang/Memory
import structs/FreeArrayList
import threading/Thread

ByteBuffer: class {
	size: Int
	pointer: UInt8*
	destroy: Func (This)
	init: func (=size, =pointer, =destroy)
	init: func ~fromSizeAndPointer (=size, =pointer) {
		this destroy = This recycle
	}
	new: static func ~fromSize (size: Int) -> This {
		bin := This getBin(size)
		buffer: This
		for(i in 0..bin size)
		{
			buffer = bin[i]
			if ((buffer size) == size) {
				bin removeAt(i, false)
				break
			} else {
				buffer = null
			}
		}
		if (buffer == null) {
			pointer: UInt8* = gc_malloc_atomic(size);
			This new(size, pointer, This recycle)
		} else {
			buffer
		}
	}
	__destroy__: func {
		if ((destroy as Closure) thunk) {
			this destroy(this)
		} else {
			raise("Wtf, no thunk?")
		}
	}
	__delete__: func {
		gc_free(this pointer)
		gc_free(this)
	}
	
	free: func {
		this __destroy__()
	}
	
	recycle: static func (buffer: This) {
		This lock lock()
		bin := This getBin(buffer size)
		while (bin size > 10) {
			b := bin get(0)
			bin removeAt(0, false)
			b __delete__()
		}
		bin add(buffer)
		This lock unlock()
	}
	getBin: static func (size: Int) -> FreeArrayList<This> {
		if (size < 10000)
			This smallRecycleBin
		else if (size < 100000)
			This mediumRecycleBin
		else
			This largeRecycleBin
//		size < 10000 ? This smallRecycleBin : size < 100000 ? This mediumRecycleBin : This largeRecycleBin
	}
	copy: func -> This {
		result := This new(this size)
		memcpy(result pointer, this pointer, this size)
		result
	}
	copyFrom: func (other: This, start, destination, length: Int) {
		a := this as UInt8*
		b := other as UInt8*
		memcpy(a + destination, b + start, length)
	}

	lock := static Mutex new()
	smallRecycleBin := static FreeArrayList<This> new()
	mediumRecycleBin := static FreeArrayList<This> new()
	largeRecycleBin := static FreeArrayList<This> new()
	clean := static func {
		while (This smallRecycleBin size > 0) {
			b := This smallRecycleBin get(0)
			This smallRecycleBin removeAt(0, false)
			b __delete__()
		}
		gc_free(This smallRecycleBin data)
		gc_free(This smallRecycleBin)
		while (This mediumRecycleBin size > 0) {
			b := This mediumRecycleBin get(0)
			This mediumRecycleBin removeAt(0, false)
			b __delete__()
		}
		gc_free(This mediumRecycleBin data)
		gc_free(This mediumRecycleBin)
		while (This largeRecycleBin size > 0) {
			b := This largeRecycleBin get(0)
			This largeRecycleBin removeAt(0, false)
			b __delete__()
		}
		gc_free(This largeRecycleBin data)
		gc_free(This largeRecycleBin)
	}
}
