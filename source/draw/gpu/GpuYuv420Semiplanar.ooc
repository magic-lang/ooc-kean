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
import GpuMonochrome, GpuCanvas, GpuUv, GpuContext, GpuImage

GpuYuv420Semiplanar: class extends GpuImage {
	_y: GpuMonochrome
	y ::= this _y
	_uv: GpuUv
	uv ::= this _uv

	init: func (=_y, =_uv, context: GpuContext) {
		super(this _y size, 3, context)
		this coordinateSystem = this _y coordinateSystem
		this _y referenceCount increase()
		this _uv referenceCount increase()
	}
	init: func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) {
		y := context createGpuImage(rasterImage y) as GpuMonochrome
		uv := context createGpuImage(rasterImage uv) as GpuUv
		this init(y, uv, context)
	}
	init: func ~empty (size: IntSize2D, context: GpuContext) {
		y := context createMonochrome(size)
		uv := context createUv(size / 2)
		this init(y, uv, context)
	}
	free: override func {
		this y referenceCount decrease()
		this uv referenceCount decrease()
		super()
	}
	bind: func (unit: UInt) {
		this _y bind(unit)
		this _uv bind(unit + 1)
	}
	unbind: func {
		this _y unbind()
		this _uv unbind()
	}
	upload: func (raster: RasterImage) {
		semiPlanar := raster as RasterYuv420Semiplanar
		this _y upload(semiPlanar y)
		this _uv upload(semiPlanar uv)
	}
	generateMipmap: func {
		this _y generateMipmap()
		this _uv generateMipmap()
	}
	setMagFilter: func (linear: Bool) {
		this _y setMagFilter(linear)
		this _uv setMagFilter(linear)
	}
	setMinFilter: func (linear: Bool) {
		this _y setMinFilter(linear)
		this _uv setMinFilter(linear)
	}
	resizeTo: func (size: IntSize2D) -> This {
		target := this _context createYuv420Semiplanar(size)
		target canvas draw(this)
		target
	}
	toRasterDefault: func -> RasterImage {
		y := this _y toRaster() as RasterMonochrome
		uv := this _uv toRaster() as RasterUv
		RasterYuv420Semiplanar new(y, uv)
	}
	create: override func (size: IntSize2D) -> This { this _context createYuv420Semiplanar(size) }
	_createCanvas: override func -> GpuCanvas { GpuCanvasYuv420Semiplanar new(this, this _context) }
}
