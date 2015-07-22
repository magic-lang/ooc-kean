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
use ooc-collections

import GpuImage, GpuMap, GpuSurface, GpuContext, structs/LinkedList

GpuCanvas: abstract class extends GpuSurface {
	_target: GpuImage
	blend := false
	init: func (=_target, context: GpuContext) {
		super(this _target size, context, FloatTransform2D createScaling(2.0f / this _target size width, 2.0f / this _target size height))
	}
	draw: abstract func (image: Image)
	draw: abstract func ~transform2D (image: Image, transform: FloatTransform2D)
	draw: abstract func ~withmap (image: Image, map: GpuMap, viewport: IntBox2D)
	clear: abstract func
	drawLines: virtual func (transformList: VectorList<FloatPoint2D>)
	drawBox: virtual func (box: FloatBox2D)
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>)
	readPixels: virtual func -> ByteBuffer { raise("Trying to read pixels in unimplemented readPixels function"); null }
	onRecycle: abstract func
}
