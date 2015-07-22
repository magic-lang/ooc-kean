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

use ooc-draw
use ooc-math
use ooc-base
import GpuCanvas, GpuContext, GpuFence

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
	_canvas: GpuCanvas
	canvas: GpuCanvas { get {
		if (this _canvas == null)
			this _canvas = this _createCanvas()
		this _canvas } }
	_context: GpuContext
	_channels: Int
	channels: Int { get { this _channels } }
	length: Int { get { this _channels * this size width * this size height } }
	_recyclable := false
	recyclable ::= this _recyclable
	reference ::= FloatTransform2D createScaling(this size width / 2.0f, this size height / 2.0f)
	init: func (size: IntSize2D, =_channels, =_context) { super(size) }
	free: override func {
		if (this _canvas != null) {
			this _canvas free()
			this _canvas = null
		}
		super()
	}
	recycle: func {
		if (this _canvas != null)
			this _canvas onRecycle()
		version(safe)
			this free()
		else
			this _context recycle(this)
	}
	bind: abstract func (unit: UInt)
	unbind: abstract func
	upload: abstract func (raster: RasterImage)
	generateMipmap: abstract func
	setMagFilter: abstract func (linear: Bool)
	setMinFilter: abstract func (linear: Bool)

	//TODO: Implement abstract functions
	create: override func (size: IntSize2D) -> This { raise("Unimplemented"); null }
	resizeTo: func (size: IntSize2D) -> This { raise("Using unimplemented function reSizeTo in GpuImage class"); null }
	copy: func -> This { raise("Using unimplemented function copy in GpuImage class"); null }
	copy: func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This { raise("Using unimplemented function copy ~fromParams in GpuImage class"); null }
	shift: func (offset: IntSize2D) -> This { raise("Using unimplemented function shift in GpuImage class"); null }
	distance: func (other: This) -> Float { raise("Using unimplemented function distance in GpuImage class"); 0.0f }
	toRaster: func(async: Bool = false) -> RasterImage { this _context toRaster(this, async) }
	toRasterAsync: func -> (RasterImage, GpuFence) { this _context toRasterAsync(this) }
	toRasterDefault: abstract func -> RasterImage
	_createCanvas: abstract func -> GpuCanvas

}
