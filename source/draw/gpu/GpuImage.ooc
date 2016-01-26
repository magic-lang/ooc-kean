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

use draw
use geometry
use base
import GpuContext, GpuFence, GpuSurface

version(!gpuOff) {
GpuImageType: enum {
	monochrome
	rgba
	rgb
	bgr
	bgra
	uv
	yuvSemiplanar
	yuvPlanar
	yuv422
}

GpuImage: abstract class extends Image {
	_context: GpuContext
	filter: Bool { get set }
	canvas: GpuSurface { get {
		if (this _canvas == null)
			this _canvas = this _createCanvas() as GpuSurface
		this _canvas as GpuSurface
	}}
	init: func (size: IntVector2D, =_context) { super(size) }
	resizeTo: override func (size: IntVector2D) -> This {
		result := this create(size) as This
		result canvas draw(this, size)
		result
	}
	copy: override func -> This { this resizeTo(this size) }
	copy: override func ~fromParams (size: IntVector2D, transform: FloatTransform2D) -> This { raise("Using unimplemented function copy ~fromParams in GpuImage class"); null }
	distance: override func (other: Image) -> Float { raise("Using unimplemented function distance in GpuImage class"); 0.0f }

	upload: abstract func (image: RasterImage)
	toRaster: func -> RasterImage { this _context toRaster(this) }
	toRasterAsync: func -> (RasterImage, GpuFence) { this _context toRasterAsync(this) }
	toRasterDefault: abstract func -> RasterImage
}
}
