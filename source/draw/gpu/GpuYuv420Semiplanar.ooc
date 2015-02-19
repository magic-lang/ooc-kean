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
import GpuMonochrome, GpuCanvas, GpuPlanar, GpuUv, GpuContext

GpuYuv420Semiplanar: abstract class extends GpuPlanar {
	_y: GpuMonochrome
	y ::= this _y
	_uv: GpuUv
	uv ::= this _uv

	init: func (size: IntSize2D, context: GpuContext) { super(size, context) }
	dispose: func {
		this _y free()
		this _uv free()
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
	resizeTo: func (size: IntSize2D) -> This {
		target := this _context createYuv420Semiplanar(size)
		target canvas draw(this)
		target
	}
	toRasterDefault: func -> RasterImage {
		y := this _y toRaster()
		uv := this _uv toRaster()
		result := RasterYuv420Semiplanar new(y as RasterMonochrome, uv as RasterUv)
		result
	}
	toRasterDefault: func ~overwrite (rasterImage: RasterImage) {
		semiPlanar := rasterImage as RasterYuv420Semiplanar
		this _y toRaster(semiPlanar y)
		this _uv toRaster(semiPlanar uv)
	}
}
