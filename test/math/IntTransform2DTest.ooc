use ooc-unit
use ooc-math
import math
import lang/IO

IntTransform2DTest: class extends Fixture {
	transform0 := IntTransform2D new(3, 1, 2, 1, 5, 7)
	transform1 := IntTransform2D new(7, 4, 2, 5, 7, 6)
	transform2 := IntTransform2D new(29, 11, 16, 7, 38, 20)
	transform3 := IntTransform2D new(1, -1, -2, 3, 9, -16)
	transform4 := IntTransform2D new(10, 20, 30, 40, 50, 60)
	point0 := IntPoint2D new(-7, 3)
	point1 := IntPoint2D new(-10, 3)
	size := IntSize2D new(10, 10)
	init: func {
		super("IntTransform2D")
		this add("equality", func {
			transform := IntTransform2D new()
			expect(this transform0 == this transform0, is true)
			expect(this transform0 == this transform1, is false)
			expect(this transform0 == transform, is false)
			expect(transform == transform, is true)
			expect(transform == this transform0, is false)
		})
		this add("inverse transform", func {
			expect(this transform0 inverse == this transform3, is true)
		})
		this add("multiplication, transform - transform", func {
			expect(this transform0 * this transform1 == this transform2, is true)
		})
		this add("multiplication, transform - point", func {
			expect(this transform0 * this point0 == this point1, is true)
		})
		this add("create zero transform", func {
			transform := IntTransform2D new()
			expect(transform a, is equal to(0))
			expect(transform b, is equal to(0))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(0))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
			expect(transform i, is equal to(0))
		})
		this add("create identity transform", func {
			transform := IntTransform2D identity
			expect(transform a, is equal to(1))
			expect(transform b, is equal to(0))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(1))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
			expect(transform i, is equal to(1))
		})
		this add("rotate", func {
			angle := Float pi
			transform := IntTransform2D createZRotation(angle)
			transform = transform rotate(-angle)
			expect(transform a, is equal to(1))
			expect(transform b, is equal to(0))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(1))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
			expect(transform i, is equal to(1))
		})
		this add("scale", func {
			scale := 20
			identity := IntTransform2D new(scale, 0, 0, scale, 0, 0)
			transform := IntTransform2D createScaling(scale, scale)
			transform = transform scale(5)
			expect(transform a, is equal to(100))
			expect(transform b, is equal to(0))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(100))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
			expect(transform i, is equal to(1))
		})
		this add("translate", func {
			xDelta := 40
			yDelta := -40
			transform := IntTransform2D createTranslation(xDelta, yDelta)
			transform = transform translate(-xDelta, -yDelta)
			expect(transform a, is equal to(1))
			expect(transform b, is equal to(0))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(1))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
			expect(transform i, is equal to(1))
		})
		this add("create rotation", func {
			angle := Float pi
			transform := IntTransform2D createZRotation(angle)
			expect(transform a, is equal to(-1))
			expect(transform b, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(-1))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
		})
		this add("create scale", func {
			scale := 20
			transform := IntTransform2D createScaling(scale, scale)
			expect(transform a, is equal to(scale))
			expect(transform b, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(scale))
			expect(transform g, is equal to(0))
			expect(transform h, is equal to(0))
		})
		this add("create translation", func {
			xDelta := 40
			yDelta := -40
			transform := IntTransform2D createTranslation(xDelta, yDelta)
			expect(transform a, is equal to(1))
			expect(transform b, is equal to(0))
			expect(transform d, is equal to(0))
			expect(transform e, is equal to(1))
			expect(transform g, is equal to(xDelta))
			expect(transform h, is equal to(yDelta))
		})
		this add("get values", func {
			transform := this transform0
			expect(transform a, is equal to(3))
			expect(transform b, is equal to(1))
			expect(transform c, is equal to(0))
			expect(transform d, is equal to(2))
			expect(transform e, is equal to(1))
			expect(transform f, is equal to(0))
			expect(transform g, is equal to(5))
			expect(transform h, is equal to(7))
			expect(transform i, is equal to(1))
		})
	}
}

IntTransform2DTest new() run()
