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
	_defaultMap: GpuMap
	_coordinateTransform := IntTransform2D identity
	init: func (=_size, =_context, =_defaultMap, =_coordinateTransform) {
		this _toLocal = FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
		this clearColor = ColorBgra new(0, 0, 0, 0)
		this viewport = IntBox2D new(this size)
		this focalLength = 0.0f
		this nearPlane = 1.0f
		this farPlane = 10000.0f
		this _view = FloatTransform3D identity
		this blend = false
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
	_getDefaultMap: virtual func (image: Image) -> GpuMap { this _defaultMap }
	_bind: virtual func
	_unbind: virtual func
	clear: abstract func
	draw: func ~general (action: Func) {
		this _bind()
		this _context setViewport(this viewport)
		this _context enableBlend(this blend)
		action()
		this _unbind()
	}
	draw: func ~WithoutBind (destination: IntBox2D, map: GpuMap) {
		map model = this _createModelTransform(destination)
		map view = this _view
		map projection = this _projection
		this draw(func {
			map use()
			this _context drawQuad()
		})
	}
	draw: virtual func ~GpuImage (image: GpuImage, source: IntBox2D, destination: IntBox2D, map: GpuMap) {
		image bind(0)
		map textureTransform = This _createTextureTransform(image size, source)
		this draw(destination, map)
	}
	draw: func ~Full (image: Image, source: IntBox2D, destination: IntBox2D, map: GpuMap) {
		if (image instanceOf?(GpuImage)) { this draw(image as GpuImage, source, destination, map) }
		else if (image instanceOf?(RasterImage)) {
			temp := this _context createGpuImage(image as RasterImage)
			this draw(temp as GpuImage, source, destination, map)
			temp free()
		}
		else
			Debug raise("Trying to draw unsupported image format to OpenGLES3Canvas!")
	}
	draw: func ~ImageSourceDestination (image: Image, source: IntBox2D, destination: IntBox2D) { this draw(image, source, destination, this _getDefaultMap(image)) }
	draw: func ~ImageDestination (image: Image, destination: IntBox2D) { this draw(image, IntBox2D new(image size), destination) }
	draw: func ~Image (image: Image) { this draw(image, IntBox2D new(image size)) }
	draw: func ~ImageTargetSize (image: Image, targetSize: IntSize2D) { this draw(image, IntBox2D new(targetSize)) }
	draw: func ~ImageMap (image: Image, map: GpuMap) { this draw(image, IntBox2D new(image size), IntBox2D new(image size), map)}
	draw: func ~ImageDestinationMap (image: Image, destination: IntBox2D, map: GpuMap) { this draw(image, IntBox2D new(image size), destination, map) }

	drawLines: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawLines(pointList, this _projection * this _toLocal) }) }
	drawBox: virtual func (box: FloatBox2D) { this draw(func { this _context drawBox(box, this _projection * this _toLocal) }) }
	drawPoints: virtual func (pointList: VectorList<FloatPoint2D>) { this draw(func { this _context drawPoints(pointList, this _projection * this _toLocal) }) }
}
