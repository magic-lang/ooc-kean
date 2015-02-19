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
import GpuMap, GpuContext, Viewport

GpuSurface: abstract class {
	size: IntSize2D
	_context: GpuContext
	init: func (=_context)
	draw: abstract func (image: Image, map: GpuMap, viewport: Viewport)
	draw: abstract func ~twoGpuimages (image1: Image, image2: Image, map: GpuMap, viewport: Viewport)
	clear: abstract func
	recycle: abstract func
}
