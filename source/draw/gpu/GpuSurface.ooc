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
use ooc-collections
use ooc-base

import GpuContext, GpuMap, GpuImage

GpuSurface: abstract class {
	clearColor: ColorBgra { get set }
	viewport: IntBox2D { get set }
	_size: IntSize2D
	size ::= this _size
	blend: Bool { get set }
	_context: GpuContext
	_model: FloatTransform3D
	_view: FloatTransform3D
	_projection: FloatTransform3D
	_toLocal: FloatTransform3D
	transform: FloatTransform3D {
		get { this _toLocal * this _view * this _toLocal }
		set(value) { this _view = this _toLocal * value * this _toLocal }
	}
	_focalLength: Float
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			if (this _focalLength > 0.0f) {
				a := 2.0f * this _focalLength / this size width
				f := -(this _coordinateTransform e as Float) * 2.0f * this _focalLength / this size height
				k := (this farPlane + this nearPlane) / (this farPlane - this nearPlane)
				o := 2.0f * this farPlane * this nearPlane / (this farPlane - this nearPlane)
				this _projection = FloatTransform3D new(a, 0.0f, 0.0f, 0.0f, 0.0f, f, 0.0f, 0.0f, 0.0f, 0.0f, k, -1.0f, 0.0f, 0.0f, o, 0.0f)
			}
			else
				this _projection = FloatTransform3D createScaling(2.0f / this size width, -(this _coordinateTransform e as Float) * 2.0f / this size height, 1.0f)
			this _model = this _createModelTransform(IntBox2D new(this size))
		}
	}
	nearPlane: Float { get set }
	farPlane: Float { get set }
	map: GpuMap { get set }
	_defaultMap: GpuMap
	_textureTransform: IntTransform2D
	_coordinateTransform := IntTransform2D identity
	init: func (=_size, =_context, =_defaultMap, =_coordinateTransform) {
		this _toLocal = FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		this reset()
	}
	_createModelTransform: func (box: IntBox2D) -> FloatTransform3D {
		toReference := FloatTransform3D createTranslation((box size width - this size width) / 2, (this size height - box size height) / 2, 0.0f)
		translation := this _toLocal * FloatTransform3D createTranslation(box leftTop x, box leftTop y, this focalLength) * this _toLocal
 		translation * toReference * FloatTransform3D createScaling(box size width / 2.0f, box size height / 2.0f, 1.0f)
	}
	_createTextureTransform: static func (imageSize: IntSize2D, box: IntBox2D) -> FloatTransform3D {
		scaling := FloatTransform3D createScaling(box size width as Float / imageSize width, box size height as Float / imageSize height, 1.0f)
		translation := FloatTransform3D createTranslation(box leftTop x as Float / imageSize width, box leftTop y as Float / imageSize height, 0.0f)
		translation * scaling
	}
	reset: virtual func {
		this clearColor = ColorBgra new(0, 0, 0, 0)
		this viewport = IntBox2D new(this size)
		this focalLength = 0.0f
		this nearPlane = 1.0f
		this farPlane = 10000.0f
		this _view = FloatTransform3D identity
		this blend = false
		this map = this _defaultMap
	}
	_bind: virtual func
	_unbind: virtual func
	clear: abstract func
	draw: func ~general (action: Func) {
		this _bind()
		this _context setViewport(this viewport)
		this _context enableBlend(this blend)
		this map use()
		action()
		this _unbind()
		this reset()
	}
	draw: virtual func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D) {
		this map model = this _createModelTransform(destination)
		this map view = this _view
		this map projection = this _projection
		this map textureTransform = This _createTextureTransform(image size, source)
		this draw(func {
			image bind(0)
			this _context drawQuad()
		})
	}
	draw: func ~Image (image: Image, source: IntBox2D, destination: IntBox2D) {
		if (image instanceOf?(GpuImage)) { this draw~GpuImage(image as GpuImage, source, destination) }
		else if (image instanceOf?(RasterImage)) {
			temp := this _context createGpuImage(image as RasterImage)
			this draw~GpuImage(temp as GpuImage, source, destination)
			temp free()
		}
		else
			Debug raise("Trying to draw unsupported image format to OpenGLES3Canvas!")
	}
	draw: func ~DefaultImage (image: Image) { this draw(image, IntBox2D new(image size), IntBox2D new(image size)) }
	draw: func ~Destination (image: Image, destination: IntBox2D) { this draw(image, IntBox2D new(image size), destination)}
	draw: func ~DestinationSize (image: Image, targetSize: IntSize2D) { this draw(image, IntBox2D new(targetSize)) }
	drawLines: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawLines(pointList, this _projection * this _toLocal) }) }
	drawBox: virtual func (box: FloatBox2D) { this draw(func { this _context drawBox(box, this _projection * this _toLocal) }) }
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawPoints(pointList, this _projection * this _toLocal) }) }
}
