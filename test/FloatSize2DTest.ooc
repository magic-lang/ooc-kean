use ooc-unit
use ooc-math
import math
import lang/IO
//import ../../../source/FloatExtension

FloatSize2DTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	vector0 := FloatSize2D new (22.221f, -3.1f)
	vector1 := FloatSize2D new (12.221f, 13.1f)
	vector2 := FloatSize2D new (34.442f, 10.0f)
	vector3 := FloatSize2D new (10.0f, 20.0f)
	init: func () {
		super("FloatSize2D")
		this add("equality", func() {
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
		this add("addition", func() {
			expect((this vector0 + this vector1) width, is equal to(this vector2 width))
			expect((this vector0 + this vector1) height, is equal to(this vector2 height))
		})
		this add("subtraction", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 - this vector0, is equal to(FloatSize2D new()))
		})
		this add("scalar multiplication", func() {
//			FIXME: Unary minus compiler bug
//			expect((-1) * this vector0, is equal to(-vector0)) (-1)
		})
		this add("scalar division", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 / (-1), is equal to(-vector0))
		})
		this add("get values", func() {
			expect(this vector0 width, is equal to(22.221f))
			expect(this vector0 height, is equal to(-3.1f))
		})
		this add("swap", func()	{
			result := this vector0 swap() 
			expect(result width, is equal to(this vector0 height))
			expect(result height, is equal to(this vector0 width))
		})
		this add("casting", func() {
			value := "10.00, 20.00"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(FloatSize2D parse(value), is equal to(this vector3))
		})
		this add("polar 0", func() {
			point := FloatSize2D new()
			expect(point Norm, is equal to(0))
			expect(point Azimuth, is equal to(0))
		})		
		this add("polar 1", func() {
			point := FloatSize2D new(1, 0)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(0))
		})		
		this add("polar 2", func() {
			point := FloatSize2D new(0, 1)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(PI as Float / 2.0f))
		})		
		this add("polar 3", func() {
			point := FloatSize2D new(0, -5)
			expect(point Norm, is equal to(5.0f))			
			expect(point Azimuth, is equal to(PI as Float / -2.0f))
		})		
		this add("polar 4", func() {
			point := FloatSize2D new(-1, 0)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(PI as Float))
		})		
		this add("polar 5", func() {
			point := FloatSize2D new(-3, 0)
			point2 := FloatSize2D polar(point Norm, point Azimuth)
			expect(point distance(point2), is equal to(0.0f) within(this precision))
		})
		this add("angles", func() {
			expect(FloatSize2D BasisX angle(FloatSize2D BasisX), is equal to(0.0f) within(this precision))
			expect(FloatSize2D BasisX angle(FloatSize2D BasisY), is equal to(PI as Float / 2.0f) within(this precision))
			expect(FloatSize2D BasisX angle(-FloatSize2D BasisX), is equal to(PI as Float) within(this precision))
			expect(FloatSize2D BasisX angle(-FloatSize2D BasisY), is equal to(-PI as Float / 2.0f) within(this precision))
		})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
FloatSize2DTest new() run()
