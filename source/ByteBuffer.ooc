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
import IDisposable

ByteBuffer: class implements IDisposable {
	size: Int
	pointer: UInt8*
	free: Func (This)
	init: func (=size, =pointer, =free)
	init: func ~fromSizeAndPointer (=size, =pointer) {
		this free = This recycle
	}
	init: func ~fromSize (=size) {
		pointer: UInt8* = 0
		bin := ArrayList<This> new()
		bin = This getBin(size);
		
		for(i in 0..bin size)
		{
			buffer := bin[i]
			if (buffer size == size) {
				pointer = bin[i] pointer
				bin removeAt(i)
				break
			}
		}
		if (!pointer) {
			pointer = gc_malloc(size);
		}
		this init(size, pointer, This recycle)
	}
	dispose: func {
		if ((free as Closure) thunk)
			this free(this)
	}
	recycle: static func (buffer: This) {
		This lock lock()
		bin := This getBin(buffer size)
		while (bin size > 10) {
			b := bin removeAt(0)
			gc_free(b pointer)
		}
		bin add(buffer)
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
}
