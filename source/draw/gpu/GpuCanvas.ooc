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
import GpuImage, GpuMap, GpuSurface, GpuContext

GpuCanvas: abstract class extends GpuSurface {
	_target: GpuImage
	init: func (=_target, context: GpuContext) { super(this _target size, context, context getMap(this _target, GpuMapType transform)) }
	readPixels: virtual func -> ByteBuffer { Debug raise("Trying to read pixels in unimplemented readPixels function"); null }
	onRecycle: abstract func
}
