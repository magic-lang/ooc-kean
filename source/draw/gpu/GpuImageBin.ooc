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
use ooc-base
import structs/FreeArrayList, GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar, GpuYuv422Semipacked
import threading/Thread

GpuImageBin: class {
	_monochrome: FreeArrayList<GpuImage>
	_bgr: FreeArrayList<GpuImage>
	_bgra: FreeArrayList<GpuImage>
	_uv: FreeArrayList<GpuImage>
	_yuv422: FreeArrayList<GpuImage>
	_mutex: Mutex
	_limit := 5

	init: func {
		this _mutex = Mutex new()
		this _monochrome = FreeArrayList<GpuImage> new()
		this _bgr = FreeArrayList<GpuImage> new()
		this _bgra = FreeArrayList<GpuImage> new()
		this _uv = FreeArrayList<GpuImage> new()
		this _yuv422 = FreeArrayList<GpuImage> new()
	}
	free: func {
		this _mutex lock()
		for(i in 0..this _monochrome size)
			this _monochrome[i] _recyclable = false
		for(i in 0..this _bgr size)
			this _bgr[i] _recyclable = false
		for(i in 0..this _bgra size)
			this _bgra[i] _recyclable = false
		for(i in 0..this _uv size)
			this _uv[i] _recyclable = false
		for(i in 0..this _yuv422 size)
			this _yuv422[i] _recyclable = false
		this _monochrome free()
		this _bgr free()
		this _bgra free()
		this _uv free()
		this _yuv422 free()
		this _mutex unlock()
		this _mutex destroy()
		super()
	}
	_add: func (image: GpuImage, list: FreeArrayList<GpuImage>) {
		if (list size >= this _limit) {
			// We need to make sure the image will be destroyed instead of recycled
			temp := list[0]
			list removeAt(0)
			temp _recyclable = false
			temp free()
		}
		list add(image)
	}
	add: func (image: GpuImage) {
		version(safe) raise("Added a GpuImage to the bin without permission to recycle images.")
		this _mutex lock()
		match (image) {
			case (i: GpuMonochrome) => this _add(i, this _monochrome)
			case (i: GpuBgr) => this _add(i, this _bgr)
			case (i: GpuBgra) => this _add(i, this _bgra)
			case (i: GpuUv) => this _add(i, this _uv)
			case (i: GpuYuv422Semipacked) => this _add(i, this _yuv422)
			case => Debug raise("Unknown format in GpuImageBin add()")
		}
		this _mutex unlock()
	}
	_search: func (size: IntSize2D, arrayList: FreeArrayList<GpuImage>) -> GpuImage {
		result := null
		index := 0
		for (i in 0..arrayList size) {
			image := arrayList[i]
			if (image size width == size width && image size height == size height) {
				result = image
				index = i
				break
			}
		}
		if (result != null)
			arrayList removeAt(index, false)
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
			case GpuImageType yuv422 => this _search(size, this _yuv422)
			case => null
		}
		this _mutex unlock()
		result
	}
}
