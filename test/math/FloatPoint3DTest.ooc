use ooc-unit
use ooc-math
import math
import lang/IO

FloatPoint3DTest: class extends Fixture {
	precision := 1.0e-4f
	point0 := FloatPoint3D new (22.0f, -3.0f, 10.0f)
	point1 := FloatPoint3D new (12.0f, 13.0f, 20.0f)
	point2 := FloatPoint3D new (34.0f, 10.0f, 30.0f)
	point3 := FloatPoint3D new (10.1f, 20.2f, 30.3f)
	point4 := FloatPoint3D new (10.1f, 20.7f, 30.3f)
	init: func {
		super("FloatPoint3D")
		this add("norm", func {
			expect(this point0 norm, is equal to(24.3515f) within(this precision))
		})
		this add("scalar product", func {
			point := FloatPoint3D new()
			expect(this point0 scalarProduct(point), is equal to(0.0f) within(this precision))
			expect(this point0 scalarProduct(this point1), is equal to(425.0f) within(this precision))
		})
		this add("scalar multiplication", func {
			expect(this point0 vectorProduct(this point1) x, is equal to(-190.0f) within(this precision))
			expect(this point0 vectorProduct(this point1) y, is equal to(-320.0f) within(this precision))
			expect(this point0 vectorProduct(this point1) z, is equal to(322.0f) within(this precision))
		})
		this add("equality", func {
			point := FloatPoint3D new()
			expect(this point0 == this point0, is true)
			expect(this point0 != this point1, is true)
			expect(this point0 == point, is false)
			expect(point == point, is true)
			expect(point == this point0, is false)
		})
		this add("addition", func {
			expect((this point0 + this point1) x, is equal to(this point2 x) within(this precision))
			expect((this point0 + this point1) y, is equal to(this point2 y) within(this precision))
			expect((this point0 + this point1) z, is equal to(this point2 z) within(this precision))
		})
		this add("subtraction", func {
			expect((this point0 - this point0) x, is equal to(FloatPoint3D new() x))
			expect((this point0 - this point0) y, is equal to(FloatPoint3D new() y))
			expect((this point0 - this point0) z, is equal to(FloatPoint3D new() z))
		})
		this add("get values", func {
			expect(this point0 x, is equal to(22.0f))
			expect(this point0 y, is equal to(-3.0f))
			expect(this point0 z, is equal to(10.0f))
		})
		this add("casting", func {
			value := "12.00000000, 13.00000000, 20.00000000"
			expect(this point1 toString(), is equal to(value))
		})
		this add("p norm", func {
			oneNorm := this point0 pNorm(1.0f)
			euclideanNorm := this point0 pNorm(2.0f)
			expect(oneNorm, is equal to(35.0f) within(this precision))
			expect(euclideanNorm, is equal to(24.352f) within(0.01f))
		})
		this add("int casts", func {
			point := point3 toIntPoint3D()
			expect(point x, is equal to(10))
			expect(point y, is equal to(20))
			expect(point z, is equal to(30))
		})
		this add("minimum maximum", func {
			max := this point0 maximum(this point1)
			min := this point0 minimum(this point1)
			expect(max x, is equal to(22.0f) within(this precision))
			expect(max y, is equal to(13.0f) within(this precision))
			expect(max z, is equal to(20.0f) within(this precision))
			expect(min x, is equal to(12.0f) within(this precision))
			expect(min y, is equal to(-3.0f) within(this precision))
			expect(min z, is equal to(10.0f) within(this precision))
		})
		this add("rounding", func {
			round := this point4 round()
			ceiling := this point4 ceiling()
			floor := this point4 floor()
			expect(round x, is equal to(10.0f) within(this precision))
			expect(round y, is equal to(21.0f) within(this precision))
			expect(round z, is equal to(30.0f) within(this precision))
			expect(ceiling x, is equal to(11.0f) within(this precision))
			expect(ceiling y, is equal to(21.0f) within(this precision))
			expect(ceiling z, is equal to(31.0f) within(this precision))
			expect(floor x, is equal to(10.0f) within(this precision))
			expect(floor y, is equal to(20.0f) within(this precision))
			expect(floor z, is equal to(30.0f) within(this precision))
		})
		this add("clamp", func {
			clamped := this point1 clamp(this point0, this point2)
			expect(clamped x, is equal to(22.0f) within(this precision))
			expect(clamped y, is equal to(10.0f) within(this precision))
			expect(clamped z, is equal to(20.0f) within(this precision))
		})
		this add("distance", func {
			distance := point0 distance(point1)
			expect(distance, is equal to(21.354f) within(0.01f))
		})
		this add("interpolation", func {
			interpolate1 := FloatPoint3D linearInterpolation(this point0, this point1, 0.0f)
			interpolate2 := FloatPoint3D linearInterpolation(this point0, this point1, 0.5f)
			interpolate3 := FloatPoint3D linearInterpolation(this point0, this point1, 1.0f)
			expect(interpolate1 x, is equal to(this point0 x) within(this precision))
			expect(interpolate1 y, is equal to(this point0 y) within(this precision))
			expect(interpolate1 z, is equal to(this point0 z) within(this precision))
			expect(interpolate2 x, is equal to(17.0f) within(0.01f))
			expect(interpolate2 y, is equal to(5.0f) within(0.01f))
			expect(interpolate2 z, is equal to(15.0f) within(0.01f))
			expect(interpolate3 x, is equal to(this point1 x) within(this precision))
			expect(interpolate3 y, is equal to(this point1 y) within(this precision))
			expect(interpolate3 z, is equal to(this point1 z) within(this precision))
		})
		this add("angle", func {
			first := FloatPoint3D new(2.0f, -3.0f, 5.0f)
			second := FloatPoint3D new(5.0f, 3.0f, -7.0f)
			expect(first angle(second), is equal to(2.221f) within(0.01f))
		})
		this add("spherical", func {
			point := FloatPoint3D spherical(5.0f, 1.23f, 0.57f)
			expect(point x, is equal to(0.90f) within(0.01f))
			expect(point y, is equal to(2.54f) within(0.01f))
			expect(point z, is equal to(4.21f) within(0.01f))
		})
		this add("azimuth", func {
			mypoint := FloatPoint3D new(1.0, 5.5, 0.1)
			expect(mypoint azimuth, is equal to(5.5 atan2(1.0) as Float) within(this precision))
		})
	}
}
FloatPoint3DTest new() run()
