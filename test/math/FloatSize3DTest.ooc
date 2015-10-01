use ooc-unit
use ooc-math
import math
import lang/IO

FloatSize3DTest: class extends Fixture {
	precision := 1.0e-4f
	vector0 := FloatSize3D new (22.0f, -3.0f, 10.0f)
	vector1 := FloatSize3D new (12.0f, 13.0f, 20.0f)
	vector2 := FloatSize3D new (34.0f, 10.0f, 30.0f)
	vector3 := FloatSize3D new (10.0f, 20.0f, 30.0f)
	vector4 := FloatSize3D new (10.1f, 20.7f, 30.3f)
	init: func {
		super("FloatSize3D")
		this add("norm", func {
			expect(this vector0 norm, is equal to(593.0f sqrt()) within(this precision))
			expect(this vector0 norm, is equal to(this vector0 scalarProduct(this vector0) sqrt()) within(this precision))
		})
		this add("volume", func {
			expect(vector3 volume, is equal to(6000.0f) within(this precision))
		})
		this add("scalar product", func {
			size := FloatSize3D new()
			expect(this vector0 scalarProduct(size), is equal to(0.0f) within(this precision))
			expect(this vector0 scalarProduct(this vector1), is equal to(425.0f) within(this precision))
		})
		this add("vector product", func {
			//FIXME: Equals interface
//			expect(this vector0 vectorProduct(this vector1), is equal to(-(this vector1 vectorProduct(this vector0))))
			expect(this vector0 vectorProduct(this vector1) width, is equal to(-190.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) height, is equal to(-320.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) depth, is equal to(322.0f) within(this precision))
		})
		this add("equality", func {
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
		this add("addition", func {
			expect((this vector0 + this vector1) width, is equal to(this vector2 width))
			expect((this vector0 + this vector1) height, is equal to(this vector2 height))
			expect((this vector0 + this vector1) depth, is equal to(this vector2 depth))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) width, is equal to((FloatSize3D new()) width))
			expect((this vector0 - this vector0) height, is equal to((FloatSize3D new()) height))
			expect((this vector0 - this vector0) depth, is equal to((FloatSize3D new()) depth))
		})
		this add("get values", func {
			expect(this vector0 width, is equal to(22.0f))
			expect(this vector0 height, is equal to(-3.0f))
			expect(this vector0 depth, is equal to(10.0f))
		})
		this add("casting", func {
			value := "10.00, 20.00, 30.00"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(FloatSize2D parse(value), is equal to(this vector3))
		})
		this add("int casts", func {
			vector := vector0 toIntSize3D()
			expect(vector width, is equal to(22))
			expect(vector height, is equal to(-3))
			expect(vector depth, is equal to(10))
		})
		this add("minimum maximum", func {
			_max := this vector0 maximum(this vector1)
			_min := this vector0 minimum(this vector1)
			expect(_max width, is equal to(22.221f) within(this precision))
			expect(_max height, is equal to(13.1f) within(this precision))
			expect(_max depth, is equal to(20.0f) within(this precision))
			expect(_min width, is equal to(12.221f) within(this precision))
			expect(_min height, is equal to(-3.1f) within(this precision))
			expect(_min depth, is equal to(10.0f) within(this precision))
		})
		this add("rounding", func {
			expect(_round width, is equal to(10.0f) within(this precision))
			expect(_round height, is equal to(21.0f) within(this precision))
			expect(_round depth, is equal to(30.0f) within(this precision))
			expect(_ceiling width, is equal to(11.0f) within(this precision))
			expect(_ceiling height, is equal to(21.0f) within(this precision))
			expect(_ceiling depth, is equal to(31.0f) within(this precision))
			expect(_floor width, is equal to(10.0f) within(this precision))
			expect(_floor height, is equal to(20.0f) within(this precision))
			expect(_floor depth, is equal to(30.0f) within(this precision))
		})
		this add("p norm", func {
			onenorm := this vector0 pNorm(1)
			euclidean := this vector0 pNorm(2)
			expect(onenorm, is equal to(35.0f) within(this precision))
			expect(euclidean, is equal to(26.702f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this vector1 clamp(this vector0, this vector2)
			expect(clamped width, is equal to(12.0f) within(this precision))
			expect(clamped height, is equal to(10.0f) within(this precision))
			expect(clamped height, is equal to(20.0f) within(this precision))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (425.0f) within(this precision))
		})
	}
}
FloatSize3DTest new() run()
