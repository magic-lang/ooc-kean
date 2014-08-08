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
//import ooc-base/Buffer into Buffer
import math
import structs/ArrayList
import Image
import RasterBgra

RasterImage: abstract class extends Image {
	buffer: ByteBuffer { get set }
	pointer: UInt8* { get { buffer pointer } }
	length: Int { get { buffer size } }
	apply: abstract func ~bgr (action: Func<ColorBgr>)
	apply: abstract func ~yuv (action: Func<ColorYuv>)
	apply: abstract func ~monochrome (action: Func<ColorMonochrome>)
	init: func ~fromRasterImage (original: RasterImage) { 
		super(original) 
		this buffer = original buffer copy()
	}
	init: func (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
		super(size, coordinateSystem, crop, false)
		this buffer = buffer
	}
	resizeTo: func (size: IntSize2D) -> Image {
		result : Image
//	TODO: Actually resize the image
		resized := this
		result = resized
		result		
	}
	copy: func ~fromParams (size: IntSize2D, transform: FloatTransform2D) -> Image {
		transform = (this transform asFloatTransform2D()) * transform * (this transform asFloatTransform2D()) Inverse()
		mappingTransform := FloatTransform2D createTranslation(this size width / 2, this size height / 2) * transform
		upperLeft := mappingTransform * FloatPoint2D new(-size width / 2, -size width / 2)
		upperRight := mappingTransform * FloatPoint2D new(size width / 2, -size width / 2)
		downLeft := mappingTransform * FloatPoint2D new(-size width / 2, size width / 2)
		downRight := mappingTransform * FloatPoint2D new(size width / 2, size width / 2)
		source := FloatBox2D bounds(upperLeft, upperRight, downLeft, downRight)
		mappingTransformInverse := mappingTransform Inverse()
		upperLeft = mappingTransformInverse * source leftTop
		upperRight = mappingTransformInverse * source rightTop
		downLeft = mappingTransformInverse * source leftBottom
		downRight = mappingTransformInverse * source rightBottom
		this copy(size, source, upperLeft, upperRight, downLeft)
	}
	copy: func (size: FloatSize2D, source: FloatBox2D, upperLeft, upperRight, lowerLeft: FloatPoint2D) -> RasterImage {
		result := RasterBgra new(size ceiling() asIntSize2D())
//		TODO: The stuff
		result
	}
}
