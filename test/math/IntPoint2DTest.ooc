use ooc-unit
use ooc-math
import math
import lang/IO

IntPoint2DTest: class extends Fixture {
	vector0 := IntPoint2D new (22, -3)
	vector1 := IntPoint2D new (12, 13)
	vector2 := IntPoint2D new (34, 10)
	vector3 := IntPoint2D new (10, 20)
	init: func () {
		super("IntPoint2D")
		this add("equality", func {
			point := IntPoint2D new()
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func {
			expect((this vector0 + this vector1) x, is equal to(this vector2 x))
			expect((this vector0 + this vector1) y, is equal to(this vector2 y))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) x, is equal to((IntPoint2D new()) x))
			expect((this vector0 - this vector0) y, is equal to((IntPoint2D new()) y))
		})
		this add("get values", func {
			expect(this vector0 x, is equal to(22))
			expect(this vector0 y, is equal to(-3))
		})
		this add("swap", func {
			result := this vector0 swap()
			expect(result x, is equal to(this vector0 y))
			expect(result y, is equal to(this vector0 x))
		})
		this add("casting", func {
			value := "10, 20"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(FloatSize2D parse(value), is equal to(this vector3))
		})
		this add("casts", func {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
IntPoint2DTest new() run()
