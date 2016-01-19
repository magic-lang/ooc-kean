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

use base
use ooc-math
use ooc-geometry
use ooc-unit

IntShell2DTest: class extends Fixture {
	init: func {
		super("IntShell2D")
		this add("Size and position", func {
			shell := IntShell2D new(1, 2, 3, 4)
			expect(shell size x, is equal to(3))
			expect(shell size y, is equal to(7))
			expect(shell leftTop x, is equal to(1))
			expect(shell leftTop y, is equal to(3))
			expect(shell balance x, is equal to(1))
			expect(shell balance y, is equal to(1))
		})
		this add("isZero, notZero", func {
			shellNotZero := IntShell2D new(2, 3)
			shellZero := IntShell2D new()
			expect(shellNotZero notZero)
			expect(!shellNotZero isZero)
			expect(shellZero isZero)
			expect(!shellZero notZero)
		})
		this add("maximum, minimum", func {
			first := IntShell2D new(1, 2, 3, 4)
			second := IntShell2D new(4, 3, 2, 1)
			third := first maximum(second)
			fourth := first minimum(second)
			thirdEquals := IntShell2D new(4, 3, 3, 4)
			fourthEquals := IntShell2D new(1, 2, 2, 1)
			expect(third == thirdEquals)
			expect(fourth == fourthEquals)
			expect(third != fourth)
			expect(!(third != third))
		})
		this add("+ and - operators", func {
			first := IntShell2D new(4)
			second := IntShell2D new(1, 1, 2, 2)
			added := first + second
			subtracted := first - second
			expect(added left, is equal to(5))
			expect(added right, is equal to(5))
			expect(added top, is equal to(6))
			expect(added bottom, is equal to(6))
			expect(subtracted left, is equal to(3))
			expect(subtracted right, is equal to(3))
			expect(subtracted top, is equal to(2))
			expect(subtracted bottom, is equal to(2))
		})
		this add("increase, decrease (box)", func {
			shell := IntShell2D new(1)
			box := IntBox2D new(1, 2, 3, 4)
			increased := shell increase~byBox(box)
			decreased := shell decrease~byBox(box)
			expect(increased left, is equal to(0))
			expect(increased top, is equal to(1))
			expect(increased right, is equal to(5))
			expect(increased bottom, is equal to(7))
			expect(decreased left, is equal to(2))
			expect(decreased top, is equal to(3))
			expect(decreased right, is equal to(3))
			expect(decreased bottom, is equal to(5))
		})
		this add("increase, decrease (size)", func {
			shell := IntShell2D new(1)
			size := IntVector2D new(1, 2)
			increased := shell increase(size)
			decreased := shell decrease(size)
			expect(increased left, is equal to(-1))
			expect(increased top, is equal to(-1))
			expect(increased right, is equal to(2))
			expect(increased bottom, is equal to(3))
			expect(decreased left, is equal to(0))
			expect(decreased top, is equal to(1))
			expect(decreased right, is equal to(1))
			expect(decreased bottom, is equal to(1))
		})
		this add("parse", func {
			shell := IntShell2D parse(t"1, 2, 3, 4")
			expect(shell left, is equal to(1))
			expect(shell right, is equal to(2))
			expect(shell top, is equal to(3))
			expect(shell bottom, is equal to(4))
		})
		this add("toText", func {
			text := IntShell2D new(1) toText() take()
			expect(text, is equal to(t"1, 1, 1, 1"))
			text free()
		})
	}
}

IntShell2DTest new() run() . free()
