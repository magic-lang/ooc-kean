use ooc-unit
use ooc-math
import math
import lang/IO

FloatPoint2DTest: class extends Fixture {
	precision := 1.0e-5f
	point0 := FloatPoint2D new (22.221f, -3.1f)
	point1 := FloatPoint2D new (12.221f, 13.1f)
	point2 := FloatPoint2D new (34.442f, 10.0f)
	point3 := FloatPoint2D new (10.0f, 20.0f)
	init: func {
		super("FloatPoint2D")
		this add("equality", func {
			point := FloatPoint2D new()
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
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to((FloatPoint2D new()) x))
			expect((this point0 - this point0) y, is equal to((FloatPoint2D new()) y))
		})
		this add("scalar multiplication", func {
			expect(((-1) * this point0) x, is equal to((-point0) x))
			expect(((-1) * this point0) y, is equal to((-point0) y))
		})
		this add("scalar division", func {
			expect((this point0 / (-1)) x, is equal to((-point0) x))
			expect((this point0 / (-1)) y, is equal to((-point0) y))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22.221f))
			expect(this point0 y, is equal to(-3.1f))
		})
		this add("swap", func {
			result := this point0 swap()
			expect(result x, is equal to(this point0 y))
			expect(result y, is equal to(this point0 x))
		})
		this add("casting", func {
			value := "10.00, 20.00"
			expect(this point3 toString(), is equal to(value))
//			FIXME: Equals interface
			expect((FloatPoint2D parse(value)) x, is equal to((this point3) x))
			expect((FloatPoint2D parse(value)) y, is equal to((this point3) y))
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
			expect((this point0 minimum(this point1)) x, is equal to((this point1) x))
			expect((this point0 minimum(this point1)) y, is equal to((this point0) y))
		})
		this add("maximum", func {
			expect((this point0 maximum(this point1)) x, is equal to((this point0) x))
			expect((this point0 maximum(this point1)) y, is equal to((this point1) y))
		})
		this add("int casts", func {
			point := point3 toIntPoint2D()
			expect(point x, is equal to(10))
			expect(point y, is equal to(20))
		})
		this add("minimum maximum", func {
			_max := this point0 maximum(this point1)
			_min := this point0 minimum(this point1)
			expect(_max x, is equal to(22.221f) within(this precision))
			expect(_max y, is equal to(13.1f) within(this precision))
			expect(_min x, is equal to(12.221f) within(this precision))
			expect(_min y, is equal to(-3.1f) within(this precision))
		})
		this add("rounding", func {
			_round := this point1 round()
			_ceiling := this point1 ceiling()
			_floor := this point1 floor()
			expect(_round x, is equal to(12.0f) within(this precision))
			expect(_round y, is equal to(13.0f) within(this precision))
			expect(_ceiling x, is equal to(13.0f) within(this precision))
			expect(_ceiling y, is equal to(14.0f) within(this precision))
			expect(_floor x, is equal to(12.0f) within(this precision))
			expect(_floor y, is equal to(13.0f) within(this precision))
		})
		this add("p norm", func {
			onenorm := this point0 pNorm(1)
			euclidean := this point0 pNorm(2)
			expect(onenorm, is equal to(25.321f) within(this precision))
			expect(euclidean, is equal to(22.436f) within(0.01f))
		})
		this add("scalar product", func {
			expect(this point0 scalarProduct(this point1), is equal to (230.95f) within(0.01f))
		})
		this add("distance", func {
			_distance := point0 distance(point1)
			expect(_distance, is equal to(19.04f) within(0.01f))
		})
	}
}
FloatPoint2DTest new() run()
