/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use base
use math
use geometry
use unit

FloatShell2DTest: class extends Fixture {
	init: func {
		super("FloatShell2D")
		tolerance := 0.0001f
		this add("fixture", func {
			expect(FloatShell2D new(1.0f, 2.0f, 3.0f, 4.0f), is equal to(FloatShell2D new(1.0f, 2.0f, 3.0f, 4.0f)))
		})
		this add("Size and position", func {
			shell := FloatShell2D new(1.0f, 2.0f, 3.0f, 4.0f)
			expect(shell size x, is equal to(3.0f) within(tolerance))
			expect(shell size y, is equal to(7.0f) within(tolerance))
			expect(shell leftTop x, is equal to(1.0f) within(tolerance))
			expect(shell leftTop y, is equal to(3.0f) within(tolerance))
			expect(shell balance x, is equal to(1.0f) within(tolerance))
			expect(shell balance y, is equal to(1.0f) within(tolerance))
		})
		this add("isZero, notZero", func {
			shellNotZero := FloatShell2D new(2.0f, 3.0f)
			shellZero := FloatShell2D new()
			expect(shellNotZero notZero, is true)
			expect(shellNotZero isZero, is false)
			expect(shellZero isZero, is true)
			expect(shellZero notZero, is false)
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
			expect(third != fourth, is true)
			expect(third != third, is false)
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
			expect(subtracted left, is equal to(3.0f) within(tolerance))
			expect(subtracted right, is equal to(2.5f) within(tolerance))
			expect(subtracted top, is equal to(2.0f) within(tolerance))
			expect(subtracted bottom, is equal to(1.5f) within(tolerance))
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
			size := FloatVector2D new(1.0f, 2.0f)
			increased := shell increase(size)
			decreased := shell decrease(size)
			expect(increased left, is equal to(-1.0f) within(tolerance))
			expect(increased top, is equal to(-1.0f) within(tolerance))
			expect(increased right, is equal to(2.0f) within(tolerance))
			expect(increased bottom, is equal to(3.0f) within(tolerance))
			expect(decreased left, is equal to(0.0f) within(tolerance))
			expect(decreased top, is equal to(1.0f) within(tolerance))
			expect(decreased right, is equal to(1.0f) within(tolerance))
			expect(decreased bottom, is equal to(1.0f) within(tolerance))
		})
		this add("parse", func {
			shell := FloatShell2D parse("1.0, 2.0, 3.0, 4.0")
			expect(shell left, is equal to(1.0f) within(tolerance))
			expect(shell right, is equal to(2.0f) within(tolerance))
			expect(shell top, is equal to(3.0f) within(tolerance))
			expect(shell bottom, is equal to(4.0f) within(tolerance))
		})
	}
}

FloatShell2DTest new() run() . free()
