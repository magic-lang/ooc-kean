//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
use ooc-draw
import GpuMonochrome, GpuCanvas, GpuPlanar, GpuContext

GpuYuv420Planar: abstract class extends GpuPlanar {
	_y: GpuMonochrome
	y ::= this _y
	_u: GpuMonochrome
	u ::= this _u
	_v: GpuMonochrome
	v ::= this _v
	init: func (=_y, =_u, =_v, context: GpuContext) {
		super(this _y size, context)
		this _y referenceCount increase()
		this _u referenceCount increase()
		this _v referenceCount increase()
	}
	free: override func {
		this y referenceCount decrease()
		this u referenceCount decrease()
		this v referenceCount decrease()
		super()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _u bind(unit + 1)
		this _v bind(unit + 2)
	}
	unbind: func {
		this _y unbind()
		this _u unbind()
		this _v unbind()
	}
	upload: func (raster: RasterImage) {
		planar := raster as RasterYuv420Planar
		this _y upload(planar y)
		this _u upload(planar u)
		this _v upload(planar v)
	}
	generateMipmap: func {
		this _y generateMipmap()
		this _u generateMipmap()
		this _v generateMipmap()
	}
	setMagFilter: func (linear: Bool) {
		this _y setMagFilter(linear)
		this _u setMagFilter(linear)
		this _v setMagFilter(linear)
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := this _context createYuv420Planar(size)
		target canvas draw(this)
		target
	}
	toRasterDefault: func -> RasterImage {
		y := this _y toRaster()
		u := this _u toRaster()
		v := this _v toRaster()
		result := RasterYuv420Planar new(y as RasterMonochrome, u as RasterMonochrome, v as RasterMonochrome)
		result
	}
	toRasterDefault: func ~overwrite (rasterImage: RasterImage) {
		planar := rasterImage as RasterYuv420Planar
		this _y toRaster(planar y)
		this _u toRaster(planar u)
		this _v toRaster(planar v)
	}
}
