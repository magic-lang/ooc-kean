use ooc-unit
use ooc-math


SizeTest: class extends Fixture {
	vector0 := Size new (22.221f, -3.1f)
	vector1 := Size new (12.221f, 13.1f)
	vector2 := Size new (34.442f, 10.0f)
	vector3 := Size new (10.0f, 20.0f)
	init: func () {
		super("Size")
		this add("get values", func() 
		{
			expect(this vector0 width, is equal to(22.221f))
			expect(this vector0 height, is equal to(-3.1f))
		})
		this add("swap", func() 
		{
			Size result := this vector0 swap() 
			expect(result width, is equal to(this vector0 height))
			expect(result height, is equal to(this vector0 width))
		})
		this add("casting"
	}
}
SizeTest new() run()
