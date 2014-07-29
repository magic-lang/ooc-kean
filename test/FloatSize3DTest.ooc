use ooc-unit
use ooc-math
import math
import lang/IO
//import ../../../source/FloatExtension

FloatSize3DTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	vector0 := FloatSize3D new (22.0f, -3.0f, 10.0f)
	vector1 := FloatSize3D new (12.0f, 13.0f, 20.0f)
	vector2 := FloatSize3D new (34.0f, 10.0f, 30.0f)
	vector3 := FloatSize3D new (10.0f, 20.0f, 30.0f)
	init: func () {
		super("FloatSize3D")
		this add("norm", func() {
			expect(this vector0 Norm, is equal to(593.0f sqrt()) within(this precision))
			expect(this vector0 Norm, is equal to(this vector0 scalarProduct(this vector0) sqrt()) within(this precision))
		})
		this add("volume", func() {
			expect(vector3 Volume, is equal to(6000.0f) within(this precision))
		})
		this add("scalar product", func() {
			size := FloatSize3D new()
			expect(this vector0 scalarProduct(size), is equal to(0.0f) within(this precision))
			expect(this vector0 scalarProduct(this vector1), is equal to(425.0f) within(this precision))
		})
		this add("vector product", func() {
			//FIXME: Equals interface
//			expect(this vector0 vectorProduct(this vector1), is equal to(-(this vector1 vectorProduct(this vector0))))
			expect(this vector0 vectorProduct(this vector1) width, is equal to(-190.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) height, is equal to(-320.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) depth, is equal to(322.0f) within(this precision))
		})
		this add("equality", func() {
			size := FloatSize3D new()
//			FIXME: There is no equals interface yet
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == size, is false)
			expect(size == size, is true)
			expect(size == this vector0, is false)
		})
		this add("addition", func() {
			expect((this vector0 + this vector1) width, is equal to(this vector2 width))
			expect((this vector0 + this vector1) height, is equal to(this vector2 height))
			expect((this vector0 + this vector1) depth, is equal to(this vector2 depth))
		})
		this add("subtraction", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 - this vector0, is equal to(FloatSize3D new()))
		})
		this add("get values", func() {
			expect(this vector0 width, is equal to(22.0f))
			expect(this vector0 height, is equal to(-3.0f))
			expect(this vector0 depth, is equal to(10.0f))
		})
		this add("casting", func() {
			value := "10.00, 20.00, 30.00"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(FloatSize2D parse(value), is equal to(this vector3))
		})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
FloatSize3DTest new() run()
