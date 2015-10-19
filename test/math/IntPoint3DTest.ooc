use ooc-unit
use ooc-base
use ooc-math
import math
import lang/IO

IntPoint3DTest: class extends Fixture {
	precision := 1.0e-5f
	point0 := IntPoint3D new (22, -3, 8)
	point1 := IntPoint3D new (12, 13, -8)
	point2 := IntPoint3D new (34, 10, 0)
	point3 := IntPoint3D new (10, 20, 0)
	init: func {
		super("IntPoint3D")
		this add("equality", func {
			point := IntPoint3D new()
//			FIXME: There is no equals interface yet
//			expect(this point0, is equal to(this point0))
//			expect(this point0 equals(this point0 as Object), is true)
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func {
			expect((this point0 + this point1) x, is equal to(this point2 x))
			expect((this point0 + this point1) y, is equal to(this point2 y))
			expect((this point0 + this point1) z, is equal to(this point2 z))
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to((IntPoint3D new()) x))
			expect((this point0 - this point0) y, is equal to((IntPoint3D new()) y))
			expect((this point0 - this point0) z, is equal to((IntPoint3D new()) z))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this point0) x, is equal to((-point0) x))
			expect(((-1) * this point0) y, is equal to((-point0) y))
			expect(((-1) * this point0) z, is equal to((-point0) z))
		})
		this add("scalar division", func {
			expect((this point0 / (-1)) x, is equal to((-point0) x))
			expect((this point0 / (-1)) y, is equal to((-point0) y))
			expect((this point0 / (-1)) z, is equal to((-point0) z))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22))
			expect(this point0 y, is equal to(-3))
			expect(this point0 z, is equal to(8))
		})
		this add("casting", func {
			value := "10, 20, 0"
			expect(this point3 toString(), is equal to(value))
			expect(IntPoint3D parse(t"34,10,0") x, is equal to(this point2 x))
			expect(IntPoint3D parse(t"34,10,0") y, is equal to(this point2 y))
			expect(IntPoint3D parse(t"34,10,0") z, is equal to(this point2 z))
		})
		this add("float casts", func {
			point := point0 toFloatPoint3D()
			expect(point x, is equal to(22.0f) within(this precision))
			expect(point y, is equal to(-3.0f) within(this precision))
			expect(point z, is equal to(8.0f) within(this precision))
		})
	}
}

IntPoint3DTest new() run()
