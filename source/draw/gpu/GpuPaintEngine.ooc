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

use ooc-base
use ooc-math
use ooc-collections
import PaintEngine
import GpuImage, GpuCanvas

version(!gpuOff) {
GpuPaintEngine: class extends PaintEngine {
	_image: GpuImage
	init: func (=_image) { super() }
	drawPoint: override func (x, y: Int) {
		this _image canvas pen = this pen
		this drawPoint~withFloat(x, y)
	}
	drawPoint: override func ~withFloat (x, y: Float) {
		this _image canvas pen = this pen
		vector := VectorList<FloatPoint2D> new().add(FloatPoint2D new(x, y))
		this _image canvas drawPoints(vector)
		vector free()
	}
	drawPoint: virtual func ~withFloatPoint2D (position: FloatPoint2D) {
		this _image canvas pen = this pen
		this drawPoint~withFloat(position x, position y)
	}
	drawLine: override func ~withFloatPoint2D (start, end: FloatPoint2D) {
		this _image canvas pen = this pen
		line := VectorList<FloatPoint2D> new().add(start).add(end)
		this _image canvas drawLines(line)
		line free()
	}
	drawLines: override func (lines: VectorList<FloatPoint2D>) {
		this _image canvas pen = this pen
		this _image canvas drawLines(lines)
	}
	drawBox: override func ~withFloatBox2D (box: FloatBox2D) {
		this _image canvas pen = this pen
		this _image canvas drawBox(box)
	}
}
}
