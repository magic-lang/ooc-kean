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
import structs/ArrayList
import threading/Thread

ByteBuffer: class {
	size: Int
	pointer: UInt8*
	destroy: Func (This)
	init: func (=size, =pointer, =destroy)
	init: func ~fromSizeAndPointer (=size, =pointer) {
		this destroy = This recycle
	}
	init: func ~fromSize (=size) {
		pointer: UInt8* = 0
		bin := This getBin(size);
		buffer: This
		for(i in 0..bin size)
		{
//			"we need buffer of size " print()
//			this size toString() println()
//			"now at element " print()
//			i toString() print()
//			" in bin" println()
			buffer = bin[i] // leak
//			"buffer is " print()
//			if (buffer == null)
//				"null" println()
//			else {
//				bSize: Int = buffer size
//				bSize toString() println()
//			}
			if ((buffer size) == size) {
//				"old buffer found" println()
				bin removeAt(i) // leak
				break
			} else {
				buffer = null // leak
			}
		}
		if (buffer == null) {
			pointer = gc_malloc(size);
//			"new buffer" println()
			this init(size, pointer, This recycle)
		} else {
//			"reusing buffer" println()
			this init(size, buffer pointer, This recycle)
		}
	}
	__destroy__: func {
//		"destroying buffer" println()
		if ((destroy as Closure) thunk)
			this destroy(this)
	}
	__delete__: func {
		gc_free(this pointer)
//		"deleting buffer" println()
		gc_free(this)
	}
	
	free: func {
//		"freeing buffer" println()
		version(!gc) {
			this __destroy__()
		}
	}
	
	recycle: static func (buffer: This) {
		This lock lock()
		bin := This getBin(buffer size)
		while (bin size > 10) {
			b := bin removeAt(0)
			b __delete__()
		}
//		bin size toString() println()
		bin add(buffer)
//		"recycling buffer of size " print()
//		buffer size toString() println()
//		bin size toString() println()
		
		This lock unlock()
	}
	getBin: static func (size: Int) -> ArrayList<This> {
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
	smallRecycleBin := static ArrayList<This> new()
	mediumRecycleBin := static ArrayList<This> new()
	largeRecycleBin := static ArrayList<This> new()
	clean := static func {
//		while (This smallRecycleBin size > 0) {
//			b := This smallRecycleBin removeAt(0)
//			gc_free(b pointer)
//			gc_free(b)
//		}
//		gc_free(This smallRecycleBin data)
//		gc_free(This smallRecycleBin)
//		while (This mediumRecycleBin size > 0) {
//			b := This mediumRecycleBin removeAt(0)
//			gc_free(b pointer)
//			gc_free(b)
//		}
//		gc_free(This mediumRecycleBin data)
//		gc_free(This mediumRecycleBin)
//		while (This largeRecycleBin size > 0) {
//			b := This largeRecycleBin removeAt(0)
//			gc_free(b pointer)
//			gc_free(b)
//		}
//		gc_free(This largeRecycleBin data)
//		gc_free(This largeRecycleBin)
	}
}
