/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use geometry
use base
import RasterPlanar
import RasterPacked
import RasterImage
import RasterMonochrome
import RasterUv
import Image
import Color

RasterYuvSemiplanar: abstract class extends RasterPlanar {
	_y: RasterMonochrome
	_uv: RasterUv
	y ::= this _y
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

	apply: override func ~bgr (action: Func (ColorBgr)) {
		this apply(ColorConvert fromYuv(action))
	}
	apply: override func ~monochrome (action: Func (ColorMonochrome)) {
		this apply(ColorConvert fromYuv(action))
	}
	distance: override func (other: Image) -> Float {
		result := 0.0f
		if (!other || (this size != other size) || !other instanceOf?(This))
			result = Float maximumValue
		else {
			for (y in 0 .. this size y)
				for (x in 0 .. this size x) {
					c := this[x, y]
					o := (other as This)[x, y]
					if (c distance(o) > 0) {
						maximum := o
						minimum := o
						for (otherY in 0 maximum(y - this distanceRadius) .. (y + 1 + this distanceRadius) minimum(this size y))
							for (otherX in 0 maximum(x - this distanceRadius) .. (x + 1 + this distanceRadius) minimum(this size x))
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
							distance += (minimum y - c y) as Float squared
						else if (c y > maximum y)
							distance += (c y - maximum y) as Float squared
						if (c u < minimum u)
							distance += (minimum u - c u) as Float squared
						else if (c u > maximum u)
							distance += (c u - maximum u) as Float squared
						if (c v < minimum v)
							distance += (minimum v - c v) as Float squared
						else if (c v > maximum v)
							distance += (c v - maximum v) as Float squared
						result += (distance) sqrt() / 3
					}
				}
			result /= this size length
		}
	}

	abstract operator [] (x, y: Int) -> ColorYuv
	abstract operator []= (x, y: Int, value: ColorYuv)
}
