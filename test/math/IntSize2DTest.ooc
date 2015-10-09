use ooc-unit
use ooc-math
import math
import lang/IO

IntSize2DTest: class extends Fixture {
	precision := 1.0e-5f
	vector0 := IntSize2D new (22, -3)
	vector1 := IntSize2D new (12, 13)
	vector2 := IntSize2D new (34, 10)
	vector3 := IntSize2D new (10, 20)
	init: func {
		super("IntSize2D")
		this add("equality", func {
			point := IntSize2D new()
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
			expect((this vector0 - this vector0) width, is equal to((IntSize2D new()) width))
			expect((this vector0 - this vector0) height, is equal to((IntSize2D new()) height))
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
			expect(this vector0 width, is equal to(22))
			expect(this vector0 height, is equal to(-3))
		})
		this add("swap", func {
			result := this vector0 swap()
			expect(result width, is equal to(this vector0 height))
			expect(result height, is equal to(this vector0 width))
		})
		this add("casting", func {
			value := "10, 20"
			expect(this vector3 toString(), is equal to(value))
			point := this vector3 toIntPoint2D()
			expect(point x, is equal to(this vector3 width))
			expect(point y, is equal to(this vector3 height))
		})
		this add("float casts", func {
			vector := vector0 toFloatSize2D()
			expect(vector width, is equal to(22.0f) within(this precision))
			expect(vector height, is equal to(-3.0f) within(this precision))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (225))
		})
		this add("minimum maximum", func {
			_max := vector0 maximum(this vector1)
			_min := vector0 minimum(this vector1)
			expect(_max width, is equal to(22))
			expect(_max height, is equal to(13))
			expect(_min width, is equal to(12))
			expect(_min height, is equal to(-3))
		})
		this add("clamp", func {
			result := vector1 clamp(this vector0, this vector2)
			expect(result width, is equal to(22))
			expect(result height, is equal to(10))
		})
		this add("fillEven", func {
			even := IntSize2D fillEven(this vector1)
			expect(even width, is equal to(12))
			expect(even height, is equal to(14))
		})
		this add("polar", func {
			sqrttwo := IntSize2D polar(1.415f, 0.785f)
			expect(sqrttwo width, is equal to(1))
			expect(sqrttwo height, is equal to(1))
		})
		this add("area, square, empty", func {
			_rectangle := IntSize2D new(10, 20)
			_square := IntSize2D new(5, 5)
			_empty := IntSize2D new()
			expect(_rectangle area, is equal to(200))
			expect(_square square, is equal to(true))
			expect(_rectangle square, is equal to(false))
			expect(_empty empty, is equal to(true))
			expect(_square empty, is equal to(false))
			expect(_empty area, is equal to(0))
		})
	}
}
IntSize2DTest new() run()
