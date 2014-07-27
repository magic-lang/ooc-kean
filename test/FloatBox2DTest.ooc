use ooc-unit
use ooc-math
import math
import lang/IO

FloatBox2DTest: class extends Fixture {
	precision := 1.0f / 1_0000.0f
	box0 := FloatBox2D new (1.0f, 2.0f, 3.0f, 4.0f)
	box1 := FloatBox2D new (4.0f, 3.0f, 2.0f, 1.0f)
	box2 := FloatBox2D new (2.0f, 1.0f, 4.0f, 3.0f)
	init: func () {
		super("FloatBox2D")
		this add("equality", func() {
			box := FloatBox2D new()
//			expect(this vector0, is equal to(this vector0))
//			expect(this vector0 equals(this vector0 as Object), is true)
			expect(this box0 == this box0, is true)
			expect(this box0 != this box1, is true)
			expect(this box0 == box, is false)
			expect(box == box, is true)
			expect(box == this box0, is false)
		})
		this add("leftTop", func() {
			leftTop := this box0 leftTop
			expect(leftTop x, is equal to(1.0f))
			expect(leftTop y, is equal to(2.0f))
		})
		this add("size", func() {
			size := this box0 size
			expect(size width, is equal to(3.0f))
			expect(size height, is equal to(4.0f))
		})
		this add("addition", func() {})
		this add("subtraction", func() {})
		this add("scalar multiplication", func() {})
		this add("casts", func() {
//			FIXME: We have no integer versions of anything yet
		})
	}
}
FloatBox2DTest new() run()
