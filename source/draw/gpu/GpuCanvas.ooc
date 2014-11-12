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

import GpuImage, GpuMap, GpuSurface, GpuContext, Viewport

GpuCanvas: abstract class {
	_size: IntSize2D
	_context: GpuContext
	init: func (=_context)
	dispose: abstract func
	draw: abstract func (image: Image, transform := FloatTransform2D identity)
	draw: abstract func ~withmap (image: Image, map: GpuMap, viewport: Viewport)
	drawLines: func (transform: FloatTransform2D, size: IntSize2D)
	readPixels: func (channels: UInt) -> ByteBuffer {
		raise("Trying to read pixels in unimplemented readPixels function")
	}
	onRecycle: abstract func

}
