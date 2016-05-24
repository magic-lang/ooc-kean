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
	init: func (size: IntVector2D, =_context, =_defaultMap) { super(size) }
	_getDefaultMap: virtual func (image: Image) -> Map { this _defaultMap }
}
}
