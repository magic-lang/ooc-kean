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

use ooc-geometry
use draw
import GpuContext, GpuImage, GpuSurface, GpuCanvas

version(!gpuOff) {
GpuYuv420Semiplanar: class extends GpuImage {
	_y: GpuImage
	_uv: GpuImage
	y ::= this _y
	uv ::= this _uv
	filter: Bool {
		get { this _y filter }
		set(value) {
			this _y filter = value
			this _uv filter = value
		}
	}
	init: func (=_y, =_uv, context: GpuContext) {
		super(this _y size, context)
		this _coordinateSystem = this _y coordinateSystem
		this _y referenceCount increase()
		this _uv referenceCount increase()
	}
	init: func ~fromRaster (rasterImage: RasterYuv420Semiplanar, context: GpuContext) {
		y := context createImage(rasterImage y)
		uv := context createImage(rasterImage uv)
		this init(y, uv, context)
	}
	init: func ~empty (size: IntVector2D, context: GpuContext) {
		y := context createMonochrome(size)
		uv := context createUv(size / 2)
		this init(y, uv, context)
	}
	free: override func {
		this y referenceCount decrease()
		this uv referenceCount decrease()
		super()
	}
	toRasterDefault: override func -> RasterImage {
		y := this _y toRaster() as RasterMonochrome
		uv := this _uv toRaster() as RasterUv
		RasterYuv420Semiplanar new(y, uv)
	}
	create: override func (size: IntVector2D) -> This { this _context createYuv420Semiplanar(size) }
	_createCanvas: override func -> GpuSurface { GpuCanvasYuv420Semiplanar new(this, this _context) }
	upload: override func (image: RasterImage) {
		if (image instanceOf?(RasterYuv420Semiplanar)) {
			raster := image as RasterYuv420Semiplanar
			this _y upload(raster y)
			this _uv upload(raster uv)
		}
	}
}
}
