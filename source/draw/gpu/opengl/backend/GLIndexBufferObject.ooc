/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016-2017 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

 use geometry

GLIndexBufferObject: abstract class {
	init: func
	bind: abstract func
	unbind: abstract func
	draw: abstract func
	update: abstract func (vertices: FloatPoint3D[], textureCoordinates: FloatPoint2D[])
}
