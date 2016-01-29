/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import ByteBuffer into ByteBuffer
import Image
import RasterImage

RasterPlanar: abstract class extends RasterImage {
	init: func (size: IntVector2D) { super(size) }
	init: func ~fromOriginal (original: This) { super(original) }
}
