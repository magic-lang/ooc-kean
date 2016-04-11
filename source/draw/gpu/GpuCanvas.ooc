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

import GpuContext, GpuImage, Mesh, GpuYuv420Semiplanar

version(!gpuOff) {
GpuCanvas: abstract class extends Canvas {
	_context: GpuContext
	_defaultMap: Map
	_coordinateTransform := IntTransform2D identity
	init: func (size: IntVector2D, =_context, =_defaultMap, =_coordinateTransform) { super(size) }
	_getDefaultMap: virtual func (image: Image) -> Map { this _defaultMap }
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
