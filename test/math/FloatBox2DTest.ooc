use ooc-unit
use ooc-math
use ooc-collections
import math
import lang/IO

FloatBox2DTest: class extends Fixture {
	precision := 1.0e-5f
	box0 := FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f)
	box1 := FloatBox2D new (4.0f, 3.0f, 2.0f, 1.0f)
	box2 := FloatBox2D new (2.0f, 1.0f, 4.0f, 3.0f)
	init: func {
		super("FloatBox2D")
		this add("equality", func {
			box := FloatBox2D new()
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this box0 == this box0, is true)
			expect(this box0 != this box1, is true)
			expect(this box0 == box, is false)
			expect(box == box, is true)
			expect(box == this box0, is false)
		})
		this add("leftTop", func {
			leftTop := this box0 leftTop
			expect(leftTop x, is equal to(1.0f))
			expect(leftTop y, is equal to(2.0f))
		})
		this add("size", func {
			size := this box0 size
			expect(size width, is equal to(3.0f))
			expect(size height, is equal to(4.0f))
		})
		this add("addition", func)
		this add("subtraction", func)
		this add("scalar multiplication", func)
		this add("casts", func {
//			FIXME: We have no integer versions of anything yet
		})
		this add("contains~FloatPoint2DVectorList", func {
			box := FloatBox2D new(-2.0f, -1.0f, 3.0f, 3.0f)
			list := FloatPoint2DVectorList new()
			list add(FloatPoint2D new(0.0f, 1.0f))
			list add(FloatPoint2D new(-2.0f, 2.0f))
			list add(FloatPoint2D new(-2.0f, -2.0f))
			list add(FloatPoint2D new(0.0f, 0.0f))
			inBox := box contains~FloatPoint2DVectorList(list)
			expect(inBox count, is equal to(3))
			expect(inBox[0], is equal to(0))
			expect(inBox[1], is equal to(1))
			expect(inBox[2], is equal to(3))
		})
		this add("enlarge and shrink", func {
			box := FloatBox2D new(-2.0f, -1.0f, 3.0f, 3.0f)
			paddedBox := box enlarge(0.1f)
			shrunkBox := paddedBox shrink(1.0f / 11.0f)
			expect(box == shrunkBox, is true)
		})
		this add("enlargeEvenly", func {
			box := FloatBox2D new(-3.0f, -1.0f, 3.0f, 3.0f)
			paddedBox := box enlargeEvenly(2.0f)
			expect(paddedBox == FloatBox2D new(-9.0f, -7.0f, 15.0f, 15.0f))
		})
		this add("resizeTo", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			changedBox := box resizeTo(FloatSize2D new(2.0f, 2.0f))
			expect(changedBox left, is equal to(2.0f) within(this precision))
			expect(changedBox right, is equal to(4.0f) within(this precision))
			expect(changedBox top, is equal to(2.0f) within(this precision))
			expect(changedBox bottom, is equal to(4.0f) within(this precision))
		})
		this add("scale", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			doubledBox := box scale(2.0f)
			halfBox := box scale(0.5f)
			expect(doubledBox left, is equal to(-1.0f) within(this precision))
			expect(doubledBox right, is equal to(7.0f) within(this precision))
			expect(doubledBox top, is equal to(-1.0f) within(this precision))
			expect(doubledBox bottom, is equal to(7.0f) within(this precision))
			expect(halfBox left, is equal to(2.0f) within(this precision))
			expect(halfBox right, is equal to(4.0f) within(this precision))
			expect(halfBox top, is equal to(2.0f) within(this precision))
			expect(halfBox bottom, is equal to(4.0f) within(this precision))
		})
		this add("enlarge", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			enlargedBox := box enlargeTo(FloatSize2D new(6.0f, 6.0f))
			notEnlargedBox := box enlargeTo(FloatSize2D new(3.0f, 3.0f))
			expect(enlargedBox left, is equal to(0.0f) within(this precision))
			expect(enlargedBox top, is equal to(0.0f) within(this precision))
			expect(enlargedBox right, is equal to(6.0f) within(this precision))
			expect(enlargedBox bottom, is equal to(6.0f) within(this precision))
			expect(notEnlargedBox == box, is true)
		})
		this add("reduce", func {
			box := FloatBox2D new(1.0f, 1.0f, 4.0f, 4.0f)
			reducedBox := box shrinkTo(FloatSize2D new(2.0f, 2.0f))
			notReducedBox := box shrinkTo(FloatSize2D new(6.0f, 6.0f))
			expect(reducedBox left, is equal to(2.0f) within(this precision))
			expect(reducedBox top, is equal to(2.0f) within(this precision))
			expect(reducedBox right, is equal to(4.0f) within(this precision))
			expect(reducedBox bottom, is equal to(4.0f) within(this precision))
			expect(notReducedBox == box, is true)
		})
		this add("box to point distance", func {
			box := FloatBox2D new(-10.f, -10.f, 20.f, 20.f)
			points := VectorList<FloatPoint2D> new()
			points add(FloatPoint2D new(5.f, 5.f))
			points add(FloatPoint2D new(15.f, 0.f))
			points add(FloatPoint2D new(0.f, -17.f))
			points add(FloatPoint2D new(11.f, -12.f))
			separatedDistance := box distance(points[0])
			expect(separatedDistance width, is equal to(0.f) within(this precision))
			expect(separatedDistance height, is equal to(0.f) within(this precision))
			separatedDistance = box distance(points[3])
			expect(separatedDistance width, is equal to(1.f) within(this precision))
			expect(separatedDistance height, is equal to(2.f) within(this precision))
			maximumSeparatedDistance := box maximumDistance(points)
			expect(maximumSeparatedDistance width, is equal to(5.f) within(this precision))
			expect(maximumSeparatedDistance height, is equal to(7.f) within(this precision))
			points free()
		})
		this add("interpolate", func {
			a := FloatBox2D new(1.0f, 5.0f, 3.0f, 4.0f)
			b := FloatBox2D new(4.0f, -1.0f, 0.0f, 1.0f)
			interpolatedBox := FloatBox2D linearInterpolation(a, b, 1.0f / 3.0f)
			expect(interpolatedBox left, is equal to(2.0f) within(this precision))
			expect(interpolatedBox top, is equal to(3.0f) within(this precision))
			expect(interpolatedBox width, is equal to(2.0f) within(this precision))
			expect(interpolatedBox height, is equal to(3.0f) within(this precision))
		})
	}
}
FloatBox2DTest new() run()
