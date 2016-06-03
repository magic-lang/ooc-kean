/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry
use collections
use base

FloatBox2DTest: class extends Fixture {
	box0 := FloatBox2D new(1.0f, 2.0f, 3.0f, 4.0f)
	box1 := FloatBox2D new(4.0f, 3.0f, 2.0f, 1.0f)
	box2 := FloatBox2D new(2.0f, 1.0f, 4.0f, 3.0f)
	box3 := FloatBox2D new(2.6f, 1.2f, 4.9f, 3.01f)
	init: func {
		tolerance := 1.0e-5f
		super("FloatBox2D")
		this add("fixture", func {
			expect(this box0, is equal to(this box0))
		})
		this add("equality", func {
			box := FloatBox2D new()
			expect(this box0 == this box0, is true)
			expect(this box0 != this box1, is true)
			expect(this box0 == box, is false)
			expect(box == box, is true)
			expect(box == this box0, is false)
		})
		this add("leftTop", func {
			leftTop := this box0 leftTop
			expect(leftTop x, is equal to(1.0f) within(tolerance))
			expect(leftTop y, is equal to(2.0f) within(tolerance))
		})
		this add("size", func {
			size := this box0 size
			expect(size x, is equal to(3.0f) within(tolerance))
			expect(size y, is equal to(4.0f) within(tolerance))
		})
		this add("addition, union", func {
			result := this box0 + this box1
			expect(result left, is equal to(1.0f) within(tolerance))
			expect(result top, is equal to(2.0f) within(tolerance))
			expect(result width, is equal to(5.0f) within(tolerance))
			expect(result height, is equal to(4.0f) within(tolerance))
			expect(result == this box0 union(this box1))
		})
		this add("subtraction, intersection", func {
			result := this box0 - this box2
			other := this box2 - this box0
			expect(result == other)
			expect(result top, is equal to(2.0f) within(tolerance))
			expect(result left, is equal to(2.0f) within(tolerance))
			expect(result width, is equal to(2.0f) within(tolerance))
			expect(result height, is equal to(2.0f) within(tolerance))
			expect(result == this box0 intersection(this box2))
		})
		this add("casts", func {
			intBox := this box0 toIntBox2D()
			expect(intBox left, is equal to(1))
			expect(intBox top, is equal to(2))
			expect(intBox right, is equal to(4))
			expect(intBox bottom, is equal to(6))
		})
		this add("contains~FloatPoint2DVectorList", func {
			box := FloatBox2D new(-2.0f, -1.0f, 3.0f, 3.0f)
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(0.0f, 1.0f))
			list add(FloatPoint2D new(-2.0f, 2.0f))
			list add(FloatPoint2D new(-2.0f, -2.0f))
			list add(FloatPoint2D new(0.0f, 0.0f))
			inBox := box contains~FloatPoint2DVectorList(list)
			expect(inBox count, is equal to(3))
			expect(inBox[0], is equal to(0))
			expect(inBox[1], is equal to(1))
			expect(inBox[2], is equal to(3))
			(list, inBox) free()
		})
		this add("enlarge and shrink", func {
			box := FloatBox2D new(-2.0f, -1.0f, 3.0f, 3.0f)
			paddedBox := box enlarge(0.1f)
			shrunkBox := paddedBox shrink(1.0f / 11.0f)
			expect(box == shrunkBox, is true)
		})
		this add("rounding", func {
			round := this box3 round()
			ceiling := this box3 ceiling()
			floor := this box3 floor()

			expect(round left, is equal to(3.0f) within(tolerance))
			expect(round top, is equal to(1.0f) within(tolerance))
			expect(round width, is equal to(5.0f) within(tolerance))
			expect(round height, is equal to(3.0f) within(tolerance))

			expect(ceiling left, is equal to(3.0f) within(tolerance))
			expect(ceiling top, is equal to(2.0f) within(tolerance))
			expect(ceiling width, is equal to(5.0f) within(tolerance))
			expect(ceiling height, is equal to(4.0f) within(tolerance))

			expect(floor left, is equal to(2.0f) within(tolerance))
			expect(floor top, is equal to(1.0f) within(tolerance))
			expect(floor width, is equal to(4.0f) within(tolerance))
			expect(floor height, is equal to(3.0f) within(tolerance))
		})
		this add("swap", func {
			swapped := this box0 swap()
			expect(swapped top, is equal to(this box0 left))
			expect(swapped left, is equal to(this box0 top))
			expect(swapped width, is equal to(this box0 height))
			expect(swapped height, is equal to(this box0 width))
		})
		this add("adaptTo", func {
			smallBox := FloatBox2D new(1.0f, 1.0f, 1.0f, 1.0f)
			largeBox := FloatBox2D new(3.0f, 3.0f, 2.0f, 2.0f)
			adapted := smallBox adaptTo(largeBox, 0.5f)
			expect(adapted center x, is equal to(2.75f) within(tolerance))
			expect(adapted center y, is equal to(2.75f) within(tolerance))
			expect(adapted width, is equal to(1.5f) within(tolerance))
			expect(adapted height, is equal to(1.5f) within(tolerance))
		})
		this add("toString", func {
			string := this box0 toString()
			expect(string, is equal to("1.00, 2.00, 3.00, 4.00"))
			string free()
		})
		this add("bounds", func {
			points := VectorList<FloatPoint2D> new()
			points add(FloatPoint2D new(1.0f, 2.0f))
			points add(FloatPoint2D new(-1.0f, -2.0f))
			points add(FloatPoint2D new(1.0f, 3.0f))
			points add(FloatPoint2D new(-2.0f, 4.0f))
			points add(FloatPoint2D new(0.0f, 0.0f))
			points add(FloatPoint2D new(-1.0f, 3.0f))
			box := FloatBox2D bounds(points)
			expect(box left, is equal to(-2.0f) within(tolerance))
			expect(box top, is equal to(-2.0f) within(tolerance))
			expect(box right, is equal to(1.0f) within(tolerance))
			expect(box bottom, is equal to(4.0f) within(tolerance))
			points free()
		})
		this add("parse", func {
			box := FloatBox2D parse("1.0, 2.0, 3.0, 4.0")
			expect(box left, is equal to(1.0f) within(tolerance))
			expect(box top, is equal to(2.0f) within(tolerance))
			expect(box right, is equal to(1.0f + 3.0f) within(tolerance))
			expect(box bottom, is equal to(2.0f + 4.0f) within(tolerance))
		})
		this add("createAround", func {
			box := FloatBox2D createAround(FloatPoint2D new(1.0f, 1.0f), FloatVector2D new(4.0f, 4.0f))
			expect(box left, is equal to(-1.0f) within(tolerance))
			expect(box top, is equal to(-1.0f) within(tolerance))
			expect(box right, is equal to(3.0f) within(tolerance))
			expect(box bottom, is equal to(3.0f) within(tolerance))
		})
		this add("enlargeEvenly", func {
			box := FloatBox2D new(-3.0f, -1.0f, 3.0f, 3.0f)
			paddedBox := box enlargeEvenly(2.0f)
			expect(paddedBox == FloatBox2D new(-9.0f, -7.0f, 15.0f, 15.0f))
		})
		this add("resizeTo", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			changedBox := box resizeTo(FloatVector2D new(2.0f, 2.0f))
			expect(changedBox left, is equal to(2.0f) within(tolerance))
			expect(changedBox right, is equal to(4.0f) within(tolerance))
			expect(changedBox top, is equal to(2.0f) within(tolerance))
			expect(changedBox bottom, is equal to(4.0f) within(tolerance))
		})
		this add("scale", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			doubledBox := box scale(2.0f)
			halfBox := box scale(0.5f)
			expect(doubledBox left, is equal to(-1.0f) within(tolerance))
			expect(doubledBox right, is equal to(7.0f) within(tolerance))
			expect(doubledBox top, is equal to(-1.0f) within(tolerance))
			expect(doubledBox bottom, is equal to(7.0f) within(tolerance))
			expect(halfBox left, is equal to(2.0f) within(tolerance))
			expect(halfBox right, is equal to(4.0f) within(tolerance))
			expect(halfBox top, is equal to(2.0f) within(tolerance))
			expect(halfBox bottom, is equal to(4.0f) within(tolerance))
		})
		this add("enlarge", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			enlargedBox := box enlargeTo(FloatVector2D new(6.0f, 6.0f))
			notEnlargedBox := box enlargeTo(FloatVector2D new(3.0f, 3.0f))
			expect(enlargedBox left, is equal to(0.0f) within(tolerance))
			expect(enlargedBox top, is equal to(0.0f) within(tolerance))
			expect(enlargedBox right, is equal to(6.0f) within(tolerance))
			expect(enlargedBox bottom, is equal to(6.0f) within(tolerance))
			expect(notEnlargedBox == box, is true)
		})
		this add("reduce", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			reducedBox := box shrinkTo(FloatVector2D new(2.0f, 2.0f))
			notReducedBox := box shrinkTo(FloatVector2D new(6.0f, 6.0f))
			expect(reducedBox left, is equal to(2.0f) within(tolerance))
			expect(reducedBox top, is equal to(2.0f) within(tolerance))
			expect(reducedBox right, is equal to(4.0f) within(tolerance))
			expect(reducedBox bottom, is equal to(4.0f) within(tolerance))
			expect(notReducedBox == box, is true)
		})
		this add("box to point distance", func {
			box := FloatBox2D new(-10.f, -10.f, 20.f, 20.f)
			points := VectorList<FloatPoint2D> new()
			points add(FloatPoint2D new(5.f, 5.f))
			points add(FloatPoint2D new(15.f, 0.f))
			points add(FloatPoint2D new(0.f, -17.f))
			points add(FloatPoint2D new(11.f, -12.f))
			separatedDistance := box distance(points[0])
			expect(separatedDistance x, is equal to(0.f) within(tolerance))
			expect(separatedDistance y, is equal to(0.f) within(tolerance))
			separatedDistance = box distance(points[3])
			expect(separatedDistance x, is equal to(1.f) within(tolerance))
			expect(separatedDistance y, is equal to(2.f) within(tolerance))
			maximumSeparatedDistance := box maximumDistance(points)
			expect(maximumSeparatedDistance x, is equal to(5.f) within(tolerance))
			expect(maximumSeparatedDistance y, is equal to(7.f) within(tolerance))
			points free()
		})
		this add("interpolate", func {
			a := FloatBox2D new(1.0f, 5.0f, 3.0f, 4.0f)
			b := FloatBox2D new(4.0f, -1.0f, 0.0f, 1.0f)
			interpolatedBox := FloatBox2D mix(a, b, 1.0f / 3.0f)
			expect(interpolatedBox left, is equal to(2.0f) within(tolerance))
			expect(interpolatedBox top, is equal to(3.0f) within(tolerance))
			expect(interpolatedBox width, is equal to(2.0f) within(tolerance))
			expect(interpolatedBox height, is equal to(3.0f) within(tolerance))
		})
	}
}

FloatBox2DTest new() run() . free()
