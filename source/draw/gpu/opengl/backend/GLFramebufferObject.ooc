/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use draw
use geometry

version(!gpuOff) {
GLFramebufferObject: abstract class {
	_size: IntVector2D
	_backend: UInt
	size ::= this _size

	init: func (=_size)
	bind: abstract func
	unbind: abstract func
	clear: abstract func
	setClearColor: abstract func (color: ColorRgba)
	readPixels: abstract func (target: RasterPacked)
	invalidate: abstract func
}
}
