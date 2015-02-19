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
import structs/FreeArrayList, GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar, GpuPacker

GpuPackerBin: class {
	_packers: FreeArrayList<GpuPacker>
	init: func { this _packers = FreeArrayList<GpuPacker> new() }
	clean: func {
		for(i in 0..this _packers size) {
			packer := this _packers[i]
			packer free()
		}
		this _packers clear()
	}
	add: func (packer: GpuPacker) { this _packers add(packer) }
	_search: func (size: IntSize2D, bytesPerPixel: UInt, arrayList: FreeArrayList<GpuPacker>) -> GpuPacker {
		result := null
		index := 0
		for (i in 0..arrayList size) {
			packer := arrayList[i]
			if(packer size == size && packer bytesPerPixel == bytesPerPixel) {
				index = i
				result = packer
				break
			}
		}
		if (result != null)
			arrayList removeAt(index, false)
		result
	}
	find: func (size: IntSize2D, bytesPerPixel: UInt)-> GpuPacker { this _search(size, bytesPerPixel, this _packers) }
}
