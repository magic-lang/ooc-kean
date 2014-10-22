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
import GpuMonochrome, GpuCanvas, GpuPlanar, GpuContext

GpuYuv420Planar: abstract class extends GpuPlanar {
	_y: GpuMonochrome
	y: GpuMonochrome { get { this _y } }
	_u: GpuMonochrome
	u: GpuMonochrome { get { this _u } }
	_v: GpuMonochrome
	v: GpuMonochrome { get { this _v } }

	init: func (size: IntSize2D, context: GpuContext) {
		super(size, context)
	}

}
