/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import Image
import RasterMonochrome, RasterRgb, RasterRgba
import Color
import StbImage

RasterImage: abstract class extends Image {
	distanceRadius ::= 1
	stride: UInt { get }
	init: func ~fromRasterImage (original: This) { super(original) }
	init: func (size: IntVector2D) { super(size) }
	apply: abstract func ~rgb (action: Func (ColorRgb))
	apply: abstract func ~yuv (action: Func (ColorYuv))
	apply: abstract func ~monochrome (action: Func (ColorMonochrome))
	resizeTo: override func (size: IntVector2D) -> Image {
		raise("resizeTo unimplemented for " + this class name)
		null
	}
	copy: abstract func -> This
	save: virtual func (filename: String) -> Int { Debug error("RasterImage save unimplemented for format!"); 0 }
	open: static func ~unknownType (filename: String) -> This {
		result: This
		(buffer, size, imageComponents) := StbImage load(filename)
		match (imageComponents) {
			case 1 =>
				result = RasterMonochrome new(buffer, size)
			case 3 =>
				result = RasterRgb new(buffer, size)
			case 4 =>
				result = RasterRgba new(buffer, size)
				(result as RasterRgba) swapRedBlue()
			case =>
				buffer free()
				raise("Unsupported number of channels in image")
		}
		result
	}
}
