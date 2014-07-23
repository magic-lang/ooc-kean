use ooc-unit
use ooc-math
import math
import lang/IO

PointTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	vector0 := Point new (22.221f, -3.1f)
	vector1 := Point new (12.221f, 13.1f)
	vector2 := Point new (34.442f, 10.0f)
	vector3 := Point new (10.0f, 20.0f)
	init: func () {
		super("Point")
		this add("equality", func() {
			point := Point new()
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector as Object), is true
			expect(this vector0 == this vector0, is true)
			expect(this vector0 != this vector1, is true)
			expect(this vector0 == point, is false)
			expect(point == point, is true)
			expect(point == this vector0, is false)
		})
		this add("addition", func() {
			expect((this vector0 + this vector1) x, is equal to(this vector2 x))
			expect((this vector0 + this vector1) y, is equal to(this vector2 y))
		})
		this add("subtraction", func() {
//			FIXME: Unary minus compiler bug
//			expect(this vector0 - this vector0, is equal to(Size new()))
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
			expect(this vector0 x, is equal to(22.221f))
			expect(this vector0 y, is equal to(-3.1f))
		})
		this add("swap", func()	{
			result := this vector0 swap() 
			expect(result x, is equal to(this vector0 y))
			expect(result y, is equal to(this vector0 x))
		})
		this add("casting", func() {
			value := "10.00, 20.00"
			expect(this vector3 toString(), is equal to(value))
//			FIXME: Equals interface
//			expect(Size parse(value), is equal to(this vector3))
		})
		this add("polar 0", func() {
			point := Size new()
			expect(point Norm, is equal to(0))
			expect(point Azimuth, is equal to(0))
		})		
		this add("polar 1", func() {
			point := Size new(1, 0)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(0))
		})		
		this add("polar 2", func() {
			point := Size new(0, 1)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(PI as Float / 2.0f))
		})		
		this add("polar 3", func() {
			point := Size new(0, -5)
			expect(point Norm, is equal to(5.0f))			
			expect(point Azimuth, is equal to(PI as Float / -2.0f))
		})		
		this add("polar 4", func() {
			point := Size new(-1, 0)
			expect(point Norm, is equal to(1.0f))
			expect(point Azimuth, is equal to(PI as Float))
		})		
		this add("polar 5", func() {
			point := Size new(-3, 0)
			point2 := Size polar(point Norm, point Azimuth)
			expect(point distance(point2), is equal to(0.0f) within(this precision))
		})
		this add("angles", func() {
			expect(Size BasisX angle(Size BasisX), is equal to(0.0f) within(this precision))
			expect(Size BasisX angle(Size BasisY), is equal to(PI as Float / 2.0f) within(this precision))
			expect(Size BasisX angle(-Size BasisX), is equal to(PI as Float) within(this precision))
			expect(Size BasisX angle(-Size BasisY), is equal to(-PI as Float / 2.0f) within(this precision))
		})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
PointTest new() run()
