/* This file is part of magic-sdk, an sdk for the open source programming language magic.
 *
 * Copyright (C) 2016 magic-lang
 *
 * This software may be modified and distributed under the terms
 * of the MIT license.  See the LICENSE file for details.
 */

use unit
use geometry

FloatTransform2DTest: class extends Fixture {
	precision := 1.0e-5f
	transform0 := FloatTransform2D new(3.0f, 1.0f, 2.0f, 1.0f, 5.0f, 7.0f)
	transform1 := FloatTransform2D new(7.0f, 4.0f, 2.0f, 5.0f, 7.0f, 6.0f)
	transform2 := FloatTransform2D new(29.0f, 11.0f, 16.0f, 7.0f, 38.0f, 20.0f)
	transform3 := FloatTransform2D new(1.0f, -1.0f, -2.0f, 3.0f, 9.0f, -16.0f)
	transform4 := FloatTransform2D new(10.0f, 20.0f, 30.0f, 40.0f, 50.0f, 60.0f)
	point0 := FloatPoint2D new(-7.0f, 3.0f)
	point1 := FloatPoint2D new(-10.0f, 3.0f)
	size := FloatVector2D new(10.0f, 10.0f)
	init: func {
		super("FloatTransform2D")
		this add("equality", func {
			transform := FloatTransform2D new()
			expect(this transform0 == this transform0, is true)
			expect(this transform0 == this transform1, is false)
			expect(this transform0 == transform, is false)
			expect(transform == transform, is true)
			expect(transform == this transform0, is false)
		})
		this add("inverse transform", func {
			expect(this transform0 inverse == this transform3)
		})
		this add("multiplication, transform - transform", func {
			expect(this transform0 * this transform1 == this transform2)
		})
		this add("multiplication, transform - point", func {
			expect(this transform0 * this point0 == this point1)
		})
		this add("create zero transform", func {
			transform := FloatTransform2D new()
			expect(transform a, is equal to(0.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(0.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(0.0f) within(this precision))
		})
		this add("create identity transform", func {
			transform := FloatTransform2D identity
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("rotate", func {
			angle := Float pi / 9.0f
			transform := FloatTransform2D createZRotation(angle)
			transform = transform rotate(-angle)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("scale", func {
			scale := 20.0f
			transform := FloatTransform2D createScaling(scale, scale)
			transform = transform scale(5.0f)
			expect(transform a, is equal to(100.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(100.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("translate", func {
			xDelta := 40.0f
			yDelta := -40.0f
			transform := FloatTransform2D createTranslation(xDelta, yDelta)
			transform = transform translate(-xDelta, -yDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("create rotation", func {
			angle := Float pi / 9.0f
			transform := FloatTransform2D createZRotation(angle)
			expect(transform a, is equal to(angle cos()) within(this precision))
			expect(transform b, is equal to(angle sin()) within(this precision))
			expect(transform d, is equal to(-angle sin()) within(this precision))
			expect(transform e, is equal to(angle cos()) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
		})
		this add("create scale", func {
			scale := 20.0f
			transform := FloatTransform2D createScaling(scale, scale)
			expect(transform a, is equal to(scale) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(scale) within(this precision))
			expect(transform g, is equal to(0.0f) within(this precision))
			expect(transform h, is equal to(0.0f) within(this precision))
		})
		this add("create translation", func {
			xDelta := 40.0f
			yDelta := -40.0f
			transform := FloatTransform2D createTranslation(xDelta, yDelta)
			expect(transform a, is equal to(1.0f) within(this precision))
			expect(transform b, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(0.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform g, is equal to(xDelta) within(this precision))
			expect(transform h, is equal to(yDelta) within(this precision))
		})
		this add("get values", func {
			transform := this transform0
			expect(transform a, is equal to(3.0f) within(this precision))
			expect(transform b, is equal to(1.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(5.0f) within(this precision))
			expect(transform h, is equal to(7.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("get ScalingX", func {
			scale := this transform0 scalingX
			expect(scale, is equal to(3.162277f) within(this precision))
		})
		this add("get ScalingY", func {
			scale := this transform0 scalingY
			expect(scale, is equal to(2.23606801f) within(this precision))
		})
		this add("get Scaling", func {
			scale := this transform0 scaling
			expect(scale, is equal to(2.69917297f) within(this precision))
		})
		this add("get ScalingX", func {
			translation := this transform0 translation
			expect(translation x, is equal to(5.0f) within(this precision))
			expect(translation y, is equal to(7.0f) within(this precision))
		})
		this add("setTranslation", func {
			transform := this transform0 setTranslation(FloatVector2D new(-7.0f, 3.0f))
			expect(transform a, is equal to(3.0f) within(this precision))
			expect(transform b, is equal to(1.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.0f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(-7.0f) within(this precision))
			expect(transform h, is equal to(3.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("set Scaling", func {
			transform := this transform0 setScaling(4)
			expect(transform a, is equal to(4.44580647f) within(this precision))
			expect(transform b, is equal to(1.48193549f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.96387098f) within(this precision))
			expect(transform e, is equal to(1.48193549f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(7.40967746f) within(this precision))
			expect(transform h, is equal to(10.37354844f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("set XScaling", func {
			transform := this transform0 setXScaling(4)
			expect(transform a, is equal to(3.79473319f) within(this precision))
			expect(transform b, is equal to(1.0f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.52982212f) within(this precision))
			expect(transform e, is equal to(1.0f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(6.32455532f) within(this precision))
			expect(transform h, is equal to(7.0f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("set YScaling", func {
			transform := this transform0 setYScaling(4)
			expect(transform a, is equal to(3.0f) within(this precision))
			expect(transform b, is equal to(1.78885438f) within(this precision))
			expect(transform c, is equal to(0.0f) within(this precision))
			expect(transform d, is equal to(2.0f) within(this precision))
			expect(transform e, is equal to(1.78885438f) within(this precision))
			expect(transform f, is equal to(0.0f) within(this precision))
			expect(transform g, is equal to(5.0f) within(this precision))
			expect(transform h, is equal to(12.52198066f) within(this precision))
			expect(transform i, is equal to(1.0f) within(this precision))
		})
		this add("toText", func {
			text := FloatTransform2D new(3.0f, 1.0f, 2.0f, 1.0f, 5.0f, 7.0f) toText() take()
			expect(text, is equal to(t"3.00, 1.00, 0.00\t2.00, 1.00, 0.00\t5.00, 7.00, 1.00"))
			text free()
		})
	}
}

FloatTransform2DTest new() run() . free()
