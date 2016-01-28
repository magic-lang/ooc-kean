/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry

Map: abstract class {
	model: FloatTransform3D { get set }
	view: FloatTransform3D { get set }
	projection: FloatTransform3D { get set }
	textureTransform: FloatTransform3D { get set }
}
