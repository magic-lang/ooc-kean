/*
 * Copyright (C) 2014 - Simon Mika <simon@mika.se>
 *
 * This sofware is free software; you can redistribute it and/or
 * modify it under the terms of the GNU Lesser General Public
 * License as published by the Free Software Foundation; either
 * version 2.1 of the License, or (at your option) any later version.
 *
 * This software is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 * Lesser General Public License for more details.
 *
 * You should have received a copy of the GNU Lesser General Public License
 * along with this software. If not, see <http://www.gnu.org/licenses/>.
 */

use ooc-collections
use ooc-math
use ooc-unit
import math

FloatConvexHull2DTest: class extends Fixture {
	init: func {
		super("FloatConvexHull2D")
		tolerance := 0.0001f
		
		this add("contains, triangle", func {
			trianglePoints := VectorList<FloatPoint2D> new()
			trianglePoints add(FloatPoint2D new(0.0f, 0.0f))
			trianglePoints add(FloatPoint2D new(0.0f, 1.0f))
			trianglePoints add(FloatPoint2D new(1.0f, 0.0f))
			hull := FloatConvexHull2D new(trianglePoints)
			expect(hull contains(FloatPoint2D new(0.1f, 0.1f)), is equal to(true))
			expect(hull contains(FloatPoint2D new(0.7f, 0.7f)), is equal to(false))
			expect(hull contains(FloatPoint2D new(0.9f, 0.01f)), is equal to(true))
			expect(hull contains(FloatPoint2D new(-0.1f, 0.0f)), is equal to(false))
			expect(hull count, is equal to(3))
			expect(hull points == trianglePoints)
			hull free()
		})
		
		this add("contains, square", func {
			square := FloatBox2D new(1.0f, 1.0f, 3.0f, 4.0f)
			hull := FloatConvexHull2D new(square)
			expect(hull count, is equal to(4))
			expect(hull contains(FloatPoint2D new(1.0f, 1.0f)), is equal to(true))
			expect(hull contains(FloatPoint2D new(2.0f, 2.0f)), is equal to(true))
			expect(hull contains(FloatPoint2D new(3.9f, 4.9f)), is equal to(true))
			expect(hull contains(FloatPoint2D new(4.1f, 4.9f)), is equal to(false))
			expect(hull contains(FloatPoint2D new(3.9f, 5.1f)), is equal to(false))
			hull free()
		})
		
		this add("contains, hull", func {
			bigSquare := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			bigHull := FloatConvexHull2D new(bigSquare)
			smallSquare := FloatBox2D new(2.0f, 2.0f, 2.0f, 2.0f)
			smallHull := FloatConvexHull2D new(smallSquare)
			expect(bigHull contains(smallHull), is equal to(true))
			expect(smallHull contains(bigHull), is equal to(false))
		})
		
		this add("toString", func {
			square := FloatBox2D new(1.0f, 1.0f, 3.0f, 4.0f)
			hull := FloatConvexHull2D new(square)
			expect(hull count, is equal to(4))
			expect(hull toString() == "(1.00, 1.00) (1.00, 5.00) (4.00, 5.00) (4.00, 1.00) ")
			hull free()
		})
	}
}

FloatConvexHull2DTest new() run()
