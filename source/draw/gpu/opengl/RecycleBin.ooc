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
use ooc-draw-gpu
import OpenGLES3Packed, OpenGLES3Monochrome, OpenGLES3Bgra, OpenGLES3Bgr, OpenGLES3Uv

RecycleBin: class {
	_monochrome := VectorList<OpenGLES3Monochrome> new()
	_bgr := VectorList<OpenGLES3Bgr> new()
	_bgra := VectorList<OpenGLES3Bgra> new()
	_uv := VectorList<OpenGLES3Uv> new()
	_limit := 15
	init: func
	_cleanList: static func (list: VectorList<OpenGLES3Packed>) {
		for (i in 0 .. list count)
			list[i] _recyclable = false
		list clear()
	}
	clean: func {
		This _cleanList(this _monochrome)
		This _cleanList(this _bgr)
		This _cleanList(this _bgra)
		This _cleanList(this _uv)
	}
	free: override func {
		this clean()
		this _monochrome free()
		this _bgr free()
		this _bgra free()
		this _uv free()
		super()
	}
	_add: func (image: OpenGLES3Packed, list: VectorList<OpenGLES3Packed>) {
		if (list count >= this _limit) {
			version(debugGL) Debug print("GpuImageBin full; freeing one GpuImage")
			// We need to make sure the image will be destroyed instead of recycled
			temp := list remove(0)
			temp _recyclable = false
			temp free()
		}
		list add(image)
	}
	add: func (image: OpenGLES3Packed) {
		match (image) {
			case (i: OpenGLES3Monochrome) => this _add(i, this _monochrome)
			case (i: OpenGLES3Bgr) => this _add(i, this _bgr)
			case (i: OpenGLES3Bgra) => this _add(i, this _bgra)
			case (i: OpenGLES3Uv) => this _add(i, this _uv)
			case => Debug raise("Unknown format in GpuImageBin add()")
		}
	}
	_search: func (size: IntSize2D, list: VectorList<OpenGLES3Packed>) -> OpenGLES3Packed {
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
	find: func (type: GpuImageType, size: IntSize2D) -> OpenGLES3Packed {
		match (type) {
			case GpuImageType monochrome => this _search(size, this _monochrome)
			case GpuImageType uv => this _search(size, this _uv)
			case GpuImageType bgr => this _search(size, this _bgr)
			case GpuImageType bgra => this _search(size, this _bgra)
			case => null
		}
	}
}
