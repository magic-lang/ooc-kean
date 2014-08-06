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

Buffer: class {
	size: Int
	pointer: Pointer
	free: Func (Buffer)
	init: func (=size, =pointer, =free)
	init: func ~fromSize (=size) {
		pointer: Pointer
		bin := ArrayList<Buffer> new()
//		bin = This getBin(size);
		
		for(i in 0..bin size)
		{
			buffer := bin[i]
			if (buffer size == size) {
				pointer = bin[i] pointer
				bin removeAt(i)
				break
			}
		}
		if (pointer == None new()) {
			pointer = gc_malloc(size);
		}
		this init(size, pointer, This recycle)
	}
	dispose: func() {
		if (this free == null)
			this free(this)
	}
	recycle: static func (buffer: Buffer) {
		This lock lock()
		bin := This getBin(buffer size)
		while (bin size > 10) {
			b := bin removeAt(0)
			gc_free(b pointer)
		}
		bin add(buffer)
		This lock unlock()
	}
	getBin: static func (size: Int) -> ArrayList<Buffer> {
		// TODO: select bin
		This mediumRecycleBin
	}
	lock := static Mutex new()
	smallRecycleBin := static ArrayList<Buffer> new()
	mediumRecycleBin := static ArrayList<Buffer> new()
	largeRecycleBin := static ArrayList<Buffer> new()
}
