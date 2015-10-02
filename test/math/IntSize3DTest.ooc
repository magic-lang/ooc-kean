use ooc-unit
use ooc-math
import math
import lang/IO

IntSize3DTest: class extends Fixture {
	precision := 1.0e-5f
	vector0 := IntSize3D new (22, -3, 8)
	vector1 := IntSize3D new (12, 13, -8)
	vector2 := IntSize3D new (34, 10, 0)
	vector3 := IntSize3D new (10, 20, 0)
	init: func {
		super("IntSize3D")
		this add("equality", func {
			point := IntSize3D new()
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
			expect((this vector0 + this vector1) depth, is equal to(this vector2 depth))
		})
		this add("subtraction", func {
			expect((this vector0 - this vector0) width, is equal to((IntSize3D new()) width))
			expect((this vector0 - this vector0) height, is equal to((IntSize3D new()) height))
			expect((this vector0 - this vector0) depth, is equal to((IntSize3D new()) depth))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this vector0) width, is equal to((-vector0) width))
			expect(((-1) * this vector0) height, is equal to((-vector0) height))
			expect(((-1) * this vector0) depth, is equal to((-vector0) depth))
		})
		this add("scalar division", func {
			expect((this vector0 / (-1)) width, is equal to((-vector0) width))
			expect((this vector0 / (-1)) height, is equal to((-vector0) height))
			expect((this vector0 / (-1)) depth, is equal to((-vector0) depth))
		})
		this add("get values", func {
			expect(this vector0 width, is equal to(22))
			expect(this vector0 height, is equal to(-3))
			expect(this vector0 depth, is equal to(8))
		})
		this add("casting", func {
			value := "10, 20, 0"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(IntSize2D parse(value), is equal to(this vector3))
		})
		this add("float casts", func {
			vector := vector0 toFloatSize3D()
			expect(vector width, is equal to(22.0f) within(this precision))
			expect(vector height, is equal to(-3.0f) within(this precision))
			expect(vector depth, is equal to(8.0f) within(this precision))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (161))
		})
		this add("minimum maximum", func {
			_max := this vector0 maximum(this vector1)
			_min := this vector0 minimum(this vector1)
			expect(_max width, is equal to(22))
			expect(_max height, is equal to(13))
			expect(_max depth, is equal to(8))
			expect(_min width, is equal to(12))
			expect(_min height, is equal to(-3))
			expect(_min depth, is equal to(-8))
		})
		this add("clamp", func {
			result := this vector1 clamp(this vector0, this vector2)
			expect(result width, is equal to(22))
			expect(result height, is equal to(10))
			expect(result depth, is equal to(8))
		})
		this add("fillEven", func {
			even := IntSize3D fillEven(this vector0)
			expect(even width, is equal to(22))
			expect(even height, is equal to(-3)) //FIXME Incorrect due to mod operator not correct about negative numbers
			expect(even depth, is equal to(8))
		})
		this add("volume, empty", func {
			_empty := IntSize3D new()
			expect(_empty empty, is equal to(true))
			expect(this vector1 empty, is equal to(false))
			expect(this vector1 volume, is equal to(-1248))
			expect(_empty volume, is equal to(0))
		})
	}
}

IntSize3DTest new() run()
