use ooc-unit
use ooc-base
use ooc-math
import math
import lang/IO

FloatSize2DTest: class extends Fixture {
	precision := 1.0e-4f
	vector0 := FloatSize2D new (22.221f, -3.1f)
	vector1 := FloatSize2D new (12.221f, 13.1f)
	vector2 := FloatSize2D new (34.442f, 10.0f)
	vector3 := FloatSize2D new (10.0f, 20.0f)
	init: func {
		super("FloatSize2D")
		this add("equality", func {
			point := FloatSize2D new()
//			FIXME: There is no equals interface yet
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func {
			expect((this vector0 + this vector1) width, is equal to(this vector2 width))
			expect((this vector0 + this vector1) height, is equal to(this vector2 height))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) width, is equal to(FloatSize2D new() width))
			expect((this vector0 - this vector0) height, is equal to(FloatSize2D new() height))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this vector0) width, is equal to((-vector0) width))
			expect(((-1) * this vector0) height, is equal to((-vector0) height))
		})
		this add("scalar division", func {
			expect((this vector0 / (-1)) width, is equal to((-vector0) width))
			expect((this vector0 / (-1)) height, is equal to((-vector0) height))
		})
		this add("get values", func {
			expect(this vector0 width, is equal to(22.221f))
			expect(this vector0 height, is equal to(-3.1f))
		})
		this add("swap", func {
			result := this vector0 swap()
			expect(result width, is equal to(this vector0 height))
			expect(result height, is equal to(this vector0 width))
		})
		this add("casting", func {
			value := t"10.00, 20.00"
			expect(this vector3 toString(), is equal to(value toString()))
			expect(FloatSize2D parse(value) width, is equal to(this vector3 width))
			expect(FloatSize2D parse(value) height, is equal to(this vector3 height))
		})
		this add("polar 0", func {
			point := FloatSize2D new()
			expect(point norm, is equal to(0))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 1", func {
			point := FloatSize2D new(1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 2", func {
			point := FloatSize2D new(0, 1)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(PI as Float / 2.0f))
		})
		this add("polar 3", func {
			point := FloatSize2D new(0, -5)
			expect(point norm, is equal to(5.0f))
			expect(point azimuth, is equal to(PI as Float / -2.0f))
		})
		this add("polar 4", func {
			point := FloatSize2D new(-1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(PI as Float))
		})
		this add("polar 5", func {
			point := FloatSize2D new(-3, 0)
			point2 := FloatSize2D polar(point norm, point azimuth)
			expect(point distance(point2), is equal to(0.0f) within(this precision))
		})
		this add("angles", func {
			expect(FloatSize2D basisX angle(FloatSize2D basisX), is equal to(0.0f) within(this precision))
			expect(FloatSize2D basisX angle(FloatSize2D basisY), is equal to(PI as Float / 2.0f) within(this precision))
			expect(FloatSize2D basisX angle(-FloatSize2D basisX), is equal to(PI as Float) within(this precision))
			expect(FloatSize2D basisX angle(-FloatSize2D basisY), is equal to(-PI as Float / 2.0f) within(this precision))
		})
		this add("int casts", func {
			vector := vector0 toIntSize2D()
			expect(vector width, is equal to(22))
			expect(vector height, is equal to(-3))
		})
	}
}
FloatSize2DTest new() run()
