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
use ooc-collections
use ooc-math
use ooc-base
import GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar
import threading/Thread

GpuImageBin: class {
	_monochrome: VectorList<GpuImage>
	_bgr: VectorList<GpuImage>
	_bgra: VectorList<GpuImage>
	_uv: VectorList<GpuImage>
	_mutex: Mutex
	_limit := 15
	init: func {
		this _mutex = Mutex new()
		this _monochrome = VectorList<GpuImage> new()
		this _bgr = VectorList<GpuImage> new()
		this _bgra = VectorList<GpuImage> new()
		this _uv = VectorList<GpuImage> new()
	}
	_cleanList: static func (list: VectorList<GpuImage>) {
		for (i in 0 .. list count)
			list[i] _recyclable = false
		list clear()
	}
	clean: func {
		this _mutex lock()
		This _cleanList(this _monochrome)
		This _cleanList(this _bgr)
		This _cleanList(this _bgra)
		This _cleanList(this _uv)
		this _mutex unlock()
	}
	free: override func {
		this clean()
		this _monochrome free()
		this _bgr free()
		this _bgra free()
		this _uv free()
		this _mutex destroy()
		super()
	}
	_add: func (image: GpuImage, list: VectorList<GpuImage>) {
		if (list count >= this _limit) {
			version(debugGL) Debug print("GpuImageBin full; freeing one GpuImage")
			// We need to make sure the image will be destroyed instead of recycled
			temp := list remove(0)
			temp _recyclable = false
			temp free()
		}
		list add(image)
	}
	add: func (image: GpuImage) {
		version(safe) Debug raise("Added a GpuImage to the bin without permission to recycle images.")
		this _mutex lock()
		match (image) {
			case (i: GpuMonochrome) => this _add(i, this _monochrome)
			case (i: GpuBgr) => this _add(i, this _bgr)
			case (i: GpuBgra) => this _add(i, this _bgra)
			case (i: GpuUv) => this _add(i, this _uv)
			case => Debug raise("Unknown format in GpuImageBin add()")
		}
		this _mutex unlock()
	}
	_search: func (size: IntSize2D, list: VectorList<GpuImage>) -> GpuImage {
		result := null
		index := -1
		for (i in 0 .. list count) {
			image := list[i]
			if (image size width == size width && image size height == size height) {
				index = i
				break
			}
		}
		if (index != -1)
			result = list remove(index)
		result
	}
	find: func (type: GpuImageType, size: IntSize2D) -> GpuImage {
		this _mutex lock()
		result := null
		result = match (type) {
			case GpuImageType monochrome => this _search(size, this _monochrome)
			case GpuImageType uv => this _search(size, this _uv)
			case GpuImageType bgr => this _search(size, this _bgr)
			case GpuImageType bgra => this _search(size, this _bgra)
			case => null
		}
		this _mutex unlock()
		result
	}
}
