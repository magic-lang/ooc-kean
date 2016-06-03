/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use collections
use geometry
use unit

FloatConvexHull2DTest: class extends Fixture {
	init: func {
		super("FloatConvexHull2D")
		this add("contains, triangle", func {
			trianglePoints := VectorList<FloatPoint2D> new()
			trianglePoints add(FloatPoint2D new(0.0f, 0.0f))
			trianglePoints add(FloatPoint2D new(0.0f, 1.0f))
			trianglePoints add(FloatPoint2D new(1.0f, 0.0f))
			hull := FloatConvexHull2D new(trianglePoints, false)
			expect(hull contains(FloatPoint2D new(0.1f, 0.1f)), is true)
			expect(hull contains(FloatPoint2D new(0.7f, 0.7f)), is false)
			expect(hull contains(FloatPoint2D new(0.9f, 0.01f)), is true)
			expect(hull contains(FloatPoint2D new(-0.1f, 0.0f)), is false)
			expect(hull count, is equal to(3))
			hull free()
		})
		this add("contains, square", func {
			square := FloatBox2D new(1.0f, 1.0f, 3.0f, 4.0f)
			hull := FloatConvexHull2D new(square)
			expect(hull count, is equal to(4))
			expect(hull contains(FloatPoint2D new(1.0f, 1.0f)), is true)
			expect(hull contains(FloatPoint2D new(2.0f, 2.0f)), is true)
			expect(hull contains(FloatPoint2D new(3.9f, 4.9f)), is true)
			expect(hull contains(FloatPoint2D new(4.1f, 4.9f)), is false)
			expect(hull contains(FloatPoint2D new(3.9f, 5.1f)), is false)
			hull free()
		})
		this add("hull computation", func {
			points := VectorList<FloatPoint2D> new()
			points add(FloatPoint2D new(1.0f, 0.0f)) // hull
			points add(FloatPoint2D new(-1.0f, 0.0f)) // hull
			points add(FloatPoint2D new(-1.0f, -1.0f)) // hull
			points add(FloatPoint2D new(-0.9f, -0.5f)) // inside
			points add(FloatPoint2D new(0.0f, 1.0f)) // inside
			points add(FloatPoint2D new(0.0f, 0.0f)) // inside
			points add(FloatPoint2D new(0.0f, -1.0f)) // hull
			points add(FloatPoint2D new(0.5f, 2.0f)) // hull
			points add(FloatPoint2D new(-0.5f, 0)) // inside

			convexHull := FloatConvexHull2D new(points)
			expect(convexHull count, is equal to(5))
			expect(convexHull contains(FloatPoint2D new(0.0f, 0.0f)), is true)
			expect(convexHull contains(FloatPoint2D new(0.5f, 1.5f)), is true)
			expect(convexHull contains(FloatPoint2D new(-0.5f, 1.5f)), is false)
			expect(convexHull contains(FloatPoint2D new(-0.5f, 0.05f)), is true)
			expect(convexHull contains(FloatPoint2D new(-0.9f, -0.9f)), is true)
			expect(convexHull contains(FloatPoint2D new(-1.01f, -1.0f)), is false)
			convexHull free()
		})
		this add("contains, hull", func {
			bigSquare := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			bigHull := FloatConvexHull2D new(bigSquare)
			smallSquare := FloatBox2D new(2.0f, 2.0f, 2.0f, 2.0f)
			smallHull := FloatConvexHull2D new(smallSquare)
			expect(bigHull contains(smallHull), is true)
			expect(smallHull contains(bigHull), is false)
			(smallHull, bigHull) free()
		})
		this add("toString", func {
			square := FloatBox2D new(1.0f, 1.0f, 3.0f, 4.0f)
			hull := FloatConvexHull2D new(square)
			expect(hull count, is equal to(4))
			string := hull toString()
			expect(string == "(1.00, 1.00) (1.00, 5.00) (4.00, 5.00) (4.00, 1.00) ")
			(string, hull) free()
		})
	}
}

FloatConvexHull2DTest new() run() . free()
