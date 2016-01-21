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

use geometry
use draw
use base
use collections
import GpuImage, GpuMap, GpuSurface, GpuContext, GpuYuv420Semiplanar, GpuMesh

version(!gpuOff) {
GpuCanvasYuv420Semiplanar: class extends GpuSurface {
	_target: GpuYuv420Semiplanar
	transform: FloatTransform3D {
		get { this _view }
		set(value) {
			this _view = this _toLocal * value * this _toLocal
			this _target y canvas _view = this _view
			this _target uv canvas _view = FloatTransform3D createTranslation(-this _view m / 2.0f, -this _view n / 2.0f, -this _view o / 2.0f) * this _view
		}
	}
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			this _target y canvas focalLength = value
			this _target uv canvas focalLength = value / 2
		}
	}
	pen: Pen {
		get { this _pen }
		set(value) {
			this _pen = value
			yuv := value color toYuv()
			this _target y canvas pen = Pen new(ColorBgra new(yuv y, 0, 0, 255), value width)
			this _target uv canvas pen = Pen new(ColorBgra new(yuv u, yuv v, 0, 255), value width)
		}
	}

	init: func (=_target, context: GpuContext) {
		super(this _target size, context, context defaultMap, IntTransform2D identity)
		this _target uv canvas pen = Pen new(ColorBgra new(128, 128, 128, 128))
	}
	draw: override func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: GpuMap) {
		gpuImage := image as GpuYuv420Semiplanar
		this _target y canvas draw(gpuImage y, source, destination, map)
		this _target uv canvas draw(gpuImage uv, IntBox2D new(source leftTop / 2, source size / 2), IntBox2D new(destination leftTop / 2, destination size / 2), map)
	}
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		gpuImage := image as GpuYuv420Semiplanar
		this _target y canvas draw(gpuImage y, source, destination)
		this _target uv canvas draw(gpuImage uv, IntBox2D new(source leftTop / 2, source size / 2), IntBox2D new(destination leftTop / 2, destination size / 2))
	}
	drawLines: override func (pointList: VectorList<FloatPoint2D>) {
		this _target y canvas drawLines(pointList)
		uvLines := VectorList<FloatPoint2D> new()
		for (i in 0 .. pointList count)
			uvLines add(pointList[i] / 2.0f)
		this _target uv canvas drawLines(uvLines)
		uvLines free()
	}
	drawPoints: override func (pointList: VectorList<FloatPoint2D>) { this _target y canvas drawPoints(pointList) }
	fill: override func {
		this _target y canvas fill()
		this _target uv canvas fill()
	}
	draw: override func ~mesh (image: GpuImage, mesh: GpuMesh) {
		if (!image instanceOf?(GpuYuv420Semiplanar))
			Debug raise("Invalid input format in GpuYuv420SemiplanarCanvas::draw~mesh")
		yuv := image as GpuYuv420Semiplanar
		this _target y canvas draw(yuv y, mesh)
		this _target uv canvas draw(yuv uv, mesh)
	}
}
}
