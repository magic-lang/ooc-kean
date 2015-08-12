use ooc-unit
use ooc-math
import math
import lang/IO

FloatPoint2DTest: class extends Fixture {
	precision := 1.0e-5f
	vector0 := FloatPoint2D new (22.221f, -3.1f)
	vector1 := FloatPoint2D new (12.221f, 13.1f)
	vector2 := FloatPoint2D new (34.442f, 10.0f)
	vector3 := FloatPoint2D new (10.0f, 20.0f)
	init: func {
		super("FloatPoint2D")
		this add("equality", func {
			point := FloatPoint2D new()
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
			expect((this vector0 - this vector0) x, is equal to((FloatPoint2D new()) x))
			expect((this vector0 - this vector0) y, is equal to((FloatPoint2D new()) y))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this vector0) x, is equal to((-vector0) x))
			expect(((-1) * this vector0) y, is equal to((-vector0) y))
		})
		this add("scalar division", func {
			expect((this vector0 / (-1)) x, is equal to((-vector0) x))
			expect((this vector0 / (-1)) y, is equal to((-vector0) y))
		})
		this add("get values", func {
			expect(this vector0 x, is equal to(22.221f))
			expect(this vector0 y, is equal to(-3.1f))
		})
		this add("swap", func	{
			result := this vector0 swap()
			expect(result x, is equal to(this vector0 y))
			expect(result y, is equal to(this vector0 x))
		})
		this add("casting", func {
			value := "10.00, 20.00"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
			expect((FloatPoint2D parse(value)) x, is equal to((this vector3) x))
			expect((FloatPoint2D parse(value)) y, is equal to((this vector3) y))
		})
		this add("polar 0", func {
			point := FloatPoint2D new()
			expect(point norm, is equal to(0))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 1", func {
			point := FloatPoint2D new(1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 2", func {
			point := FloatPoint2D new(0, 1)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(PI as Float / 2.0f))
		})
		this add("polar 3", func {
			point := FloatPoint2D new(0, -5)
			expect(point norm, is equal to(5.0f))
			expect(point azimuth, is equal to(PI as Float / -2.0f))
		})
		this add("polar 4", func {
			point := FloatPoint2D new(-1, 0)
			expect(point norm, is equal to(1.0f))
			expect(point azimuth, is equal to(PI as Float))
		})
		this add("polar 5", func {
			point := FloatPoint2D new(-3, 0)
			point2 := FloatPoint2D polar(point norm, point azimuth)
			expect(point distance(point2), is equal to(0.0f) within(this precision))
		})
		this add("angles", func {
			expect(FloatPoint2D basisX angle(FloatPoint2D basisX), is equal to(0.0f) within(this precision))
			expect(FloatPoint2D basisX angle(FloatPoint2D basisY), is equal to(PI as Float / 2.0f) within(this precision))
			expect(FloatPoint2D basisX angle(-FloatPoint2D basisX), is equal to(PI as Float) within(this precision))
			expect(FloatPoint2D basisX angle(-FloatPoint2D basisY), is equal to(-PI as Float / 2.0f) within(this precision))
		})
		this add("minimum", func {
			expect((this vector0 minimum(this vector1)) x, is equal to((this vector1) x))
			expect((this vector0 minimum(this vector1)) y, is equal to((this vector0) y))
		})
		this add("maximum", func {
			expect((this vector0 maximum(this vector1)) x, is equal to((this vector0) x))
			expect((this vector0 maximum(this vector1)) y, is equal to((this vector1) y))
		})
		this add("casts", func {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
FloatPoint2DTest new() run()
