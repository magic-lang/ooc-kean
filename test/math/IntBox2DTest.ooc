use ooc-unit
use ooc-math
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
		this add("addition", func)
		this add("subtraction", func)
		this add("scalar multiplication", func)
		this add("casts", func {
//			FIXME: We have no integer versions of anything yet
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
			enlargedBox := box enlarge(IntSize2D new(6, 6))
			notEnlargedBox := box enlarge(IntSize2D new(3, 3))
			expect(enlargedBox left, is equal to(0))
			expect(enlargedBox top, is equal to(0))
			expect(enlargedBox right, is equal to(6))
			expect(enlargedBox bottom, is equal to(6))
			expect(notEnlargedBox == box, is true)
		})
		this add("reduce", func {
			box := IntBox2D new(1, 1, 4, 4)
			reducedBox := box reduce(IntSize2D new(2, 2))
			notReducedBox := box reduce(IntSize2D new(6, 6))
			expect(reducedBox left, is equal to(2))
			expect(reducedBox top, is equal to(2))
			expect(reducedBox right, is equal to(4))
			expect(reducedBox bottom, is equal to(4))
			expect(notReducedBox == box, is true)
		})
	}
}
IntBox2DTest new() run()
