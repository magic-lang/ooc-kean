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
import structs/ArrayList, GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar

GpuImageBin: class {
	_monochrome: ArrayList<GpuImage>
	_bgr: ArrayList<GpuImage>
	_bgra: ArrayList<GpuImage>
	_uv: ArrayList<GpuImage>
	_yuvSemiplanar: ArrayList<GpuImage>
	_yuvPlanar: ArrayList<GpuImage>

	init: func {
		this _monochrome = ArrayList<GpuImage> new()
		this _bgr = ArrayList<GpuImage> new()
		this _bgra = ArrayList<GpuImage> new()
		this _uv = ArrayList<GpuImage> new()
		this _yuvSemiplanar = ArrayList<GpuImage> new()
		this _yuvPlanar = ArrayList<GpuImage> new()
	}
	dispose: func {
		for(image in this _monochrome)
			image dispose()
		for(image in this _bgr)
			image dispose()
		for(image in this _bgra)
			image dispose()
		for(image in this _uv)
			image dispose()
		for(image in this _yuvSemiplanar)
			image dispose()
		for(image in this _yuvPlanar)
			image dispose()

		this _monochrome clear()
		this _bgr clear()
		this _bgra clear()
		this _uv clear()
		this _yuvSemiplanar clear()
		this _yuvPlanar clear()
	}

	add: func (image: GpuImage) {
		match (image) {
			case (i: GpuMonochrome) =>
				this _monochrome add(image)
			case (i: GpuBgr) =>
				this _bgr add(image)
			case (i: GpuBgra) =>
				this _bgra add(image)
			case (i: GpuUv) =>
				this _uv add(image)
			case (i: GpuYuv420Semiplanar) =>
				this _yuvSemiplanar add(image)
			case (i: GpuYuv420Planar) =>
				this _yuvPlanar add(image)
		}
	}

	_search: func (size: IntSize2D, arrayList: ArrayList<GpuImage>) -> GpuImage {
		result := null
		for (image in arrayList) {
			if (image size width == size width && image size height == size height) {
				result = image
				break
			}
		}
		if (result != null)
			arrayList remove(result)
		result
	}
	find: func (type: GpuImageType, size: IntSize2D) -> GpuImage {
		result := null
		result = match (type) {
			case GpuImageType monochrome => this _search(size, this _monochrome)
			case GpuImageType uv => this _search(size, this _uv)
			case GpuImageType bgr => this _search(size, this _bgr)
			case GpuImageType bgra => this _search(size, this _bgra)
			case GpuImageType yuvSemiplanar => this _search(size, this _yuvSemiplanar)
			case GpuImageType yuvPlanar => this _search(size, this _yuvPlanar)
		}
		result
	}

}
