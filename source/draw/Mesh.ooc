/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */
use geometry

Mesh: abstract class {
	init: func
	draw: abstract func
	update: virtual func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[]) {
		Debug error("Mesh update unimplemented for class %s" format(this class name))
	}
}
