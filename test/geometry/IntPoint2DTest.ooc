use ooc-unit
use base
use geometry

IntPoint2DTest: class extends Fixture {
	precision := 1.0e-5f
	point0 := IntPoint2D new (22, -3)
	point1 := IntPoint2D new (12, 13)
	point2 := IntPoint2D new (34, 10)
	point3 := IntPoint2D new (10, 20)
	init: func {
		super("IntPoint2D")
		this add("equality", func {
			point := IntPoint2D new()
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func {
			expect((this point0 + this point1) x, is equal to(this point2 x))
			expect((this point0 + this point1) y, is equal to(this point2 y))
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to((IntPoint2D new()) x))
			expect((this point0 - this point0) y, is equal to((IntPoint2D new()) y))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22))
			expect(this point0 y, is equal to(-3))
		})
		this add("swap", func {
			result := this point0 swap()
			expect(result x, is equal to(this point0 y))
			expect(result y, is equal to(this point0 x))
		})
		this add("casting", func {
			value := t"10, 20"
			expect(this point3 toString(), is equal to(value toString()))
			expect(IntPoint2D parse(value) x, is equal to(this point3 x))
			expect(IntPoint2D parse(value) y, is equal to(this point3 y))
		})
		this add("float casts", func {
			point := point0 toFloatPoint2D()
			expect(point x, is equal to(22.0f) within(this precision))
			expect(point y, is equal to(-3.0f) within(this precision))
		})
		this add("minimum maximum", func {
			max := this point0 maximum(this point1)
			min := this point0 minimum(this point1)
			expect(max x, is equal to(22))
			expect(max y, is equal to(13))
			expect(min x, is equal to(12))
			expect(min y, is equal to(-3))
		})
		this add("scalar product", func {
			product := this point0 scalarProduct(this point1)
			expect(product, is equal to(225))
		})
		this add("clamp", func {
			result := point1 clamp(this point0, this point2)
			expect(result x, is equal to(this point0 x))
			expect(result y, is equal to(this point2 y))
		})
		this add("distance", func {
			distance := this point0 distance(this point1)
			expect(distance, is equal to(18.87f) within(0.01f))
		})
		this add("toText", func {
			text := IntPoint2D new (22, -3) toText() take()
			expect(text, is equal to(t"22, -3"))
			text free()
		})
	}
}

IntPoint2DTest new() run() . free()
