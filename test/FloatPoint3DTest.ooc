use ooc-unit
use ooc-math
import math
import lang/IO

FloatPoint3DTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	point0 := FloatPoint3D new (22.0f, -3.0f, 10.0f)
	point1 := FloatPoint3D new (12.0f, 13.0f, 20.0f)
	point2 := FloatPoint3D new (34.0f, 10.0f, 30.0f)
	point3 := FloatPoint3D new (10.0f, 20.0f, 30.0f)
	init: func () {
		super("FloatPoint3D")
		this add("norm", func() {
			expect(this point0 Norm, is equal to(24.3515f) within(this precision))
		})
		this add("scalar product", func() {
			// Must use values, default constructor is bugged
			point := FloatPoint3D new(0, 0, 0)
			expect(this point0 scalarProduct(point), is equal to(0.0f) within(this precision))
			expect(this point0 scalarProduct(this point1), is equal to(425.0f) within(this precision))
		})
		this add("scalar multiplication", func() {
//			expect(this point0 vectorProduct(this point1), is equal to(-(this point1 vectorProduct(point0))))
			expect(this point0 vectorProduct(this point1) x, is equal to(-190.0f) within(this precision))
			expect(this point0 vectorProduct(this point1) y, is equal to(-320.0f) within(this precision))
			expect(this point0 vectorProduct(this point1) z, is equal to(322.0f) within(this precision))
		})
		this add("equality", func() {
			point := FloatPoint3D new(0, 0, 0)
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func() {
			expect((this point0 + this point1) x, is equal to(this point2 x) within(this precision))
			expect((this point0 + this point1) y, is equal to(this point2 y) within(this precision))
			expect((this point0 + this point1) z, is equal to(this point2 z) within(this precision))
		})
		this add("subtraction", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 - this vector0, is equal to(FloatSize2D new()))
		})
		this add("get values", func() {
			expect(this point0 x, is equal to(22.0f))
			expect(this point0 y, is equal to(-3.0f))
			expect(this point0 z, is equal to(10.0f))
		})
		this add("casting", func() {
			value := "10.00, 20.00, 30.00"
			expect(this point3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(FloatSize2D parse(value), is equal to(this vector3))
		})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
FloatPoint3DTest new() run()
