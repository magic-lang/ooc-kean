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

use ooc-math
use ooc-unit
import math

FloatPoint2DVectorListTest: class extends Fixture {
	init: func {
		super("FloatPoint2DVectorList")
		tolerance := 0.0001f
		this add("sum and mean", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			list add(FloatPoint2D new(7.0f, -1.0f))
			sum := list sum()
			mean := list mean()
			expect(sum x, is equal to(16.0f) within(tolerance))
			expect(sum y, is equal to(1.0f) within(tolerance))
			expect(mean x, is equal to(4.0f) within(tolerance))
			expect(mean y, is equal to(0.25f) within(tolerance))
			list free()
		})
		this add("getX, getY", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			list add(FloatPoint2D new(7.0f, -1.0f))
			xValues := list getX()
			yValues := list getY()
			expect(xValues sum, is equal to(16.0f) within(tolerance))
			expect(yValues sum, is equal to(1.0f) within(tolerance))
			list free()
			xValues free()
			yValues free()
		})
		this add("+ operator", func {
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(1.0f, 2.0f))
			list add(FloatPoint2D new(3.0f, 2.0f))
			list add(FloatPoint2D new(5.0f, -2.0f))
			added := list + FloatPoint2D new(1.0f, 1.0f)
			expect(added getX() sum, is equal to(12.0f) within(tolerance))
			expect(added getY() sum, is equal to(5.0f) within(tolerance))
			list free()
		})
	}
}

FloatPoint2DVectorListTest new() run()
