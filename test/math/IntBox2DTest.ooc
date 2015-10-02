use ooc-unit
use ooc-math
import VectorList
import math
import lang/IO

IntBox2DTest: class extends Fixture {
	box0 := IntBox2D new (1, 2, 3, 4)
	box1 := IntBox2D new (4, 3, 2, 1)
	box2 := IntBox2D new (2, 1, 4, 3)
	init: func {
		super("IntBox2D")
		this add("equality", func {
			box := IntBox2D new()
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
			expect(leftTop x, is equal to(1))
			expect(leftTop y, is equal to(2))
		})
		this add("size", func {
			size := this box0 size
			expect(size width, is equal to(3))
			expect(size height, is equal to(4))
		})
		this add("addition, union", func {
			result := box0 + box1
			expect(result left, is equal to(1))
			expect(result top, is equal to(2))
			expect(result width, is equal to(5))
			expect(result height, is equal to(4))
			expect(result == box0 union(box1))
		})
		this add("subtraction, intersection", func {
			result := box0 - box2
			resultb := box2 - box0
			expect(result == resultb)
			expect(result top, is equal to(2))
			expect(result left, is equal to(2))
			expect(result width, is equal to(2))
			expect(result height, is equal to(2))
			expect(result == box0 intersection(box2))
		})
		this add("casts", func {
			floatVersion := this box0 toFloatBox2D()
			expect(floatVersion left, is equal to(1.0f) within(0.01f))
			expect(floatVersion top, is equal to(2.0f) within(0.01f))
			expect(floatVersion right, is equal to(4.0f) within(0.01f))
			expect(floatVersion bottom, is equal to(6.0f) within(0.01f))
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
		})
		this add("contains~FloatPoint2DVectorList", func {
			box := IntBox2D new(-2, -1, 3, 3)
			inside := IntPoint2D new(0, 1)
			outside := FloatPoint2D new(-2.0f, 2.0f)
			expect(box contains(inside))
			expect(!box contains(outside))
		})
		this add("toString", func {
			expect(this box0 toString() == "1, 2, 3, 4")
		})
		this add("parse", func {
			box := IntBox2D parse("1, 2, 3, 4")
			expect(box left, is equal to(1))
			expect(box top, is equal to(2))
			expect(box right, is equal to(1 + 3))
			expect(box bottom, is equal to(2 + 4))
		})
		this add("createAround", func {
			box := IntBox2D createAround(IntPoint2D new(1, 1), IntSize2D new(4, 4))
			expect(box left, is equal to(-1))
			expect(box top, is equal to(-1))
			expect(box right, is equal to(3))
			expect(box bottom, is equal to(3))
		})
	}
}
IntBox2DTest new() run()
