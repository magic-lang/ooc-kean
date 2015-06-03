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
import GpuImage, GpuMonochrome, GpuBgr, GpuBgra, GpuUv, GpuYuv420Semiplanar, GpuYuv420Planar, GpuSurface

GpuSurfaceBin: class {
	_surfaces := VectorList<GpuSurface> new()
	init: func
	free: override func {
		this _surfaces free()
		super()
	}
	add: func (surface: GpuSurface) { this _surfaces add(surface) }
	_search: func (list: VectorList<GpuSurface>) -> GpuSurface {
		result: GpuSurface = null
		if (!list empty)
			result = list remove(0)
		result
	}
	find: func -> GpuSurface { this _search(this _surfaces) }
}
