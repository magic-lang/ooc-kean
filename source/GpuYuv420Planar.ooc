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
import GpuMonochrome, GpuCanvas, GpuPlanar

GpuYuv420Planar: class extends GpuPlanar {
	_canvas: GpuCanvasYuv420Planar
	_y: GpuMonochrome
	y: GpuMonochrome { get { this _y } }
	_u: GpuMonochrome
	u: GpuMonochrome { get { this _u } }
	_v: GpuMonochrome
	v: GpuMonochrome { get { this _v } }
	canvas: GpuCanvasYuv420Planar {
		get {
			if (this _canvas == null)
				this _canvas = GpuCanvasYuv420Planar create(this)
			this _canvas
		}
	}
	init: func (=size)
	dispose: func {
		this _y dispose()
		this _u dispose()
		this _v dispose()
		if (this _canvas != null)
			this _canvas dispose()
	}
	recycle: func {
		this _y recycle()
		this _u recycle()
		this _v recycle()
	}
	_bind: /* internal */ func {
		this _y _bind(0)
		this _u _bind(1)
		this _v _bind(2)
	}
	_generate: func (stride: UInt, y: Pointer, u: Pointer, v: Pointer) -> Bool {
		this _y = GpuMonochrome _create(this size, stride, y)
		this _u = GpuMonochrome _create(this size / 2, stride, u)
		this _v = GpuMonochrome _create(this size / 2, stride, v)
		this _y != null && this _u != null && this _v != null
	}
	create: func (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null, null) ? result : null
	}
	create: static func ~empty (size: IntSize2D) -> This {
		result := This new(size)
		result _generate(size width, null, null, null) ? result : null
	}
	_create: static /* internal */ func ~fromPixels (size: IntSize2D, stride: UInt, y: Pointer, u: Pointer, v: Pointer) -> This {
		result := This new(size)
		result _generate(stride, y, u, v) ? result : null
	}
}
