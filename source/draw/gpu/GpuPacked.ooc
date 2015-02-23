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
use ooc-base
import GpuImage, GpuTexture, GpuCanvas, GpuContext

GpuPacked: abstract class extends GpuImage {
	_texture: GpuTexture
	texture: GpuTexture { get { this _texture } }
	init: func (=_texture, size: IntSize2D, channels: Int, context: GpuContext) { super(size, channels, context) }
	dispose: override func {
		this _texture free()
		super()
	}
	bind: func (unit: UInt) { this _texture bind(unit) }
	unbind: func { this _texture unbind() }
	upload: func (raster: RasterPacked) { this _texture upload(raster buffer pointer, raster stride) }
	generateMipmap: func { this _texture generateMipmap() }
	setMagFilter: func (linear: Bool) { this _texture setMagFilter(linear) }
}
