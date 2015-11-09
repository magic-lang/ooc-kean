//
// Copyright (c) 2011-2014 Simon Mika <simon@mika.se>
//
// This program is free software: you can redistribute it and/or modify
// it under the terms of the GNU Lesser General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
// GNU Lesser General Public License for more details.
//
// You should have received a copy of the GNU Lesser General Public License
// along with this program. If not, see <http://www.gnu.org/licenses/>.

use ooc-math
use ooc-base
import math
import Image
import RasterBgra, RasterMonochrome, RasterBgr
import Color
import StbImage

RasterImage: abstract class extends Image {
	distanceRadius: Int { get { return 1; } }
	stride: UInt { get }
	init: func ~fromRasterImage (original: This) { super(original) }
	init: func (size: IntSize2D) { super(size) }
	apply: abstract func ~bgr (action: Func (ColorBgr))
	apply: abstract func ~yuv (action: Func (ColorYuv))
	apply: abstract func ~monochrome (action: Func (ColorMonochrome))
	resizeTo: func (size: IntSize2D) -> Image {
		result : Image
//	TODO: Actually resize the image
		resized := this
		result = resized
		result
	}
	copy: abstract func -> This
	copy: func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> This {
		transform = (this transform toFloatTransform2D()) * transform * (this transform toFloatTransform2D()) inverse
		mappingTransform := FloatTransform2D createTranslation(this size width / 2, this size height / 2) * transform
		upperLeft := mappingTransform * FloatPoint2D new(-size width / 2, -size width / 2)
		upperRight := mappingTransform * FloatPoint2D new(size width / 2, -size width / 2)
		downLeft := mappingTransform * FloatPoint2D new(-size width / 2, size width / 2)
		downRight := mappingTransform * FloatPoint2D new(size width / 2, size width / 2)
		source := FloatBox2D bounds([upperLeft, upperRight, downLeft, downRight])
		mappingTransformInverse := mappingTransform inverse
		upperLeft = mappingTransformInverse * source leftTop
		upperRight = mappingTransformInverse * source rightTop
		downLeft = mappingTransformInverse * source leftBottom
		downRight = mappingTransformInverse * source rightBottom
		this copy(size toFloatSize2D(), source, FloatPoint2D new(), FloatPoint2D new(), FloatPoint2D new())
	}
	copy: func ~fromMoreParams (size: FloatSize2D, source: FloatBox2D, upperLeft, upperRight, lowerLeft: FloatPoint2D) -> This {
		result := RasterBgra new(size ceiling() toIntSize2D())
//		TODO: The stuff
		result
	}
	open: static func ~unknownType (filename: String) -> This {
		x, y, imageComponents: Int
		data := StbImage load(filename, x&, y&, imageComponents&, 0)
		result: This
		match (imageComponents) {
			case 1 =>
				result = RasterMonochrome new(ByteBuffer new(data as UInt8*, x * y * imageComponents), IntSize2D new (x, y))
			case 3 =>
				result = RasterBgr new(ByteBuffer new(data as UInt8*, x * y * imageComponents), IntSize2D new (x, y))
			case 4 =>
				result = RasterBgra new(ByteBuffer new(data as UInt8*, x * y * imageComponents), IntSize2D new (x, y))
			case =>
				raise("Unsupported number of channels in image")
		}
		result
	}
	save: virtual func (filename: String) -> Int { Debug raise("RasterImage save unimplemented for format!"); 0 }
	kean_draw_rasterImage_getStride: unmangled func -> UInt { this stride }
	kean_draw_rasterImage_save: unmangled func (path: const Char*) {
		pathString := String new(path)
		this save(pathString)
		pathString free()
	}
}
