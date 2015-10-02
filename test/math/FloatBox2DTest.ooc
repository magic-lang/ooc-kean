use ooc-unit
use ooc-math
use ooc-collections
import math
import lang/IO

FloatBox2DTest: class extends Fixture {
	precision := 1.0e-5f
	box0 := FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f)
	box1 := FloatBox2D new (4.0f, 3.0f, 2.0f, 1.0f)
	box2 := FloatBox2D new (2.0f, 1.0f, 4.0f, 3.0f)
	box3 := FloatBox2D new (2.6f, 1.2f, 4.9f, 3.01f)
	init: func {
		super("FloatBox2D")
		this add("equality", func {
			box := FloatBox2D new()
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this box0 == this box0, is true)
			expect(this box0 != this box1, is true)
			expect(this box0 == box, is false)
			expect(box == box, is true)
			expect(box == this box0, is false)
		})
		this add("leftTop", func {
			leftTop := this box0 leftTop
			expect(leftTop x, is equal to(1.0f) within (this precision))
			expect(leftTop y, is equal to(2.0f) within (this precision))
		})
		this add("size", func {
			size := this box0 size
			expect(size width, is equal to(3.0f) within (this precision))
			expect(size height, is equal to(4.0f) within (this precision))
		})
		this add("addition, union", func {
			result := box0 + box1
			expect(result left, is equal to(1.0f) within (this precision))
			expect(result top, is equal to(2.0f) within (this precision))
			expect(result width, is equal to(5.0f) within (this precision))
			expect(result height, is equal to(4.0f) within (this precision))
			expect(result == box0 union(box1))
		})
		this add("subtraction, intersection", func {
			result := box0 - box2
			resultb := box2 - box0
			expect(result == resultb)
			expect(result top, is equal to(2.0f) within(this precision))
			expect(result left, is equal to(2.0f) within(this precision))
			expect(result width, is equal to(2.0f) within(this precision))
			expect(result height, is equal to(2.0f) within(this precision))
			expect(result == box0 intersection(box2))
		})
		this add("casts", func {
			intVersion := this box0 toIntBox2D()
			expect(intVersion left, is equal to(1))
			expect(intVersion top, is equal to(2))
			expect(intVersion right, is equal to(4))
			expect(intVersion bottom, is equal to(6))
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
		})
		this add("pad and shrink ~fraction", func {
			box := FloatBox2D new(-2.0f, -1.0f, 3.0f, 3.0f)
			paddedBox := box pad~fraction(0.1f)
			shrunkBox := paddedBox shrink(1.0f / 11.0f)
			expect(box == shrunkBox, is true)
		})
		this add("rounding", func {
			_round := this box3 round()
			_ceiling := this box3 ceiling()
			_floor := this box3 floor()

			expect(_round left, is equal to(3.0f) within(this precision))
			expect(_round top, is equal to(1.0f) within(this precision))
			expect(_round width, is equal to(5.0f) within(this precision))
			expect(_round height, is equal to(3.0f) within(this precision))

			expect(_ceiling left, is equal to(3.0f) within(this precision))
			expect(_ceiling top, is equal to(2.0f) within(this precision))
			expect(_ceiling width, is equal to(5.0f) within(this precision))
			expect(_ceiling height, is equal to(4.0f) within(this precision))

			expect(_floor left, is equal to(2.0f) within(this precision))
			expect(_floor top, is equal to(1.0f) within(this precision))
			expect(_floor width, is equal to(4.0f) within(this precision))
			expect(_floor height, is equal to(3.0f) within(this precision))
		})
		this add("swap", func {
			swapped := this box0 swap()
			expect(swapped top, is equal to(this box0 left))
			expect(swapped left, is equal to(this box0 top))
			expect(swapped width, is equal to(this box0 height))
			expect(swapped height, is equal to(this box0 width))
		})
		this add("adaptTo", func {
			small := FloatBox2D new(1.0f, 1.0f, 1.0f, 1.0f)
			large := FloatBox2D new(3.0f, 3.0f, 2.0f, 2.0f)
			adapted := small adaptTo(large, 0.5f)
			expect(adapted center x, is equal to(2.75f) within(this precision))
			expect(adapted center y, is equal to(2.75f) within(this precision))
			expect(adapted width, is equal to(1.5f) within(this precision))
			expect(adapted height, is equal to(1.5f) within(this precision))
		})
		this add("toString", func {
			expect(this box0 toString() == "1.00, 2.00, 3.00, 4.00")
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
			expect(box left, is equal to(-2.0f) within(this precision))
			expect(box top, is equal to(-2.0f) within(this precision))
			expect(box right, is equal to(1.0f) within(this precision))
			expect(box bottom, is equal to(4.0f) within(this precision))
		})
		this add("parse", func {
			box := FloatBox2D parse("1.0, 2.0, 3.0, 4.0")
			expect(box left, is equal to(1.0f) within(this precision))
			expect(box top, is equal to(2.0f) within(this precision))
			expect(box right, is equal to(1.0f + 3.0f) within(this precision))
			expect(box bottom, is equal to(2.0f + 4.0f) within(this precision))
		})
		this add("createAround", func {
			box := FloatBox2D createAround(FloatPoint2D new(1.0f, 1.0f), FloatSize2D new(4.0f, 4.0f))
			expect(box left, is equal to(-1.0f) within(this precision))
			expect(box top, is equal to(-1.0f) within(this precision))
			expect(box right, is equal to(3.0f) within(this precision))
			expect(box bottom, is equal to(3.0f) within(this precision))
		})
	}
}
FloatBox2DTest new() run()
