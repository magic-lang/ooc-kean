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
import structs/FreeArrayList, GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar, GpuSurface

GpuSurfaceBin: class {
	_surfaces: FreeArrayList<GpuSurface>
	init: func { this _surfaces = FreeArrayList<GpuSurface> new() }
	free: func {
		for(i in 0..this _surfaces size)
			this _surfaces[i] free()
		this _surfaces clear()
		super()
	}
	add: func (surface: GpuSurface) { this _surfaces add(surface) }
	_search: func (arrayList: FreeArrayList<GpuSurface>) -> GpuSurface {
		//TODO: using a result variable, initially null,
		// and then assigning it to arrayList[0], always returns null,
		// even if arrayList size > 0. So, using multiple returns for now.
//		result : GpuSurface = null
//		arrayList size toString() println()
		if (arrayList size > 0) {
			result := arrayList[0]
			arrayList removeAt(0, false)
//			if (result == null)
//				"Result is null!" println()
			return result
		}
//		arrayList size toString() println()
		null
	}
	find: func -> GpuSurface { this _search(this _surfaces) }
}
