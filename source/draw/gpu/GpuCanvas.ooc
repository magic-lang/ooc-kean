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
import GpuImage, GpuMap, GpuSurface, GpuContext, GpuYuv420Semiplanar

GpuCanvas: abstract class extends GpuSurface {
	_target: GpuImage
	init: func (=_target, context: GpuContext) { super(this _target size, context, context defaultMap, IntTransform2D identity) }
	readPixels: virtual func -> ByteBuffer { Debug raise("Trying to read pixels in unimplemented readPixels function"); null }
	onRecycle: abstract func
}

GpuCanvasYuv420Semiplanar: class extends GpuCanvas {
	target ::= this _target as GpuYuv420Semiplanar
	transform: FloatTransform3D {
		get { this _view }
		set(value) {
			this _view = this _toLocal * value * this _toLocal
			this target y canvas _view = this _view
			this target uv canvas _view = FloatTransform3D createTranslation(-this _view m / 2.0f, -this _view n / 2.0f, -this _view o / 2.0f) * this _view
		}
	}
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			this target y canvas focalLength = value
			this target uv canvas focalLength = value / 2
		}
	}

	init: func (image: GpuYuv420Semiplanar, context: GpuContext) {
		super(image, context)
		this target uv canvas clearColor = ColorBgra new(128, 128, 128, 128)
	}
	onRecycle: func
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: GpuMap) {
		gpuImage := image as GpuYuv420Semiplanar
		this target y canvas draw(gpuImage y, source, destination, map)
		this target uv canvas draw(gpuImage uv, IntBox2D new(source leftTop / 2, source size / 2), IntBox2D new(destination leftTop / 2, destination size / 2), map)
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>) { this target y canvas drawLines(pointList) }
	drawBox: override func (box: FloatBox2D) { this target y canvas drawBox(box) }
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) { this target y canvas drawPoints(pointList) }
	clear: override func {
		this target y canvas clear()
		this target uv canvas clear()
	}
}
