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
use ooc-math
use ooc-collections
import GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar, GpuPacker
import threading/Thread

GpuPackerBin: class {
	_packers: VectorList<GpuPacker>
	_limit := 10
	_mutex: Mutex
	init: func {
		this _packers = VectorList<GpuPacker> new()
		this _mutex = Mutex new()
	}
	free: override func {
		this _packers free()
		super()
	}
	clean: func { this _packers clear() }
	add: func (packer: GpuPacker) {
		this _mutex lock()
		if (this _packers count >= this _limit)
			this _packers remove(0) free()
		this _packers add(packer)
		this _mutex unlock()
	}
	_search: func (size: IntSize2D, bytesPerPixel: UInt, list: VectorList<GpuPacker>) -> GpuPacker {
		result: GpuPacker = null
		index := -1
		for (i in 0..list count) {
			packer := list[i]
			if(packer size == size && packer bytesPerPixel == bytesPerPixel) {
				index = i
				break
			}
		}
		if (index != -1)
			result = list remove(index)
		result
	}
	find: func (size: IntSize2D, bytesPerPixel: UInt) -> GpuPacker {
		this _mutex lock()
		result := this _search(size, bytesPerPixel, this _packers)
		this _mutex unlock()
		result
	}
}
