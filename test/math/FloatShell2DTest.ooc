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

FloatShell2DTest: class extends Fixture {
	init: func {
		super("FloatShell2D")
		tolerance := 0.0001f
		this add("Size and position", func {
			shell := FloatShell2D new(1.0f, 2.0f, 3.0f, 4.0f)
			expect(shell size width, is equal to(3.0f) within(tolerance))
			expect(shell size height, is equal to(7.0f) within(tolerance))
			expect(shell leftTop x, is equal to(1.0f) within(tolerance))
			expect(shell leftTop y, is equal to(3.0f) within(tolerance))
			expect(shell balance x, is equal to(1.0f) within(tolerance))
			expect(shell balance y, is equal to(1.0f) within(tolerance))
		})
		this add("isZero, notZero", func {
			shellNotZero := FloatShell2D new(2.0f, 3.0f)
			shellZero := FloatShell2D new()
			expect(shellNotZero notZero)
			expect(!shellNotZero isZero)
			expect(shellZero isZero)
			expect(!shellZero notZero)
		})
		this add("maximum, minimum", func {
			first := FloatShell2D new(1.0f, 2.0f, 3.0f, 4.0f)
			second := FloatShell2D new(4.0f, 3.0f, 2.0f, 1.0f)
			third := first maximum(second)
			fourth := first minimum(second)
			thirdEquals := FloatShell2D new(4.0f, 3.0f, 3.0f, 4.0f)
			fourthEquals := FloatShell2D new(1.0f, 2.0f, 2.0f, 1.0f)
			expect(third == thirdEquals)
			expect(fourth == fourthEquals)
			expect(third != fourth)
			expect(!(third != third))
		})
		this add("+ and - operators", func {
			first := FloatShell2D new(4.0f)
			second := FloatShell2D new(1.0f, 1.5f, 2.0f, 2.5f)
			added := first + second
			subtracted := first - second
			expect(added left, is equal to(5.0f) within(tolerance))
			expect(added right, is equal to(5.5f) within(tolerance))
			expect(added top, is equal to(6.0f) within(tolerance))
			expect(added bottom, is equal to(6.5f) within(tolerance))
		})
		this add("increase, decrease (box)", func {
			shell := FloatShell2D new(1.0f)
			box := FloatBox2D new(1.0f, 2.0f, 3.0f, 4.0f)
			increased := shell increase~byBox(box)
			decreased := shell decrease~byBox(box)
			expect(increased left, is equal to(0.0f) within(tolerance))
			expect(increased top, is equal to(1.0f) within(tolerance))
			expect(increased right, is equal to(5.0f) within(tolerance))
			expect(increased bottom, is equal to(7.0f) within(tolerance))
			expect(decreased left, is equal to(2.0f) within(tolerance))
			expect(decreased top, is equal to(3.0f) within(tolerance))
			expect(decreased right, is equal to(3.0f) within(tolerance))
			expect(decreased bottom, is equal to(5.0f) within(tolerance))
		})
		this add("increase, decrease (size)", func {
			shell := FloatShell2D new(1.0f)
			size := FloatSize2D new(1.0f, 2.0f)
			increased := shell increase(size)
			decreased := shell decrease(size)
			expect(increased left, is equal to(-1.0f) within(tolerance))
			expect(increased top, is equal to(-1.0f) within(tolerance))
			expect(increased right, is equal to(2.0f) within(tolerance))
			expect(increased bottom, is equal to(3.0f) within(tolerance))
			expect(decreased left, is equal to(1.0f) within(tolerance))
			expect(decreased top, is equal to(1.0f) within(tolerance))
			expect(decreased right, is equal to(0.0f) within(tolerance))
			expect(decreased bottom, is equal to(1.0f) within(tolerance))
		})
	}
}

FloatShell2DTest new() run()
