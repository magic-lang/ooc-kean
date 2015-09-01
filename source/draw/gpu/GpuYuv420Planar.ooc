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
import GpuMonochrome, GpuCanvas, GpuContext, GpuImage

GpuYuv420Planar: class extends GpuImage {
	_y: GpuMonochrome
	y ::= this _y
	_u: GpuMonochrome
	u ::= this _u
	_v: GpuMonochrome
	v ::= this _v
	init: func (=_y, =_u, =_v, context: GpuContext) {
		super(this _y size, 3, context)
		this _y referenceCount increase()
		this _u referenceCount increase()
		this _v referenceCount increase()
	}
	init: func ~gpuImages (y: GpuMonochrome, u: GpuMonochrome, v: GpuMonochrome, context: GpuContext) {
		this init(y, u, v, context)
		this coordinateSystem = y coordinateSystem
	}
	init: func ~empty (size: IntSize2D, context: GpuContext) {
		y := context createMonochrome(size)
		u := context createMonochrome(IntSize2D new(size width / 2, size height / 2))
		v := context createMonochrome(IntSize2D new(size width / 2, size height / 2))
		this init(y, u, v, context)
	}
	init: func ~fromRaster (rasterImage: RasterYuv420Planar, context: GpuContext) {
		y := context createGpuImage(rasterImage y) as GpuMonochrome
		u := context createGpuImage(rasterImage u) as GpuMonochrome
		v := context createGpuImage(rasterImage v) as GpuMonochrome
		this init(y, u, v, context)
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
	setMinFilter: func (linear: Bool) {
		this _y setMinFilter(linear)
		this _u setMinFilter(linear)
		this _v setMinFilter(linear)
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := this _context createYuv420Planar(size)
		target canvas draw(this)
		target
	}
	toRasterDefault: func -> RasterImage {
		y := this _y toRaster() as RasterMonochrome
		u := this _u toRaster() as RasterMonochrome
		v := this _v toRaster() as RasterMonochrome
		RasterYuv420Planar new(y, u, v)
	}
	_createCanvas: override func -> GpuCanvas { GpuCanvasYuv420Planar new(this, this _context) }
}
