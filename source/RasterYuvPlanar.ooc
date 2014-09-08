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
import structs/ArrayList
import RasterPlanar
import RasterPacked
import RasterImage
import RasterMonochrome
import Image
import Color

RasterYuvPlanar: abstract class extends RasterPlanar implements IDisposable {
	y, u, v: RasterMonochrome
	crop: IntShell2D {
		get
		set (value) {
			this crop = value
			if (this y != null && this u != null && this v != null) {
				this y crop = value
				this u crop = value / 2
				this v crop = value / 2
			}
		}
	}
	init: func (buffer: ByteBuffer, size: IntSize2D, coordinateSystem: CoordinateSystem, crop: IntShell2D) {
//		"RasterYuvPlanar init ~fromEverything" println()
		super(buffer, size, coordinateSystem, crop)
		this y = this createY()
		this u = this createU()
		this v = this createV()
	}
	init: func ~fromYuvPlanar (original: This) { 
		super(original) 
		this y = this createY()
		this u = this createU()
		this v = this createV()
	}
	createY: abstract func -> RasterMonochrome
	createU: abstract func -> RasterMonochrome
	createV: abstract func -> RasterMonochrome

	apply: func ~bgr (action: Func (ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: func ~monochrome (action: Func (ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))		
	}
	distance: func (other: Image) -> Float {
		result := 0.0f
		if (!other)
			result = Float maximumValue
//		else if (!other instanceOf?(This))
//			FIXME
//		else if (this size != other size)
//			FIXME
		else {
			for (y in 0..this size height)
				for (x in 0..this size width) {
					c := this[x, y]
					o := (other as RasterYuvPlanar)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum(0, y - this distanceRadius)..Int minimum(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum(0, x - this distanceRadius)..Int minimum(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y)	{
									pixel := (other as RasterYuvPlanar)[otherX, otherY]
									if (maximum y < pixel y)
										maximum y = pixel y
									else if (minimum y > pixel y)
										minimum y = pixel y
									if (maximum u < pixel u)
										maximum u = pixel u
									else if (minimum u > pixel u)
										minimum u = pixel u
									if (maximum v < pixel v)
										maximum v = pixel v
									else if (minimum v > pixel v)
										minimum v = pixel v
								}
						distance := 0.0f;
						if (c y < minimum y)
							distance += (minimum y - c y) as Float squared()
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared()
						if (c u < minimum u)
							distance += (minimum u - c u) as Float squared()
						else if (c u > maximum u)
							distance += (c u - maximum u) as Float squared()
						if (c v < minimum v)
							distance += (minimum v - c v) as Float squared()
						else if (c v > maximum v)
							distance += (c v - maximum v) as Float squared()
						result += (distance) sqrt() / 3;
					}
				}
			result /= ((this size width squared() + this size height squared()) as Float sqrt())
		}
	}
//	FIXME
//	openResource(assembly: ???, name: String) {
//		Image openResource
//	}
	abstract operator [] (x, y: Int) -> ColorYuv {}
	abstract operator []= (x, y: Int, value: ColorYuv) {}
	dispose: func
}
