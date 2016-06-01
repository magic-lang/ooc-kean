/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry
use base

IntBox2DTest: class extends Fixture {
	box0 := IntBox2D new (1, 2, 3, 4)
	box1 := IntBox2D new (4, 3, 2, 1)
	box2 := IntBox2D new (2, 1, 4, 3)
	init: func {
		super("IntBox2D")
		this add("fixture", func {
			expect(this box0, is equal to(this box0))
		})
		this add("equality", func {
			box := IntBox2D new()
			expect(this box0 == this box0, is true)
			expect(this box0 != this box1, is true)
			expect(this box0 == box, is false)
			expect(box == box, is true)
			expect(box == this box0, is false)
		})
		this add("leftTop", func {
			leftTop := this box0 leftTop
			expect(leftTop x, is equal to(1))
			expect(leftTop y, is equal to(2))
		})
		this add("size", func {
			size := this box0 size
			expect(size x, is equal to(3))
			expect(size y, is equal to(4))
		})
		this add("addition, union", func {
			result := this box0 + this box1
			expect(result left, is equal to(1))
			expect(result top, is equal to(2))
			expect(result width, is equal to(5))
			expect(result height, is equal to(4))
			expect(result == this box0 union(this box1))
		})
		this add("subtraction, intersection", func {
			result := this box0 - this box2
			other := this box2 - this box0
			expect(result == other)
			expect(result top, is equal to(2))
			expect(result left, is equal to(2))
			expect(result width, is equal to(2))
			expect(result height, is equal to(2))
			expect(result == this box0 intersection(this box2))
		})
		this add("casts", func {
			floatBox := this box0 toFloatBox2D()
			expect(floatBox left, is equal to(1.0f) within(0.01f))
			expect(floatBox top, is equal to(2.0f) within(0.01f))
			expect(floatBox right, is equal to(4.0f) within(0.01f))
			expect(floatBox bottom, is equal to(6.0f) within(0.01f))
		})
		this add("swap", func {
			swapped := this box0 swap()
			expect(swapped top, is equal to(this box0 left))
			expect(swapped left, is equal to(this box0 top))
			expect(swapped width, is equal to(this box0 height))
			expect(swapped height, is equal to(this box0 width))
		})
		this add("pad and shrink ~fraction", func {
			padding := 2
			box := IntBox2D new(-2, -1, 3, 3)
			paddedBox := box pad(padding)
			expect(paddedBox left, is equal to(box left - padding))
			expect(paddedBox top, is equal to(box top - padding))
			expect(paddedBox width, is equal to(box width + 2*padding))
			expect(paddedBox height, is equal to(box height + 2*padding))
		})
		this add("bounds", func {
			points := VectorList<IntPoint2D> new()
			points add(IntPoint2D new(1, 2))
			points add(IntPoint2D new(-1, -2))
			points add(IntPoint2D new(1, 3))
			points add(IntPoint2D new(-2, 4))
			points add(IntPoint2D new(0, 0))
			points add(IntPoint2D new(-1, 3))
			box := IntBox2D bounds(points)
			expect(box left, is equal to(-2))
			expect(box top, is equal to(-2))
			expect(box right, is equal to(1))
			expect(box bottom, is equal to(4))
			points free()
		})
		this add("contains~FloatPoint2DVectorList", func {
			box := IntBox2D new(-2, -1, 3, 3)
			inside := IntPoint2D new(0, 1)
			outside := FloatPoint2D new(-2.0f, 2.0f)
			expect(box contains(inside), is true)
			expect(box contains(outside), is false)
		})
		this add("toString", func {
			string := this box0 toString()
			expect(string, is equal to("1, 2, 3, 4"))
			string free()
		})
		this add("parse", func {
			box := IntBox2D parse("1, 2, 3, 4")
			expect(box left, is equal to(1))
			expect(box top, is equal to(2))
			expect(box right, is equal to(1 + 3))
			expect(box bottom, is equal to(2 + 4))
		})
		this add("createAround", func {
			box := IntBox2D createAround(IntPoint2D new(1, 1), IntVector2D new(4, 4))
			expect(box left, is equal to(-1))
			expect(box top, is equal to(-1))
			expect(box right, is equal to(3))
			expect(box bottom, is equal to(3))
		})
		this add("resizeTo", func {
			box := IntBox2D new(1, 1, 4, 4)
			changedBox := box resizeTo(IntVector2D new(2, 2))
			expect(changedBox left, is equal to(2))
			expect(changedBox right, is equal to(4))
			expect(changedBox top, is equal to(2))
			expect(changedBox bottom, is equal to(4))
		})
		this add("scale", func {
			box := IntBox2D new(1, 1, 4, 4)
			doubledBox := box scale(2.0f)
			halfBox := box scale(0.5f)
			expect(doubledBox left, is equal to(-1))
			expect(doubledBox right, is equal to(7))
			expect(doubledBox top, is equal to(-1))
			expect(doubledBox bottom, is equal to(7))
			expect(halfBox left, is equal to(2))
			expect(halfBox right, is equal to(4))
			expect(halfBox top, is equal to(2))
			expect(halfBox bottom, is equal to(4))
		})
		this add("enlarge", func {
			box := IntBox2D new(1, 1, 4, 4)
			enlargedBox := box enlargeTo(IntVector2D new(6, 6))
			notEnlargedBox := box enlargeTo(IntVector2D new(3, 3))
			expect(enlargedBox left, is equal to(0))
			expect(enlargedBox top, is equal to(0))
			expect(enlargedBox right, is equal to(6))
			expect(enlargedBox bottom, is equal to(6))
			expect(notEnlargedBox == box, is true)
		})
		this add("reduce", func {
			box := IntBox2D new(1, 1, 4, 4)
			reducedBox := box shrinkTo(IntVector2D new(2, 2))
			notReducedBox := box shrinkTo(IntVector2D new(6, 6))
			expect(reducedBox left, is equal to(2))
			expect(reducedBox top, is equal to(2))
			expect(reducedBox right, is equal to(4))
			expect(reducedBox bottom, is equal to(4))
			expect(notReducedBox == box, is true)
		})
	}
}

IntBox2DTest new() run() . free()
