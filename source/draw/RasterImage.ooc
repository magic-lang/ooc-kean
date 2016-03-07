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
		result : Image
//	TODO: Actually resize the image
		resized := this
		result = resized
		result
	}
	copy: abstract func -> This
	copy: override func ~fromParams (size: IntVector2D, transform: FloatTransform2D) -> This {
		transform = (this transform toFloatTransform2D()) * transform * (this transform toFloatTransform2D()) inverse
		mappingTransform := FloatTransform2D createTranslation(this size toFloatVector2D() / 2) * transform
		upperLeft := mappingTransform * FloatPoint2D new(-size x / 2, -size x / 2)
		upperRight := mappingTransform * FloatPoint2D new(size x / 2, -size x / 2)
		downLeft := mappingTransform * FloatPoint2D new(-size x / 2, size x / 2)
		downRight := mappingTransform * FloatPoint2D new(size x / 2, size x / 2)
		source := FloatBox2D bounds([upperLeft, upperRight, downLeft, downRight])
		mappingTransformInverse := mappingTransform inverse
		upperLeft = mappingTransformInverse * source leftTop
		upperRight = mappingTransformInverse * source rightTop
		downLeft = mappingTransformInverse * source leftBottom
		downRight = mappingTransformInverse * source rightBottom
		this copy(size toFloatVector2D(), source, FloatPoint2D new(), FloatPoint2D new(), FloatPoint2D new())
	}
	copy: func ~fromMoreParams (size: FloatVector2D, source: FloatBox2D, upperLeft, upperRight, lowerLeft: FloatPoint2D) -> This {
		result := RasterRgba new(size ceiling() toIntVector2D())
//		TODO: The stuff
		result
	}
	save: virtual func (filename: String) -> Int { Debug error("RasterImage save unimplemented for format!"); 0 }
	kean_draw_rasterImage_getStride: unmangled func -> UInt { this stride }
	kean_draw_rasterImage_save: unmangled func (path: const Char*) {
		pathString := String new(path)
		this save(pathString)
		pathString free()
	}
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
