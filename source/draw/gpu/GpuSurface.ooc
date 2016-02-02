/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use draw
use collections
use base

import GpuContext, GpuMap, GpuImage, GpuMesh, GpuYuv420Semiplanar

version(!gpuOff) {
GpuSurface: abstract class extends Canvas {
	_context: GpuContext
	_model: FloatTransform3D
	_view := FloatTransform3D identity
	_projection: FloatTransform3D
	_toLocal := FloatTransform3D createScaling(1.0f, -1.0f, -1.0f)
	_focalLength: Float
	_nearPlane := 1.0f
	_farPlane := 10000.0f
	_defaultMap: GpuMap
	_coordinateTransform := IntTransform2D identity
	transform: FloatTransform3D {
		get { this _transform }
		set(value) {
			this _transform = value
			this _view = this _toLocal * value * this _toLocal
		}
	}
	focalLength: Float {
		get { this _focalLength }
		set(value) {
			this _focalLength = value
			if (this _focalLength > 0.0f) {
				a := 2.0f * this _focalLength / this size x
				f := -(this _coordinateTransform e as Float) * 2.0f * this _focalLength / this size y
				k := (this _farPlane + this _nearPlane) / (this _farPlane - this _nearPlane)
				o := 2.0f * this _farPlane * this _nearPlane / (this _farPlane - this _nearPlane)
				this _projection = FloatTransform3D new(a, 0.0f, 0.0f, 0.0f, 0.0f, f, 0.0f, 0.0f, 0.0f, 0.0f, k, -1.0f, 0.0f, 0.0f, o, 0.0f)
			}
			else
				this _projection = FloatTransform3D createScaling(2.0f / this size x, -(this _coordinateTransform e as Float) * 2.0f / this size y, 1.0f)
			this _model = this _createModelTransform(IntBox2D new(this size))
		}
	}
	init: func (size: IntVector2D, =_context, =_defaultMap, =_coordinateTransform) { super(size) }
	_createModelTransform: func ~LocalInt (box: IntBox2D) -> FloatTransform3D {
		this _createModelTransform(box toFloatBox2D())
	}
	_createModelTransform: func ~LocalFloat (box: FloatBox2D) -> FloatTransform3D {
		toReference := FloatTransform3D createTranslation((box size x - this size x) / 2, (this size y - box size y) / 2, 0.0f)
		translation := this _toLocal * FloatTransform3D createTranslation(box leftTop x, box leftTop y, this focalLength) * this _toLocal
		translation * toReference * FloatTransform3D createScaling(box size x / 2.0f, box size y / 2.0f, 1.0f)
	}
	_createModelTransformNormalized: func (imageSize: IntVector2D, box: FloatBox2D) -> FloatTransform3D {
		this _createModelTransform(box * imageSize toFloatVector2D())
	}
	_getDefaultMap: virtual func (image: Image) -> GpuMap { this _defaultMap }
	clear: func { this fill() }
	draw: virtual func (action: Func)
	draw: virtual func ~WithoutBind (destination: IntBox2D, map: GpuMap)
	draw: abstract func ~GpuImage (image: GpuImage, source, destination: IntBox2D, map: GpuMap)
	draw: func ~ImageMap (image: GpuImage, map: GpuMap) { this draw~GpuImage(image, IntBox2D new(image size), IntBox2D new(image size), map) }
	draw: func ~ImageDestinationMap (image: GpuImage, destination: IntBox2D, map: GpuMap) { this draw~GpuImage(image, IntBox2D new(image size), destination, map) }
	draw: override func ~ImageSourceDestination (image: Image, source, destination: IntBox2D) {
		map := this _getDefaultMap(image)
		temporary: GpuImage = null
		if (image instanceOf?(GpuImage))
			temporary = image as GpuImage
		else if (image instanceOf?(RasterImage))
			temporary = this _context createImage(image as RasterImage)
		else
			Debug raise("Invalid image type in GpuSurface!")
		if (temporary instanceOf?(GpuYuv420Semiplanar)) {
			yuv := temporary as GpuYuv420Semiplanar
			map add("texture0", yuv y)
			map add("texture1", yuv uv)
		} else
			map add("texture0", temporary)
		this draw(temporary, source, destination, map)
		if (image != temporary)
			temporary free()
	}
	draw: virtual func ~mesh (image: GpuImage, mesh: GpuMesh) { Debug raise("draw~mesh unimplemented!") }
	_createTextureTransform: static func ~LocalInt (imageSize: IntVector2D, box: IntBox2D) -> FloatTransform3D {
		This _createTextureTransform(imageSize toFloatVector2D(), box toFloatBox2D())
	}
	_createTextureTransform: static func ~LocalFloat (imageSize: FloatVector2D, box: FloatBox2D) -> FloatTransform3D {
		This _createTextureTransform(box / imageSize)
	}
	_createTextureTransform: static func ~Normalized (normalizedBox: FloatBox2D) -> FloatTransform3D {
		scaling := FloatTransform3D createScaling(normalizedBox size x, normalizedBox size y, 1.0f)
		translation := FloatTransform3D createTranslation(normalizedBox leftTop x, normalizedBox leftTop y, 0.0f)
		translation * scaling
	}
}
}
