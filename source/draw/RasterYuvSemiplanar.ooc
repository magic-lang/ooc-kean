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
import RasterPlanar
import RasterPacked
import RasterImage
import RasterMonochrome
import RasterUv
import Image
import Color

RasterYuvSemiplanar: abstract class extends RasterPlanar {
	_y: RasterMonochrome
	y ::= this _y
	_uv: RasterUv
	uv ::= this _uv
	crop: IntShell2D {
		get
		set (value) {
			this crop = value
			if (this y != null && this uv != null) {
				this y crop = value
				this uv crop = value / 2
			}
		}
	}
	init: func (yImage: RasterMonochrome, uvImage: RasterUv) {
		super(yImage size)
		this _y = yImage
		this _y referenceCount increase()
		this _uv = uvImage
		this _uv referenceCount increase()
	}
	init: func ~fromYuvSemiplanar (original: This, y: RasterMonochrome, uv: RasterUv) {
		super(original)
		this _y = y
		this _y referenceCount increase()
		this _uv = uv
		this _uv referenceCount increase()
	}
	free: override func {
		this y referenceCount decrease()
		this uv referenceCount decrease()
		super()
	}

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
			for (y in 0 .. this size height)
				for (x in 0 .. this size width) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in Int maximum~two(0, y - this distanceRadius) .. Int minimum~two(y + 1 + this distanceRadius, this size height))
							for (otherX in Int maximum~two(0, x - this distanceRadius) .. Int minimum~two(x + 1 + this distanceRadius, this size width))
								if (otherX != x || otherY != y) {
									pixel := (other as This)[otherX, otherY]
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
						distance := 0.0f
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
						result += (distance) sqrt() / 3
					}
				}
			result /= ((this size width squared() + this size height squared()) as Float sqrt())
		}
	}
	abstract operator [] (x, y: Int) -> ColorYuv
	abstract operator []= (x, y: Int, value: ColorYuv)
}
