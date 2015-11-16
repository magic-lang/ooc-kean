use ooc-unit
use ooc-base
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
			expect(this vector0 vectorProduct(this vector1) width, is equal to(-190.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) height, is equal to(-320.0f) within(this precision))
			expect(this vector0 vectorProduct(this vector1) depth, is equal to(322.0f) within(this precision))
		})
		this add("equality", func {
			size := FloatSize3D new()
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
			value := t"10.00, 20.00, 30.00"
			expect(this vector3 toString(), is equal to(value toString()))
			expect(FloatSize3D parse(value) width, is equal to(this vector3 width))
			expect(FloatSize3D parse(value) height, is equal to(this vector3 height))
			expect(FloatSize3D parse(value) depth, is equal to(this vector3 depth))
		})
		this add("int casts", func {
			vector := this vector0 toIntSize3D()
			expect(vector width, is equal to(22))
			expect(vector height, is equal to(-3))
			expect(vector depth, is equal to(10))
		})
		this add("float casts", func {
			point := this vector0 toFloatPoint3D()
			expect(point x, is equal to(this vector0 width) within(this precision))
			expect(point y, is equal to(this vector0 height) within(this precision))
			expect(point z, is equal to(this vector0 depth) within(this precision))
		})
		this add("minimum maximum", func {
			max := this vector0 maximum(this vector1)
			min := this vector0 minimum(this vector1)
			expect(max width, is equal to(22.0f) within(this precision))
			expect(max height, is equal to(13.0f) within(this precision))
			expect(max depth, is equal to(20.0f) within(this precision))
			expect(min width, is equal to(12.0f) within(this precision))
			expect(min height, is equal to(-3.0f) within(this precision))
			expect(min depth, is equal to(10.0f) within(this precision))
		})
		this add("rounding", func {
			round := this vector4 round()
			ceiling := this vector4 ceiling()
			floor := this vector4 floor()
			expect(round width, is equal to(10.0f) within(this precision))
			expect(round height, is equal to(21.0f) within(this precision))
			expect(round depth, is equal to(30.0f) within(this precision))
			expect(ceiling width, is equal to(11.0f) within(this precision))
			expect(ceiling height, is equal to(21.0f) within(this precision))
			expect(ceiling depth, is equal to(31.0f) within(this precision))
			expect(floor width, is equal to(10.0f) within(this precision))
			expect(floor height, is equal to(20.0f) within(this precision))
			expect(floor depth, is equal to(30.0f) within(this precision))
		})
		this add("p norm", func {
			oneNorm := this vector0 pNorm(1.0f)
			euclideanNorm := this vector0 pNorm(2.0f)
			expect(oneNorm, is equal to(35.0f) within(this precision))
			expect(euclideanNorm, is equal to(24.352f) within(0.01f))
		})
		this add("clamp", func {
			clamped := this vector1 clamp(this vector0, this vector2)
			expect(clamped width, is equal to(22.0f) within(this precision))
			expect(clamped height, is equal to(10.0f) within(this precision))
			expect(clamped depth, is equal to(20.0f) within(this precision))
		})
		this add("scalar product", func {
			expect(this vector0 scalarProduct(this vector1), is equal to (425.0f) within(this precision))
		})
		this add("interpolation", func {
			interpolate1 := FloatSize3D linearInterpolation(this vector0, this vector1, 0.0f)
			interpolate2 := FloatSize3D linearInterpolation(this vector0, this vector1, 0.5f)
			interpolate3 := FloatSize3D linearInterpolation(this vector0, this vector1, 1.0f)
			expect(interpolate1 width, is equal to(this vector0 width) within(this precision))
			expect(interpolate1 height, is equal to(this vector0 height) within(this precision))
			expect(interpolate1 depth, is equal to(this vector0 depth) within(this precision))
			expect(interpolate2 width, is equal to(17.0f) within(0.01f))
			expect(interpolate2 height, is equal to(5.0f) within(0.01f))
			expect(interpolate2 depth, is equal to(15.0f) within(0.01f))
			expect(interpolate3 width, is equal to(this vector1 width) within(this precision))
			expect(interpolate3 height, is equal to(this vector1 height) within(this precision))
			expect(interpolate3 depth, is equal to(this vector1 depth) within(this precision))
		})
		this add("angle and distance", func {
			first := FloatSize3D new(2.0f, -3.0f, 5.0f)
			second := FloatSize3D new(5.0f, 3.0f, -7.0f)
			expect(first angle(second), is equal to(2.221f) within(0.01f))
			expect(first distance(second), is equal to(13.74f) within(0.01f))
		})
		this add("length, empty", func {
			empty := FloatSize3D new()
			expect(this vector0 length, is equal to(24.35f) within(0.01f))
			expect(empty empty, is true)
			expect(empty volume, is equal to(0.0f) within(this precision))
			expect(this vector0 empty, is false)
		})
		this add("azimuth", func {
			myvector := FloatSize3D new(1.0, 5.5, 0.1)
			expect(myvector azimuth, is equal to(5.5 atan2(1.0) as Float) within(this precision))
		})
	}
}
FloatSize3DTest new() run()
