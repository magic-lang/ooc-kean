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
			expect(result width, is equal to(this vector0 height) within(this precision))
			expect(result height, is equal to(this vector0 width) within(this precision))
		})
		this add("casting", func {
			value := t"10.00, 20.00"
			expect(this vector3 toString(), is equal to(value toString()))
			expect(FloatSize2D parse(value) width, is equal to(this vector3 width))
			expect(FloatSize2D parse(value) height, is equal to(this vector3 height))
		})
		this add("float casts", func {
			point := vector3 toFloatPoint2D()
			expect(point x, is equal to(vector3 width) within(this precision))
			expect(point y, is equal to(vector3 height) within(this precision))
		})
		this add("polar 0", func {
			point := FloatSize2D new()
			expect(point norm, is equal to(0))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 1", func {
			point := FloatSize2D new(1, 0)
			expect(point norm, is equal to(1.0f) within(this precision))
			expect(point azimuth, is equal to(0))
		})
		this add("polar 2", func {
			point := FloatSize2D new(0, 1)
			expect(point norm, is equal to(1.0f) within(this precision))
			expect(point azimuth, is equal to(Float pi / 2.0f) within(this precision))
		})
		this add("polar 3", func {
			point := FloatSize2D new(0, -5)
			expect(point norm, is equal to(5.0f) within(this precision))
			expect(point azimuth, is equal to(Float pi / -2.0f) within(this precision))
		})
		this add("polar 4", func {
			point := FloatSize2D new(-1, 0)
			expect(point norm, is equal to(1.0f) within(this precision))
			expect(point azimuth, is equal to(Float pi) within(this precision))
		})
		this add("polar 5", func {
			point := FloatSize2D new(-3, 0)
			point2 := FloatSize2D polar(point norm, point azimuth)
			expect(point distance(point2), is equal to(0.0f) within(this precision))
		})
		this add("angles", func {
			expect(FloatSize2D basisX angle(FloatSize2D basisX), is equal to(0.0f) within(this precision))
			expect(FloatSize2D basisX angle(FloatSize2D basisY), is equal to(Float pi / 2.0f) within(this precision))
			expect(FloatSize2D basisX angle(-FloatSize2D basisX), is equal to(Float pi) within(this precision))
			expect(FloatSize2D basisX angle(-FloatSize2D basisY), is equal to(-(Float pi) / 2.0f) within(this precision))
		})
		this add("int casts", func {
			vector := this vector0 toIntSize2D()
			expect(vector width, is equal to(22))
			expect(vector height, is equal to(-3))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max width, is equal to(22.221f) within(this precision))
			expect(max height, is equal to(13.1f) within(this precision))
			expect(min width, is equal to(12.221f) within(this precision))
			expect(min height, is equal to(-3.1f) within(this precision))
		})
		this add("rounding", func {
			round := this vector1 round()
			ceiling := this vector1 ceiling()
			floor := this vector1 floor()
			expect(round width, is equal to(12.0f) within(this precision))
			expect(round height, is equal to(13.0f) within(this precision))
			expect(ceiling width, is equal to(13.0f) within(this precision))
			expect(ceiling height, is equal to(14.0f) within(this precision))
			expect(floor width, is equal to(12.0f) within(this precision))
			expect(floor height, is equal to(13.0f) within(this precision))
		})
		this add("p norm", func {
			oneNorm := this vector0 pNorm(1.0f)
			euclideanNorm := this vector0 pNorm(2.0f)
			expect(oneNorm, is equal to(25.321f) within(this precision))
			expect(euclideanNorm, is equal to(22.436f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this vector1 clamp(this vector0, this vector2)
			expect(clamped width, is equal to(22.221f) within(this precision))
			expect(clamped height, is equal to(10.0f) within(this precision))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (230.95f) within(0.01f))
		})
		this add("interpolation", func {
			interpolate1 := FloatSize2D linearInterpolation(this vector0, this vector1, 0.0f)
			interpolate2 := FloatSize2D linearInterpolation(this vector0, this vector1, 0.5f)
			interpolate3 := FloatSize2D linearInterpolation(this vector0, this vector1, 1.0f)
			expect(interpolate1 width, is equal to(this vector0 width) within(this precision))
			expect(interpolate1 height, is equal to(this vector0 height) within(this precision))
			expect(interpolate2 width, is equal to(17.22f) within(0.01f))
			expect(interpolate2 height, is equal to(5.0f) within(0.01f))
			expect(interpolate3 width, is equal to(this vector1 width) within(this precision))
			expect(interpolate3 height, is equal to(this vector1 height) within(this precision))
		})
		this add("area, length, empty", func {
			empty := FloatSize2D new()
			expect(this vector0 area, is equal to(-68.89f) within(0.01f))
			expect(this vector0 length, is equal to(22.44f) within(0.01f))
			expect(empty empty, is true)
			expect(empty area, is equal to(0.0f) within(this precision))
			expect(this vector1 empty, is false)
		})
	}
}
FloatSize2DTest new() run()
